import 'dart:async';
import 'dart:io';

import 'package:app/features/workout/data/offline_sync_coordinator.dart';
import 'package:app/features/workout/data/offline_security_session.dart';
import 'package:app/features/workout/data/offline_workout_store.dart';
import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const ownerA = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const ownerB = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const workoutA = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const operationA = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
const setA = 'ffffffff-ffff-ffff-ffff-ffffffffffff';

final identityA = WorkoutWriteIdentity(
  ownerId: ownerA,
  workoutId: workoutA,
  operationId: operationA,
);
const payloadA = SetCreateIntent(
  workoutExerciseId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
  setNumber: 1,
  reps: 10,
  weightKg: 20,
  durationSeconds: 0,
  restSeconds: 60,
  isCompleted: true,
);

final class SyntheticServer implements OfflineCancellableSetCreateTransport {
  final Map<String, String> _ledgerPayloads = {};
  final Map<String, SyncSetAck> _ledgerResults = {};
  int calls = 0;
  int businessEffects = 0;
  bool loseNextAck = false;
  bool reject = false;
  bool corruptAck = false;
  Completer<void>? entered;
  Completer<void>? hold;
  int cancellations = 0;

  @override
  void cancelInFlight() {
    cancellations++;
  }

  @override
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent) async {
    calls++;
    if (entered != null && !entered!.isCompleted) entered!.complete();
    if (hold != null) await hold!.future;
    if (reject) throw const SyncTerminalFailure('Synthetic ownership conflict');

    final encoded = intent.payloadJson;
    if (encoded == null) {
      throw StateError('Synthetic intent has no payload');
    }
    final prior = _ledgerPayloads[intent.operationId];
    if (prior != null && prior != encoded) {
      throw const SyncTerminalFailure('Operation ID payload conflict');
    }
    if (prior == null) {
      _ledgerPayloads[intent.operationId] = encoded;
      _ledgerResults[intent.operationId] = SyncSetAck(
        operationId: intent.operationId,
        workoutId: intent.workoutId,
        setId: setA,
      );
      businessEffects++;
    }
    if (loseNextAck) {
      loseNextAck = false;
      throw StateError('Synthetic response lost after commit');
    }
    if (corruptAck) {
      return SyncSetAck(
        operationId: operationA,
        workoutId: '12121212-1212-1212-1212-121212121212',
        setId: setA,
      );
    }
    return _ledgerResults[intent.operationId]!;
  }
}

final class LeaseExpiryTransport implements OfflineSetCreateTransport {
  final firstStarted = Completer<void>();
  final releaseFirst = Completer<void>();
  int calls = 0;

  @override
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent) async {
    calls++;
    if (calls == 1) {
      firstStarted.complete();
      await releaseFirst.future;
      throw StateError('Stale first worker lost its response');
    }
    return SyncSetAck(
      operationId: intent.operationId,
      workoutId: intent.workoutId,
      setId: setA,
    );
  }
}

void main() {
  test('production gate remains closed', () {
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final store = OwnerScopedOfflineQueue.syntheticTest(
      NativeDatabase.memory(),
      session: session,
    );
    addTearDown(store.close);
    expect(productionOfflineSyncEnabled, isFalse);
    expect(
      () => OfflineSyncCoordinator.production(
        store: store,
        transport: SyntheticServer(),
        clock: DateTime.now,
        session: session,
      ),
      throwsStateError,
    );
  });

  test('backoff is bounded and rejects invalid attempt count', () {
    expect(SyncRetryPolicy.delayAfterAttempt(1), const Duration(seconds: 1));
    expect(SyncRetryPolicy.delayAfterAttempt(2), const Duration(seconds: 2));
    expect(SyncRetryPolicy.delayAfterAttempt(7), const Duration(seconds: 60));
    expect(SyncRetryPolicy.delayAfterAttempt(100), const Duration(seconds: 60));
    expect(() => SyncRetryPolicy.delayAfterAttempt(0), throwsArgumentError);
  });

  test(
    'successful ACK removes only the owner-bound synthetic operation',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identityA, payloadA);
      final server = SyntheticServer();
      final coordinator = OfflineSyncCoordinator.syntheticTest(
        store: store,
        transport: server,
        clock: () => DateTime.utc(2026, 11, 3),
      );

      final foreign = await coordinator.pump(
        ownerId: ownerB,
        workoutId: workoutA,
      );
      expect(foreign.acknowledged, 0);
      expect(server.calls, 0);
      expect(await store.pendingForOwner(ownerA), hasLength(1));

      final own = await coordinator.pump(ownerId: ownerA, workoutId: workoutA);
      expect(own.acknowledged, 1);
      expect(server.businessEffects, 1);
      expect(await store.pendingForOwner(ownerA), isEmpty);
      expect(await store.projectedForOwner(ownerA), isEmpty);
    },
  );

  test(
    'lost ACK retries the same operation after backoff without another effect',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identityA, payloadA);
      final server = SyntheticServer()..loseNextAck = true;
      var now = DateTime.utc(2026, 11, 3);
      final coordinator = OfflineSyncCoordinator.syntheticTest(
        store: store,
        transport: server,
        clock: () => now,
      );

      final first = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(first.scheduledForRetry, 1);
      expect(server.businessEffects, 1);
      final pending = (await store.pendingForOwner(ownerA)).single;
      expect(pending.operationId, operationA);
      expect(pending.state, 'retry_scheduled');
      expect(pending.attemptCount, 1);

      final early = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(early.acknowledged, 0);
      expect(server.calls, 1);
      now = now.add(const Duration(seconds: 1));
      final replay = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(replay.acknowledged, 1);
      expect(server.calls, 2);
      expect(server.businessEffects, 1);
      expect(await store.pendingForOwner(ownerA), isEmpty);
    },
  );

  test(
    'local acknowledgement invariant failure is surfaced without retry',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identityA, payloadA);
      await store.customStatement(
        'DELETE FROM offline_set_projections WHERE operation_id = ?',
        [operationA],
      );
      final server = SyntheticServer();
      var now = DateTime.utc(2026, 11, 3);
      final coordinator = OfflineSyncCoordinator.syntheticTest(
        store: store,
        transport: server,
        clock: () => now,
      );

      await expectLater(
        coordinator.pump(ownerId: ownerA, workoutId: workoutA),
        throwsStateError,
      );
      expect(server.businessEffects, 1);
      expect(server.calls, 1);
      final intent = (await store.pendingForOwner(ownerA)).single;
      expect(intent.state, 'conflict');
      expect(intent.attemptCount, 1);
      now = now.add(const Duration(minutes: 1));
      expect(
        (await coordinator.pump(
          ownerId: ownerA,
          workoutId: workoutA,
        )).scheduledForRetry,
        0,
      );
      expect(server.calls, 1);
    },
  );

  test(
    'stale in-flight operation recovers after SQLite restart and lease expiry',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gymlvl-sync-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}sync.sqlite',
      );
      final now = DateTime.utc(2026, 11, 3);
      final first = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      await first.enqueueSetCreate(identityA, payloadA);
      expect(
        await first.claim(
          ownerA,
          workoutA,
          operationA,
          now.millisecondsSinceEpoch,
        ),
        1,
      );
      await first.close();

      final reopened = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      addTearDown(reopened.close);
      final server = SyntheticServer();
      var clock = now.add(const Duration(seconds: 29));
      final coordinator = OfflineSyncCoordinator.syntheticTest(
        store: reopened,
        transport: server,
        clock: () => clock,
      );
      final early = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(early.acknowledged, 0);
      expect(server.calls, 0);

      clock = now.add(const Duration(seconds: 30));
      final recovered = await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      );
      expect(recovered.acknowledged, 1);
      expect(server.businessEffects, 1);
      expect(await reopened.pendingForOwner(ownerA), isEmpty);
    },
  );

  test(
    'two coordinators cannot claim the same live operation concurrently',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identityA, payloadA);
      final server = SyntheticServer()
        ..entered = Completer<void>()
        ..hold = Completer<void>();
      DateTime clock() => DateTime.utc(2026, 11, 3);
      final first = OfflineSyncCoordinator.syntheticTest(
        store: store,
        transport: server,
        clock: clock,
      );
      final second = OfflineSyncCoordinator.syntheticTest(
        store: store,
        transport: server,
        clock: clock,
      );
      final firstRun = first.pump(ownerId: ownerA, workoutId: workoutA);
      await server.entered!.future;
      final secondRun = await second.pump(ownerId: ownerA, workoutId: workoutA);
      expect(secondRun.acknowledged, 0);
      expect(server.calls, 1);
      server.hold!.complete();
      expect((await firstRun).acknowledged, 1);
      expect(server.businessEffects, 1);
    },
  );

  test(
    'expired first worker cannot overwrite a newer acknowledgement',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identityA, payloadA);
      final server = LeaseExpiryTransport();
      var now = DateTime.utc(2026, 11, 3);
      final first = OfflineSyncCoordinator.syntheticTest(
        store: store,
        transport: server,
        clock: () => now,
      );
      final second = OfflineSyncCoordinator.syntheticTest(
        store: store,
        transport: server,
        clock: () => now,
      );

      final staleRun = first.pump(ownerId: ownerA, workoutId: workoutA);
      await server.firstStarted.future;
      now = now.add(const Duration(seconds: 30));
      final freshRun = await second.pump(ownerId: ownerA, workoutId: workoutA);
      expect(freshRun.acknowledged, 1);
      server.releaseFirst.complete();
      final staleResult = await staleRun;
      expect(staleResult.scheduledForRetry, 0);
      expect(server.calls, 2);
      expect(await store.pendingForOwner(ownerA), isEmpty);
    },
  );

  test('terminal error and mismatched ACK quarantine the intent', () async {
    final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
    addTearDown(store.close);
    await store.enqueueSetCreate(identityA, payloadA);
    final server = SyntheticServer()..reject = true;
    final coordinator = OfflineSyncCoordinator.syntheticTest(
      store: store,
      transport: server,
      clock: () => DateTime.utc(2026, 11, 3),
    );
    final rejected = await coordinator.pump(
      ownerId: ownerA,
      workoutId: workoutA,
    );
    expect(rejected.conflicts, 1);
    expect((await store.pendingForOwner(ownerA)).single.state, 'conflict');
    expect(
      (await coordinator.pump(
        ownerId: ownerA,
        workoutId: workoutA,
      )).acknowledged,
      0,
    );
    expect(server.calls, 1);

    await store.close();
    final otherStore = OfflineWorkoutStore.syntheticTest(
      NativeDatabase.memory(),
    );
    addTearDown(otherStore.close);
    await otherStore.enqueueSetCreate(identityA, payloadA);
    final wrongAck = OfflineSyncCoordinator.syntheticTest(
      store: otherStore,
      transport: SyntheticServer()..corruptAck = true,
      clock: () => DateTime.utc(2026, 11, 3),
    );
    expect(
      (await wrongAck.pump(ownerId: ownerA, workoutId: workoutA)).conflicts,
      1,
    );
    expect((await otherStore.pendingForOwner(ownerA)).single.state, 'conflict');
  });
}
