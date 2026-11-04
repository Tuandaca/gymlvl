import 'dart:async';

import 'package:app/features/workout/data/offline_payload_cipher.dart';
import 'package:app/features/workout/data/offline_secure_key_store.dart';
import 'package:app/features/workout/data/offline_security_session.dart';
import 'package:app/features/workout/data/offline_security_payload.dart';
import 'package:app/features/workout/data/offline_sync_coordinator.dart';
import 'package:app/features/workout/data/offline_workout_store.dart';
import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const ownerA = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const ownerB = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const workoutA = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const exerciseA = 'dddddddd-dddd-dddd-dddd-dddddddddddd';
const operationA = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
const operationB = 'ffffffff-ffff-ffff-ffff-ffffffffffff';

const payload = SetCreateIntent(
  workoutExerciseId: exerciseA,
  setNumber: 1,
  reps: 10,
  weightKg: 20,
  durationSeconds: 0,
  restSeconds: 60,
  isCompleted: true,
);

WorkoutWriteIdentity identity(String owner, String operation) =>
    WorkoutWriteIdentity(
      ownerId: owner,
      workoutId: workoutA,
      operationId: operation,
    );

final class HeldTransport implements OfflineCancellableSetCreateTransport {
  final entered = Completer<void>();
  final first = Completer<SyncSetAck>();
  int calls = 0;
  int cancellations = 0;

  @override
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent) {
    calls++;
    if (calls == 1) {
      entered.complete();
      return first.future;
    }
    return Future.value(
      SyncSetAck(
        operationId: intent.operationId,
        workoutId: intent.workoutId,
        setId: '12121212-1212-1212-1212-121212121212',
      ),
    );
  }

  @override
  void cancelInFlight() {
    cancellations++;
    if (!first.isCompleted) {
      first.completeError(StateError('Transport cancelled'));
    }
  }
}

final class SwitchOnReturnTransport
    implements OfflineCancellableSetCreateTransport {
  final SyntheticOfflineAuthSession session;
  int cancellations = 0;

  SwitchOnReturnTransport(this.session);

  @override
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent) async {
    session.changeOwner(ownerB);
    return SyncSetAck(
      operationId: intent.operationId,
      workoutId: intent.workoutId,
      setId: '12121212-1212-1212-1212-121212121212',
    );
  }

  @override
  void cancelInFlight() => cancellations++;
}

/// Acknowledges every claim it receives and counts the calls.
final class SingleAckTransport implements OfflineCancellableSetCreateTransport {
  int calls = 0;
  int cancellations = 0;

  @override
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent) async {
    calls++;
    return SyncSetAck(
      operationId: intent.operationId,
      workoutId: intent.workoutId,
      setId: '12121212-1212-1212-1212-121212121212',
    );
  }

  @override
  void cancelInFlight() => cancellations++;
}

void main() {
  test('real payload protection and production sync gates remain closed', () {
    expect(productionOfflinePayloadProtectionEnabled, isFalse);
    expect(productionOfflineSyncEnabled, isFalse);
  });

  test(
    'owner-scoped facade does not expose a raw Drift query handle',
    () async {
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final queue = OwnerScopedOfflineQueue.syntheticTest(
        NativeDatabase.memory(),
        session: session,
      );
      addTearDown(queue.close);
      expect(queue, isNot(isA<OfflineWorkoutStore>()));
      expect(
        () => (queue as dynamic).customSelect(
          'SELECT * FROM offline_write_intents',
        ),
        throwsNoSuchMethodError,
      );
    },
  );

  test(
    'owner-scoped API retains both accounts and discards only on confirmation',
    () async {
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final store = OwnerScopedOfflineQueue.syntheticTest(
        NativeDatabase.memory(),
        session: session,
      );
      addTearDown(store.close);
      await store.enqueueSetCreate(identity(ownerA, operationA), payload);
      expect(await store.pendingForOwner(ownerA), hasLength(1));
      session.changeOwner(ownerB);
      await expectLater(store.pendingForOwner(ownerA), throwsStateError);
      await expectLater(
        store.enqueueSetCreate(identity(ownerA, operationB), payload),
        throwsStateError,
      );
      await expectLater(
        store.discardPendingForOwner(ownerA, ownerConfirmed: true),
        throwsStateError,
      );
      await store.enqueueSetCreate(identity(ownerB, operationB), payload);
      expect(await store.pendingForOwner(ownerB), hasLength(1));
      session.changeOwner(null);
      await expectLater(store.pendingForOwner(ownerB), throwsStateError);
      session.changeOwner(ownerA);
      expect(await store.pendingForOwner(ownerA), hasLength(1));
      expect(
        () => store.discardPendingForOwner(ownerA, ownerConfirmed: false),
        throwsStateError,
      );
      expect(
        await store.discardPendingForOwner(ownerA, ownerConfirmed: true),
        1,
      );
      expect(await store.pendingForOwner(ownerA), isEmpty);
      expect(await store.projectedForOwner(ownerA), isEmpty);
      session.changeOwner(ownerB);
      expect(await store.pendingForOwner(ownerB), hasLength(1));
      expect(await store.projectedForOwner(ownerB), hasLength(1));
    },
  );

  test('conflict remains recoverable only by its original owner', () async {
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final store = OwnerScopedOfflineQueue.syntheticTest(
      NativeDatabase.memory(),
      session: session,
    );
    addTearDown(store.close);
    await store.enqueueSetCreate(identity(ownerA, operationA), payload);
    final now = DateTime.utc(2026, 11, 3).millisecondsSinceEpoch;
    expect(await store.claim(ownerA, workoutA, operationA, now), 1);
    expect(await store.markConflict(ownerA, workoutA, operationA, 1), isTrue);
    expect((await store.pendingForOwner(ownerA)).single.state, 'conflict');
    session.changeOwner(ownerB);
    await expectLater(store.pendingForOwner(ownerA), throwsStateError);
    await expectLater(
      store.discardPendingForOwner(ownerA, ownerConfirmed: true),
      throwsStateError,
    );
    session.changeOwner(ownerA);
    expect((await store.pendingForOwner(ownerA)).single.state, 'conflict');
    expect(await store.discardPendingForOwner(ownerA, ownerConfirmed: true), 1);
    expect(await store.pendingForOwner(ownerA), isEmpty);
  });

  test(
    'account switch cancels transport and leaves old in-flight row for owner',
    () async {
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final store = OwnerScopedOfflineQueue.syntheticTest(
        NativeDatabase.memory(),
        session: session,
      );
      addTearDown(store.close);
      await store.enqueueSetCreate(identity(ownerA, operationA), payload);
      final transport = HeldTransport();
      var now = DateTime.utc(2026, 11, 3);
      final coordinator = OfflineSyncCoordinator.syntheticOwnerScopedTest(
        store: store,
        transport: transport,
        session: session,
        clock: () => now,
      );
      final pumping = coordinator.pump(ownerId: ownerA, workoutId: workoutA);
      await transport.entered.future;
      session.changeOwner(ownerB);
      final stopped = await pumping;
      expect(stopped.stoppedBySessionChange, isTrue);
      expect(stopped.acknowledged, 0);
      expect(transport.cancellations, 1);
      expect(transport.calls, 1);
      await expectLater(
        coordinator.pump(ownerId: ownerA, workoutId: workoutA),
        throwsStateError,
      );
      session.changeOwner(ownerA);
      final retained = (await store.pendingForOwner(ownerA)).single;
      expect(retained.state, 'in_flight');
      expect(retained.attemptCount, 1);
      now = now.add(const Duration(seconds: 30));
      final recovered = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(recovered.acknowledged, 1);
      expect(transport.calls, 2);
      expect(await store.pendingForOwner(ownerA), isEmpty);
    },
  );

  test(
    'session change at transport completion cannot acknowledge old owner',
    () async {
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final store = OwnerScopedOfflineQueue.syntheticTest(
        NativeDatabase.memory(),
        session: session,
      );
      addTearDown(store.close);
      await store.enqueueSetCreate(identity(ownerA, operationA), payload);
      final transport = SwitchOnReturnTransport(session);
      final coordinator = OfflineSyncCoordinator.syntheticOwnerScopedTest(
        store: store,
        transport: transport,
        session: session,
        clock: () => DateTime.utc(2026, 11, 3),
      );
      final result = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(result.stoppedBySessionChange, isTrue);
      expect(result.acknowledged, 0);
      session.changeOwner(ownerA);
      expect((await store.pendingForOwner(ownerA)).single.state, 'in_flight');
    },
  );

  test('logout stops a running pump and rejects a later pump', () async {
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final store = OwnerScopedOfflineQueue.encrypted(
      NativeDatabase.memory(),
      session: session,
      cipher: OfflinePayloadCipher(keyStore: InMemoryOfflinePayloadKeyStore()),
    );
    addTearDown(store.close);
    await store.enqueueSetCreate(identity(ownerA, operationA), payload);
    final transport = HeldTransport();
    final coordinator = OfflineSyncCoordinator.syntheticOwnerScopedTest(
      store: store,
      transport: transport,
      session: session,
      clock: () => DateTime.utc(2026, 11, 4),
    );

    final pumping = coordinator.pump(ownerId: ownerA, workoutId: workoutA);
    await transport.entered.future;
    session.logout();
    final stopped = await pumping;

    expect(stopped.stoppedBySessionChange, isTrue);
    expect(stopped.acknowledged, 0);
    expect(stopped.conflicts, 0);
    expect(transport.calls, 1);
    expect(transport.cancellations, 1);
    expect(session.authenticatedOwnerId, isNull);
    await expectLater(
      coordinator.pump(ownerId: ownerA, workoutId: workoutA),
      throwsStateError,
    );
    expect(transport.calls, 1);
  });

  test(
    'logout preserves the encrypted pending queue instead of discarding',
    () async {
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final store = OwnerScopedOfflineQueue.encrypted(
        NativeDatabase.memory(),
        session: session,
        cipher: OfflinePayloadCipher(
          keyStore: InMemoryOfflinePayloadKeyStore(),
        ),
      );
      addTearDown(store.close);
      await store.enqueueSetCreate(
        identity(ownerA, operationA),
        payload,
        createdAtUtcMillis: 1000,
      );
      await store.enqueueSetCreate(
        identity(ownerA, operationB),
        payload,
        createdAtUtcMillis: 2000,
      );
      final before = await store.pendingForOwner(ownerA);
      expect(before, hasLength(2));
      expect(await store.projectedForOwner(ownerA), hasLength(2));

      session.logout();
      expect(session.authenticatedOwnerId, isNull);
      await expectLater(store.pendingForOwner(ownerA), throwsStateError);
      await expectLater(store.projectedForOwner(ownerA), throwsStateError);

      session.changeOwner(ownerA);
      final after = await store.pendingForOwner(ownerA);
      expect(after, hasLength(2));
      expect(
        after.map((row) => row.operationId).toList(),
        before.map((row) => row.operationId).toList(),
      );
      for (final row in after) {
        expect(row.state, 'pending');
        expect(row.attemptCount, 0);
        expect(
          row.payloadJson,
          before
              .firstWhere((prior) => prior.operationId == row.operationId)
              .payloadJson,
        );
      }
      expect(await store.projectedForOwner(ownerA), hasLength(2));
    },
  );

  test(
    'after logout another account cannot touch the prior owner queue',
    () async {
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final store = OwnerScopedOfflineQueue.encrypted(
        NativeDatabase.memory(),
        session: session,
        cipher: OfflinePayloadCipher(
          keyStore: InMemoryOfflinePayloadKeyStore(),
        ),
      );
      addTearDown(store.close);
      await store.enqueueSetCreate(
        identity(ownerA, operationA),
        payload,
        createdAtUtcMillis: 1000,
      );
      final now = DateTime.utc(2026, 11, 4).millisecondsSinceEpoch;
      final transport = SingleAckTransport();
      final coordinator = OfflineSyncCoordinator.syntheticOwnerScopedTest(
        store: store,
        transport: transport,
        session: session,
        clock: () => DateTime.utc(2026, 11, 4),
      );

      session.logout();
      session.changeOwner(ownerB);

      await expectLater(store.pendingForOwner(ownerA), throwsStateError);
      await expectLater(store.projectedForOwner(ownerA), throwsStateError);
      await expectLater(
        store.pendingForOwnerWorkout(ownerA, workoutA),
        throwsStateError,
      );
      await expectLater(
        store.claim(ownerA, workoutA, operationA, now),
        throwsStateError,
      );
      await expectLater(
        store.scheduleRetry(ownerA, workoutA, operationA, now, 1),
        throwsStateError,
      );
      await expectLater(
        store.markConflict(ownerA, workoutA, operationA, 1),
        throwsStateError,
      );
      await expectLater(
        store.releaseExpiredInFlight(ownerA, workoutA, operationA, now),
        throwsStateError,
      );
      await expectLater(
        store.acknowledge(ownerA, workoutA, operationA, 1),
        throwsStateError,
      );
      await expectLater(
        store.discardPendingForOwner(ownerA, ownerConfirmed: true),
        throwsStateError,
      );
      await expectLater(
        coordinator.pump(ownerId: ownerA, workoutId: workoutA),
        throwsStateError,
      );
      expect(transport.calls, 0);

      // Owner B's own queue works.
      await store.enqueueSetCreate(identity(ownerB, operationB), payload);
      expect(await store.pendingForOwner(ownerB), hasLength(1));
      final syncedB = await coordinator.pump(
        ownerId: ownerB,
        workoutId: workoutA,
      );
      expect(syncedB.acknowledged, 1);
      expect(transport.calls, 1);
      expect(await store.pendingForOwner(ownerB), isEmpty);

      session.changeOwner(ownerA);
      expect(await store.pendingForOwner(ownerA), hasLength(1));
      expect(
        (await store.projectedForOwner(ownerA)).single.operationId,
        operationA,
      );
    },
  );

  test(
    're-authentication recovers the retained operation and syncs it once',
    () async {
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final store = OwnerScopedOfflineQueue.encrypted(
        NativeDatabase.memory(),
        session: session,
        cipher: OfflinePayloadCipher(
          keyStore: InMemoryOfflinePayloadKeyStore(),
        ),
      );
      addTearDown(store.close);
      await store.enqueueSetCreate(identity(ownerA, operationA), payload);
      final transport = HeldTransport();
      var now = DateTime.utc(2026, 11, 4);
      final coordinator = OfflineSyncCoordinator.syntheticOwnerScopedTest(
        store: store,
        transport: transport,
        session: session,
        clock: () => now,
      );

      final pumping = coordinator.pump(ownerId: ownerA, workoutId: workoutA);
      await transport.entered.future;
      session.logout();
      expect((await pumping).stoppedBySessionChange, isTrue);

      session.changeOwner(ownerA);
      final retained = (await store.pendingForOwner(ownerA)).single;
      expect(retained.state, 'in_flight');
      expect(retained.attemptCount, 1);
      expect(retained.payloadJson, isNotNull);

      now = now.add(const Duration(seconds: 30));
      final recovered = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(recovered.acknowledged, 1);
      expect(transport.calls, 2);
      expect(await store.pendingForOwner(ownerA), isEmpty);
      expect(await store.projectedForOwner(ownerA), isEmpty);

      final replay = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(replay.acknowledged, 0);
      expect(transport.calls, 2);
    },
  );

  test('explicit discard needs confirmation and the matching owner', () async {
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final store = OwnerScopedOfflineQueue.encrypted(
      NativeDatabase.memory(),
      session: session,
      cipher: OfflinePayloadCipher(keyStore: InMemoryOfflinePayloadKeyStore()),
    );
    addTearDown(store.close);
    await store.enqueueSetCreate(identity(ownerA, operationA), payload);

    expect(
      () => store.discardPendingForOwner(ownerA, ownerConfirmed: false),
      throwsStateError,
    );
    session.logout();
    await expectLater(
      store.discardPendingForOwner(ownerA, ownerConfirmed: true),
      throwsStateError,
    );
    session.changeOwner(ownerA);
    expect(await store.pendingForOwner(ownerA), hasLength(1));

    expect(await store.discardPendingForOwner(ownerA, ownerConfirmed: true), 1);
    expect(await store.pendingForOwner(ownerA), isEmpty);
    expect(await store.projectedForOwner(ownerA), isEmpty);
  });
}
