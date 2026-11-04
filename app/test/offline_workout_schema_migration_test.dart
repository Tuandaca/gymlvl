import 'dart:convert';
import 'dart:io';

import 'package:app/features/workout/data/offline_workout_store.dart';
import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('v1 synthetic outbox migrates to v3 without losing its intent', () async {
    final directory = await Directory.systemTemp.createTemp('gymlvl-v1-test-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}legacy.sqlite',
    );
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
    final payloadJson = jsonEncode(payload.toJson());

    final oldDatabase = sqlite.sqlite3.open(file.path);
    try {
      oldDatabase.execute('''
        CREATE TABLE offline_set_projections (
          operation_id TEXT NOT NULL PRIMARY KEY,
          owner_id TEXT NOT NULL,
          workout_id TEXT NOT NULL,
          payload_json TEXT NOT NULL
        );
        CREATE TABLE offline_write_intents (
          operation_id TEXT NOT NULL PRIMARY KEY,
          owner_id TEXT NOT NULL,
          workout_id TEXT NOT NULL,
          contract_version INTEGER NOT NULL,
          mutation_kind TEXT NOT NULL,
          payload_json TEXT NOT NULL
        );
        PRAGMA user_version = 1;
      ''');
      oldDatabase.execute(
        'INSERT INTO offline_set_projections '
        '(operation_id, owner_id, workout_id, payload_json) VALUES (?, ?, ?, ?)',
        [
          identity.operationId,
          identity.ownerId,
          identity.workoutId,
          payloadJson,
        ],
      );
      oldDatabase.execute(
        'INSERT INTO offline_write_intents '
        '(operation_id, owner_id, workout_id, contract_version, '
        'mutation_kind, payload_json) VALUES (?, ?, ?, ?, ?, ?)',
        [
          identity.operationId,
          identity.ownerId,
          identity.workoutId,
          1,
          'set_create_v1',
          payloadJson,
        ],
      );
    } finally {
      oldDatabase.dispose();
    }

    final migrated = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
    final row = (await migrated.pendingForOwner(identity.ownerId)).single;
    expect(row.payloadJson, payloadJson);
    expect(row.payloadFingerprint, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(row.state, 'pending');
    expect(row.attemptCount, 0);
    expect(row.nextAttemptAtUtcMillis, isNull);
    expect(row.createdAtUtcMillis, 0);
    expect(await migrated.projectedForOwner(identity.ownerId), hasLength(1));
    await migrated.enqueueSetCreate(identity, payload);
    expect(await migrated.pendingForOwner(identity.ownerId), hasLength(1));
    await migrated.close();

    final reopenedRaw = sqlite.sqlite3.open(file.path);
    try {
      expect(
        reopenedRaw.select('PRAGMA user_version').single['user_version'],
        3,
      );
      // The legacy row keeps its plaintext payload; the envelope columns are
      // added but stay NULL so the store returns it unchanged until the caller
      // explicitly encrypts it.
      final intentRow = reopenedRaw
          .select('SELECT * FROM offline_write_intents')
          .single;
      expect(intentRow['payload_json'], payloadJson);
      expect(intentRow['payload_cipher_version'], isNull);
      expect(intentRow['payload_key_version'], isNull);
      expect(intentRow['payload_nonce'], isNull);
      expect(intentRow['payload_ciphertext'], isNull);
      final projectionRow = reopenedRaw
          .select('SELECT * FROM offline_set_projections')
          .single;
      expect(projectionRow['operation_id'], identity.operationId);
      expect(projectionRow['owner_id'], identity.ownerId);
      expect(projectionRow['workout_id'], identity.workoutId);
      expect(projectionRow['payload_json'], payloadJson);
      expect(projectionRow['payload_cipher_version'], isNull);
      expect(projectionRow['payload_key_version'], isNull);
      expect(projectionRow['payload_nonce'], isNull);
      expect(projectionRow['payload_ciphertext'], isNull);
    } finally {
      reopenedRaw.dispose();
    }
  });

  test(
    'v1 migration rejects uppercase operation ID without deleting its row',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gymlvl-v1-case-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}legacy.sqlite',
      );
      final oldDatabase = sqlite.sqlite3.open(file.path);
      try {
        oldDatabase.execute('''
        CREATE TABLE offline_set_projections (
          operation_id TEXT NOT NULL PRIMARY KEY,
          owner_id TEXT NOT NULL,
          workout_id TEXT NOT NULL,
          payload_json TEXT NOT NULL
        );
        CREATE TABLE offline_write_intents (
          operation_id TEXT NOT NULL PRIMARY KEY,
          owner_id TEXT NOT NULL,
          workout_id TEXT NOT NULL,
          contract_version INTEGER NOT NULL,
          mutation_kind TEXT NOT NULL,
          payload_json TEXT NOT NULL
        );
        PRAGMA user_version = 1;
      ''');
        oldDatabase.execute(
          'INSERT INTO offline_write_intents '
          '(operation_id, owner_id, workout_id, contract_version, '
          'mutation_kind, payload_json) VALUES (?, ?, ?, ?, ?, ?)',
          [
            'EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE',
            'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
            'cccccccc-cccc-cccc-cccc-cccccccccccc',
            1,
            'set_create_v1',
            '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd"}',
          ],
        );
      } finally {
        oldDatabase.dispose();
      }

      final migrated = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      await expectLater(
        migrated.pendingForOwner('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
        throwsFormatException,
      );
      await migrated.close();
      final preserved = sqlite.sqlite3.open(file.path);
      try {
        expect(
          preserved.select('PRAGMA user_version').single['user_version'],
          1,
        );
        expect(
          preserved
              .select('SELECT count(*) AS total FROM offline_write_intents')
              .single['total'],
          1,
        );
      } finally {
        preserved.dispose();
      }
    },
  );
}
