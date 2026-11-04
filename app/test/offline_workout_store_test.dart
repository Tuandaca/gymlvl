import 'dart:io';

import 'package:app/features/workout/data/offline_workout_store.dart';
import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final identity = WorkoutWriteIdentity(
    ownerId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    workoutId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    operationId: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
  );
  const payload = SetCreateIntent(
    workoutExerciseId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    setNumber: 1,
    reps: 10,
    weightKg: 20,
    durationSeconds: 0,
    restSeconds: 60,
    isCompleted: true,
  );

  test(
    'queues projection and intent atomically and scopes reads to owner',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);

      await store.enqueueSetCreate(identity, payload);
      await store.enqueueSetCreate(identity, payload);

      expect(
        await store.pendingForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
        hasLength(1),
      );
      expect(
        await store.projectedForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
        hasLength(1),
      );
      expect(
        await store.pendingForOwner('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
        isEmpty,
      );
      expect(
        await store.projectedForOwner('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
        isEmpty,
      );
      expect(
        (await store.pendingForOwner(
          'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        )).single.mutationKind,
        'set_create_v1',
      );
      expect(
        (await store.pendingForOwner(
          'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        )).single.contractVersion,
        1,
      );
      final queued = (await store.pendingForOwnerWorkout(
        identity.ownerId,
        identity.workoutId,
      )).single;
      expect(queued.state, 'pending');
      expect(queued.attemptCount, 0);
      expect(queued.payloadFingerprint, matches(RegExp(r'^[0-9a-f]{64}$')));
    },
  );

  test(
    'workout-scoped reads exclude another workout of the same owner',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      final other = WorkoutWriteIdentity(
        ownerId: identity.ownerId,
        workoutId: '12121212-1212-1212-1212-121212121212',
        operationId: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
      );
      await store.enqueueSetCreate(identity, payload, createdAtUtcMillis: 1000);
      await store.enqueueSetCreate(other, payload, createdAtUtcMillis: 2000);
      expect(await store.pendingForOwner(identity.ownerId), hasLength(2));
      expect(
        (await store.pendingForOwnerWorkout(
          identity.ownerId,
          identity.workoutId,
        )).single.operationId,
        identity.operationId,
      );
      expect(
        (await store.pendingForOwnerWorkout(
          other.ownerId,
          other.workoutId,
        )).single.operationId,
        other.operationId,
      );
    },
  );

  test(
    'rejects case-distinct UUIDs before enqueue and scoped transitions',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identity, payload, createdAtUtcMillis: 1000);
      final upperOperation = identity.operationId.toUpperCase();
      final upperOwner = identity.ownerId.toUpperCase();
      final upperWorkout = identity.workoutId.toUpperCase();

      await expectLater(
        store.enqueueSetCreate(
          WorkoutWriteIdentity(
            ownerId: identity.ownerId,
            workoutId: identity.workoutId,
            operationId: upperOperation,
          ),
          payload,
        ),
        throwsFormatException,
      );
      await expectLater(
        store.enqueueSetCreate(
          identity,
          SetCreateIntent(
            workoutExerciseId: payload.workoutExerciseId.toUpperCase(),
            setNumber: payload.setNumber,
            reps: payload.reps,
            weightKg: payload.weightKg,
            durationSeconds: payload.durationSeconds,
            restSeconds: payload.restSeconds,
            isCompleted: payload.isCompleted,
          ),
        ),
        throwsFormatException,
      );
      expect(() => store.pendingForOwner(upperOwner), throwsFormatException);
      expect(
        () => store.pendingForOwnerWorkout(identity.ownerId, upperWorkout),
        throwsFormatException,
      );
      expect(() => store.projectedForOwner(upperOwner), throwsFormatException);
      await expectLater(
        store.claim(identity.ownerId, identity.workoutId, upperOperation, 2000),
        throwsFormatException,
      );
      await expectLater(
        store.scheduleRetry(
          identity.ownerId,
          upperWorkout,
          identity.operationId,
          3000,
          1,
        ),
        throwsFormatException,
      );
      await expectLater(
        store.markConflict(
          upperOwner,
          identity.workoutId,
          identity.operationId,
          1,
        ),
        throwsFormatException,
      );
      await expectLater(
        store.releaseExpiredInFlight(
          identity.ownerId,
          identity.workoutId,
          upperOperation,
          32000,
        ),
        throwsFormatException,
      );
      expect(
        () => store.acknowledge(
          identity.ownerId,
          upperWorkout,
          identity.operationId,
          1,
        ),
        throwsFormatException,
      );
      expect(await store.pendingForOwner(identity.ownerId), hasLength(1));
      expect(await store.projectedForOwner(identity.ownerId), hasLength(1));
    },
  );

  test(
    'operation ID cannot be reused with different content or owner',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identity, payload);

      await expectLater(
        store.enqueueSetCreate(
          identity,
          const SetCreateIntent(
            workoutExerciseId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
            setNumber: 1,
            reps: 11,
            weightKg: 20,
            durationSeconds: 0,
            restSeconds: 60,
            isCompleted: true,
          ),
        ),
        throwsStateError,
      );
      await expectLater(
        store.enqueueSetCreate(
          WorkoutWriteIdentity(
            ownerId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
            workoutId: '12121212-1212-1212-1212-121212121212',
            operationId: identity.operationId,
          ),
          payload,
        ),
        throwsStateError,
      );
      expect(
        await store.pendingForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
        hasLength(1),
      );
      expect(
        await store.projectedForOwner('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
        isEmpty,
      );
    },
  );

  test('rejects invalid payload before either table changes', () async {
    final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
    addTearDown(store.close);
    await expectLater(
      store.enqueueSetCreate(
        WorkoutWriteIdentity(
          ownerId: 'not-a-uuid',
          workoutId: identity.workoutId,
          operationId: identity.operationId,
        ),
        payload,
      ),
      throwsFormatException,
    );
    await expectLater(
      store.enqueueSetCreate(
        identity,
        const SetCreateIntent(
          workoutExerciseId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
          setNumber: 1,
          reps: 0,
          weightKg: 20,
          durationSeconds: 0,
          restSeconds: 60,
          isCompleted: true,
        ),
      ),
      throwsFormatException,
    );
    expect(
      await store.pendingForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
      isEmpty,
    );
    expect(
      await store.projectedForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
      isEmpty,
    );
  });

  test(
    'claim, retry, conflict and ACK transitions retain one fingerprint',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identity, payload, createdAtUtcMillis: 1000);
      final fingerprint = (await store.pendingForOwner(
        identity.ownerId,
      )).single.payloadFingerprint;

      expect(
        await store.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          2000,
        ),
        1,
      );
      expect(
        await store.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          2000,
        ),
        isNull,
      );
      var row = (await store.pendingForOwnerWorkout(
        identity.ownerId,
        identity.workoutId,
      )).single;
      expect(row.state, 'in_flight');
      expect(row.attemptCount, 1);
      expect(row.nextAttemptAtUtcMillis, 32000);
      expect(
        await store.scheduleRetry(
          'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
          identity.workoutId,
          identity.operationId,
          4000,
          1,
        ),
        isFalse,
      );
      expect(
        await store.scheduleRetry(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          4000,
          1,
        ),
        isTrue,
      );
      expect(
        await store.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          3999,
        ),
        isNull,
      );
      expect(
        await store.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          4000,
        ),
        2,
      );
      row = (await store.pendingForOwnerWorkout(
        identity.ownerId,
        identity.workoutId,
      )).single;
      expect(row.attemptCount, 2);
      expect(row.payloadFingerprint, fingerprint);
      expect(
        await store.markConflict(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          1,
        ),
        isFalse,
      );
      expect(
        await store.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          50000,
        ),
        isNull,
      );
      expect(
        await store.acknowledge(
          identity.ownerId,
          '12121212-1212-1212-1212-121212121212',
          identity.operationId,
          2,
        ),
        isFalse,
      );
      expect(await store.pendingForOwner(identity.ownerId), hasLength(1));
      expect(
        await store.acknowledge(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          1,
        ),
        isFalse,
      );
      expect(
        await store.acknowledge(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          2,
        ),
        isTrue,
      );
      expect(await store.pendingForOwner(identity.ownerId), isEmpty);
      expect(await store.projectedForOwner(identity.ownerId), isEmpty);
    },
  );

  test(
    'conflict is terminal and cannot be acknowledged without a claim',
    () async {
      final store = OfflineWorkoutStore.syntheticTest(NativeDatabase.memory());
      addTearDown(store.close);
      await store.enqueueSetCreate(identity, payload, createdAtUtcMillis: 1000);
      expect(
        await store.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          2000,
        ),
        1,
      );
      expect(
        await store.markConflict(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          1,
        ),
        isTrue,
      );
      final row = (await store.pendingForOwner(identity.ownerId)).single;
      expect(row.state, 'conflict');
      expect(row.nextAttemptAtUtcMillis, isNull);
      expect(
        await store.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          100000,
        ),
        isNull,
      );
      expect(
        await store.acknowledge(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          1,
        ),
        isFalse,
      );
      expect(await store.projectedForOwner(identity.ownerId), hasLength(1));
    },
  );

  test('two SQLite connections cannot claim one operation twice', () async {
    final directory = await Directory.systemTemp.createTemp(
      'gymlvl-claim-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}workout.sqlite',
    );
    final first = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
    final second = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
    addTearDown(first.close);
    addTearDown(second.close);
    await first.enqueueSetCreate(identity, payload, createdAtUtcMillis: 1000);

    final claims = await Future.wait([
      first.claim(
        identity.ownerId,
        identity.workoutId,
        identity.operationId,
        2000,
      ),
      second.claim(
        identity.ownerId,
        identity.workoutId,
        identity.operationId,
        2000,
      ),
    ]);
    expect(claims.where((token) => token == 1), hasLength(1));
    expect(claims.where((token) => token == null), hasLength(1));
    final row = (await first.pendingForOwner(identity.ownerId)).single;
    expect(row.state, 'in_flight');
    expect(row.attemptCount, 1);
    expect(await first.projectedForOwner(identity.ownerId), hasLength(1));
  });

  test(
    'restart preserves in-flight lease and safely reclaims it after expiry',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gymlvl-lease-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}workout.sqlite',
      );
      final first = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      await first.enqueueSetCreate(identity, payload, createdAtUtcMillis: 1000);
      expect(
        await first.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          2000,
        ),
        1,
      );
      final fingerprint = (await first.pendingForOwner(
        identity.ownerId,
      )).single.payloadFingerprint;
      await first.close();

      final reopened = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      addTearDown(reopened.close);
      expect(
        await reopened.releaseExpiredInFlight(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          31999,
        ),
        isFalse,
      );
      expect(
        await reopened.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          31999,
        ),
        isNull,
      );
      expect(
        await reopened.releaseExpiredInFlight(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          32000,
        ),
        isTrue,
      );
      expect(
        await reopened.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          32000,
        ),
        2,
      );
      final row = (await reopened.pendingForOwner(identity.ownerId)).single;
      expect(row.attemptCount, 2);
      expect(row.payloadFingerprint, fingerprint);
      expect(
        await reopened.scheduleRetry(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          40000,
          1,
        ),
        isFalse,
      );
      expect(await reopened.projectedForOwner(identity.ownerId), hasLength(1));
    },
  );

  test(
    'unacknowledged synthetic intent survives reopening SQLite file',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gymlvl-offline-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}workout.sqlite',
      );
      final first = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      await first.enqueueSetCreate(identity, payload, createdAtUtcMillis: 1000);
      await first.close();

      final reopened = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      addTearDown(reopened.close);
      expect(
        await reopened.pendingForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
        hasLength(1),
      );
      expect(
        await reopened.projectedForOwner(
          'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        ),
        hasLength(1),
      );
      expect(
        await reopened.claim(
          identity.ownerId,
          identity.workoutId,
          identity.operationId,
          2000,
        ),
        1,
      );
      expect(
        await reopened.acknowledge(
          'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
          identity.workoutId,
          identity.operationId,
          1,
        ),
        isFalse,
      );
      expect(
        await reopened.pendingForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
        hasLength(1),
      );
      expect(
        await reopened.acknowledge(
          'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
          identity.workoutId,
          identity.operationId,
          1,
        ),
        isTrue,
      );
      expect(
        await reopened.pendingForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
        isEmpty,
      );
      expect(
        await reopened.projectedForOwner(
          'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        ),
        isEmpty,
      );
    },
  );
}
