import 'dart:async';

import 'offline_workout_store.dart';
import 'offline_security_payload.dart';
import 'offline_security_session.dart';

/// This gate stays closed until real-data encryption, account lifecycle, and
/// the PostgreSQL concurrency gate are implemented and verified.
const bool productionOfflineSyncEnabled = false;
final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// The narrow result of the owner-scoped, idempotent set-create RPC.
final class SyncSetAck {
  final String operationId;
  final String workoutId;
  final String setId;

  const SyncSetAck({
    required this.operationId,
    required this.workoutId,
    required this.setId,
  });
}

/// A transport must map the server's explicit conflict/validation errors to
/// [SyncTerminalFailure]. Other errors may have occurred after server commit,
/// so they are retried using the same immutable operation ID and payload.
abstract interface class OfflineSetCreateTransport {
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent);
}

/// Owner-bound transport must abort a pending request on session invalidation.
abstract interface class OfflineCancellableSetCreateTransport
    implements OfflineSetCreateTransport {
  void cancelInFlight();
}

final class SyncTerminalFailure implements Exception {
  final String reason;

  const SyncTerminalFailure(this.reason);
}

final class SyncPumpResult {
  final int acknowledged;
  final int scheduledForRetry;
  final int conflicts;
  final bool skippedBecauseBusy;
  final bool stoppedBySessionChange;

  const SyncPumpResult({
    this.acknowledged = 0,
    this.scheduledForRetry = 0,
    this.conflicts = 0,
    this.skippedBecauseBusy = false,
    this.stoppedBySessionChange = false,
  });
}

/// A deterministic, bounded retry schedule for synthetic coordination tests.
final class SyncRetryPolicy {
  static Duration delayAfterAttempt(int attemptCount) {
    if (attemptCount < 1) {
      throw ArgumentError.value(attemptCount, 'attemptCount');
    }
    final exponent = (attemptCount - 1).clamp(0, 6);
    final seconds = (1 << exponent).clamp(1, 60);
    return Duration(seconds: seconds);
  }
}

/// Serializes one workout's local intents and relies on the server ledger for
/// idempotency across crashes, lost ACKs, and concurrent devices.
///
/// This class has no production caller. All tests use synthetic IDs and data.
final class OfflineSyncCoordinator {
  final OfflineQueueAccess _store;
  final OfflineSetCreateTransport _transport;
  final DateTime Function() _clock;
  final OfflineAuthenticatedSession? _session;
  bool _running = false;

  OfflineSyncCoordinator._(
    this._store,
    this._transport,
    this._clock,
    this._session,
  );

  factory OfflineSyncCoordinator.production({
    required OwnerScopedOfflineQueue store,
    required OfflineCancellableSetCreateTransport transport,
    required DateTime Function() clock,
    required OfflineAuthenticatedSession session,
  }) {
    if (!productionOfflineSyncEnabled ||
        !productionOfflinePayloadProtectionEnabled) {
      throw StateError('Production offline sync is disabled');
    }
    return OfflineSyncCoordinator._(store, transport, clock, session);
  }

  OfflineSyncCoordinator.syntheticTest({
    required OfflineWorkoutStore store,
    required OfflineSetCreateTransport transport,
    required DateTime Function() clock,
  }) : this._(store, transport, clock, null);

  OfflineSyncCoordinator.syntheticOwnerScopedTest({
    required OwnerScopedOfflineQueue store,
    required OfflineCancellableSetCreateTransport transport,
    required DateTime Function() clock,
    required OfflineAuthenticatedSession session,
  }) : this._(store, transport, clock, session);

  Future<SyncPumpResult> pump({
    required String ownerId,
    required String workoutId,
  }) async {
    if (_running) return const SyncPumpResult(skippedBecauseBusy: true);
    final session = _session;
    final generation = session?.generation;
    if (session != null && session.authenticatedOwnerId != ownerId) {
      throw StateError('Authenticated owner does not match sync owner');
    }
    bool sameSession() =>
        session == null ||
        (session.generation == generation &&
            session.authenticatedOwnerId == ownerId);
    _running = true;
    var acknowledged = 0;
    var scheduledForRetry = 0;
    var conflicts = 0;
    SyncPumpResult stopped() => SyncPumpResult(
      acknowledged: acknowledged,
      scheduledForRetry: scheduledForRetry,
      conflicts: conflicts,
      stoppedBySessionChange: true,
    );
    try {
      final intents = await _store.pendingForOwnerWorkout(ownerId, workoutId);
      if (!sameSession()) return stopped();
      intents.sort((a, b) {
        final created = a.createdAtUtcMillis.compareTo(b.createdAtUtcMillis);
        return created != 0 ? created : a.operationId.compareTo(b.operationId);
      });
      for (final intent in intents) {
        if (!sameSession()) return stopped();
        final nowUtcMillis = _clock().toUtc().millisecondsSinceEpoch;
        if (intent.state == 'conflict') break;
        if (intent.state == 'in_flight') {
          final released = await _store.releaseExpiredInFlight(
            ownerId,
            workoutId,
            intent.operationId,
            nowUtcMillis,
          );
          if (!sameSession()) return stopped();
          if (!released) break;
        }
        final claimedAttempt = await _store.claim(
          ownerId,
          workoutId,
          intent.operationId,
          nowUtcMillis,
        );
        if (!sameSession()) return stopped();
        if (claimedAttempt == null) break;

        SyncSetAck ack;
        try {
          final request = _transport.applySetCreate(intent);
          if (session == null) {
            ack = await request;
          } else {
            final changed = Completer<SyncSetAck?>();
            final subscription = session.changes.listen((_) {
              if (changed.isCompleted) return;
              try {
                (_transport as OfflineCancellableSetCreateTransport)
                    .cancelInFlight();
              } finally {
                changed.complete(null);
              }
            });
            SyncSetAck? result;
            try {
              if (!sameSession()) {
                (_transport as OfflineCancellableSetCreateTransport)
                    .cancelInFlight();
                return stopped();
              }
              result = await Future.any<SyncSetAck?>([request, changed.future]);
            } finally {
              await subscription.cancel();
            }
            if (result == null || !sameSession()) return stopped();
            ack = result;
          }
        } on SyncTerminalFailure {
          if (!sameSession()) return stopped();
          final marked = await _store.markConflict(
            ownerId,
            workoutId,
            intent.operationId,
            claimedAttempt,
          );
          if (!sameSession()) return stopped();
          if (marked) conflicts++;
          break;
        } catch (_) {
          if (!sameSession()) return stopped();
          // An uncertain response may follow a successful server commit. The
          // next attempt replays the same operation and receives its ledger result.
          final nextAttempt =
              _clock().toUtc().millisecondsSinceEpoch +
              SyncRetryPolicy.delayAfterAttempt(claimedAttempt).inMilliseconds;
          final scheduled = await _store.scheduleRetry(
            ownerId,
            workoutId,
            intent.operationId,
            nextAttempt,
            claimedAttempt,
          );
          if (!sameSession()) return stopped();
          if (scheduled) scheduledForRetry++;
          break;
        }
        if (!sameSession()) return stopped();
        if (ack.operationId != intent.operationId ||
            ack.workoutId != intent.workoutId ||
            !_uuidPattern.hasMatch(ack.setId)) {
          final marked = await _store.markConflict(
            ownerId,
            workoutId,
            intent.operationId,
            claimedAttempt,
          );
          if (!sameSession()) return stopped();
          if (marked) conflicts++;
          break;
        }
        if (!sameSession()) return stopped();
        bool removed;
        try {
          removed = await _store.acknowledge(
            ownerId,
            workoutId,
            intent.operationId,
            claimedAttempt,
          );
        } on StateError {
          // A local projection invariant failed after the server acknowledged.
          // Quarantine it for manual repair instead of replaying indefinitely.
          if (!sameSession()) return stopped();
          await _store.markConflict(
            ownerId,
            workoutId,
            intent.operationId,
            claimedAttempt,
          );
          if (!sameSession()) return stopped();
          rethrow;
        }
        if (!sameSession()) return stopped();
        if (!removed) break;
        acknowledged++;
      }
      return SyncPumpResult(
        acknowledged: acknowledged,
        scheduledForRetry: scheduledForRetry,
        conflicts: conflicts,
      );
    } on StateError {
      if (!sameSession()) return stopped();
      rethrow;
    } finally {
      _running = false;
    }
  }
}
