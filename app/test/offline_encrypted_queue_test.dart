import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/features/workout/data/offline_payload_cipher.dart';
import 'package:app/features/workout/data/offline_secure_key_store.dart';
import 'package:app/features/workout/data/offline_security_session.dart';
import 'package:app/features/workout/data/offline_sync_coordinator.dart';
import 'package:app/features/workout/data/offline_workout_store.dart';
import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

const ownerA = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const ownerB = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const workoutA = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const exerciseA = 'dddddddd-dddd-dddd-dddd-dddddddddddd';
const operationA = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
const operationB = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
const setIdA = '12121212-1212-1212-1212-121212121212';

/// A deliberately distinctive payload so a plaintext leak is unmistakable.
const markedPayload = SetCreateIntent(
  workoutExerciseId: exerciseA,
  setNumber: 3,
  reps: 987,
  weightKg: 123.5,
  durationSeconds: 0,
  restSeconds: 654,
  isCompleted: true,
);

final markedPayloadJson = jsonEncode(markedPayload.toJson());

WorkoutWriteIdentity identity(String operationId, {String ownerId = ownerA}) =>
    WorkoutWriteIdentity(
      ownerId: ownerId,
      workoutId: workoutA,
      operationId: operationId,
    );

/// Transport that fails the test if a claim ever reaches it.
final class ForbiddenTransport implements OfflineCancellableSetCreateTransport {
  int calls = 0;

  @override
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent) {
    calls++;
    throw StateError('Transport must not be called');
  }

  @override
  void cancelInFlight() {}
}

/// Single-shot transport that acknowledges the operation it receives.
final class AckTransport implements OfflineCancellableSetCreateTransport {
  int calls = 0;
  int cancellations = 0;

  @override
  Future<SyncSetAck> applySetCreate(OfflineWriteIntent intent) async {
    calls++;
    return SyncSetAck(
      operationId: intent.operationId,
      workoutId: intent.workoutId,
      setId: setIdA,
    );
  }

  @override
  void cancelInFlight() => cancellations++;
}

/// Flattens a raw row so a plaintext substring search covers every column.
String flattenRow(Map<String, Object?> row) {
  final buffer = StringBuffer();
  for (final value in row.values) {
    if (value is List<int>) {
      buffer
        ..write(String.fromCharCodes(value))
        ..write('|')
        ..write(base64Encode(value));
    } else {
      buffer.write(value);
    }
    buffer.write('#');
  }
  return buffer.toString();
}

Future<List<Map<String, Object?>>> rawRows(
  OfflineWorkoutStore raw,
  String sql,
) async => [for (final row in await raw.customSelect(sql).get()) row.data];

Future<void> expectNoStoredPlaintext(OfflineWorkoutStore raw) async {
  for (final table in ['offline_write_intents', 'offline_set_projections']) {
    final rows = await rawRows(raw, 'SELECT * FROM $table');
    for (final row in rows) {
      final flattened = flattenRow(row);
      expect(flattened, isNot(contains(markedPayloadJson)), reason: table);
      expect(flattened, isNot(contains('"reps":987')), reason: table);
      expect(row['payload_json'], isNull, reason: table);
    }
  }
}

Future<File> temporaryDatabase(String name) async {
  final directory = await Directory.systemTemp.createTemp('gymlvl-$name-');
  addTearDown(() => directory.delete(recursive: true));
  return File('${directory.path}${Platform.pathSeparator}$name.sqlite');
}

void main() {
  test('encrypted enqueue stores no plaintext in either table', () async {
    final file = await temporaryDatabase('encrypted-write');
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final queue = OwnerScopedOfflineQueue.encrypted(
      NativeDatabase(file),
      session: session,
      cipher: OfflinePayloadCipher(keyStore: InMemoryOfflinePayloadKeyStore()),
    );
    addTearDown(queue.close);

    await queue.enqueueSetCreate(
      identity(operationA),
      markedPayload,
      createdAtUtcMillis: 1000,
    );

    final raw = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
    addTearDown(raw.close);
    final intents = await rawRows(
      raw,
      'SELECT payload_json, payload_ciphertext, payload_nonce, '
      'payload_cipher_version, payload_key_version FROM offline_write_intents',
    );
    expect(intents, hasLength(1));
    expect(intents.single['payload_json'], isNull);
    expect(intents.single['payload_ciphertext'], isA<Uint8List>());
    expect((intents.single['payload_ciphertext']! as Uint8List), isNotEmpty);
    expect(intents.single['payload_nonce'], isA<Uint8List>());
    expect(
      (intents.single['payload_nonce']! as Uint8List),
      hasLength(OfflinePayloadEnvelope.nonceLength),
    );
    expect(intents.single['payload_cipher_version'], 1);
    expect(intents.single['payload_key_version'], 1);
    final projections = await rawRows(
      raw,
      'SELECT payload_json, payload_ciphertext FROM offline_set_projections',
    );
    expect(projections, hasLength(1));
    expect(projections.single['payload_json'], isNull);
    expect(projections.single['payload_ciphertext'], isA<Uint8List>());
    await expectNoStoredPlaintext(raw);
  });

  test('pending read decrypts the payload for its owner only', () async {
    final file = await temporaryDatabase('encrypted-read');
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final queue = OwnerScopedOfflineQueue.encrypted(
      NativeDatabase(file),
      session: session,
      cipher: OfflinePayloadCipher(keyStore: InMemoryOfflinePayloadKeyStore()),
    );
    addTearDown(queue.close);
    await queue.enqueueSetCreate(identity(operationA), markedPayload);

    final pending = await queue.pendingForOwnerWorkout(ownerA, workoutA);
    expect(pending, hasLength(1));
    expect(pending.single.payloadJson, markedPayloadJson);
    expect(pending.single.operationId, operationA);
    final projections = await queue.projectedForOwner(ownerA);
    expect(projections, hasLength(1));
    expect(projections.single.payloadJson, markedPayloadJson);

    await expectLater(
      queue.pendingForOwnerWorkout(ownerB, workoutA),
      throwsStateError,
    );

    final raw = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
    addTearDown(raw.close);
    await expectNoStoredPlaintext(raw);
  });

  test('a deleted owner key fails closed and retains the row', () async {
    final file = await temporaryDatabase('encrypted-missing-key');
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final keyStore = InMemoryOfflinePayloadKeyStore();
    final queue = OwnerScopedOfflineQueue.encrypted(
      NativeDatabase(file),
      session: session,
      cipher: OfflinePayloadCipher(keyStore: keyStore),
    );
    addTearDown(queue.close);
    await queue.enqueueSetCreate(identity(operationA), markedPayload);

    expect(await keyStore.deleteKeyForOwner(ownerA, 1), isTrue);

    await expectLater(
      queue.pendingForOwnerWorkout(ownerA, workoutA),
      throwsA(isA<OfflinePayloadKeyUnavailableException>()),
    );
    await expectLater(
      queue.pendingForOwner(ownerA),
      throwsA(isA<OfflinePayloadKeyUnavailableException>()),
    );

    final raw = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
    addTearDown(raw.close);
    final rows = await rawRows(
      raw,
      'SELECT payload_json, payload_ciphertext, state, attempt_count '
      'FROM offline_write_intents',
    );
    expect(rows, hasLength(1));
    expect(rows.single['payload_json'], isNull);
    expect(rows.single['payload_ciphertext'], isA<Uint8List>());
    expect(rows.single['state'], 'pending');
    expect(rows.single['attempt_count'], 0);
    await expectNoStoredPlaintext(raw);
  });

  test(
    'tampered ciphertext fails the pump without acking or deleting',
    () async {
      final file = await temporaryDatabase('encrypted-tamper');
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final queue = OwnerScopedOfflineQueue.encrypted(
        NativeDatabase(file),
        session: session,
        cipher: OfflinePayloadCipher(
          keyStore: InMemoryOfflinePayloadKeyStore(),
        ),
      );
      addTearDown(queue.close);
      await queue.enqueueSetCreate(identity(operationA), markedPayload);

      final raw = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      addTearDown(raw.close);
      final stored = await rawRows(
        raw,
        'SELECT payload_ciphertext FROM offline_write_intents',
      );
      final original = Uint8List.fromList(
        stored.single['payload_ciphertext']! as Uint8List,
      );
      final tampered = Uint8List.fromList(original);
      tampered[0] = tampered[0] ^ 0xff;
      await raw.customStatement(
        'UPDATE offline_write_intents SET payload_ciphertext = ? '
        'WHERE operation_id = ?',
        [tampered, operationA],
      );

      final transport = ForbiddenTransport();
      final coordinator = OfflineSyncCoordinator.syntheticOwnerScopedTest(
        store: queue,
        transport: transport,
        session: session,
        clock: () => DateTime.utc(2026, 11, 4),
      );
      await expectLater(
        coordinator.pump(ownerId: ownerA, workoutId: workoutA),
        throwsA(isA<OfflinePayloadAuthenticationException>()),
      );
      expect(transport.calls, 0);

      final retained = await rawRows(
        raw,
        'SELECT state, attempt_count, payload_json, payload_ciphertext '
        'FROM offline_write_intents',
      );
      expect(retained, hasLength(1));
      expect(retained.single['state'], 'pending');
      expect(retained.single['attempt_count'], 0);
      expect(retained.single['payload_json'], isNull);
      expect(retained.single['payload_ciphertext'], tampered);

      // The projection of the same operation is untouched as well.
      final projections = await rawRows(
        raw,
        'SELECT count(*) AS total FROM offline_set_projections',
      );
      expect(projections.single['total'], 1);
    },
  );

  test(
    'a v2 database migrates to v3 and encrypts its legacy rows on demand',
    () async {
      final file = await temporaryDatabase('encrypted-migrate');
      final legacy = sqlite.sqlite3.open(file.path);
      try {
        legacy.execute('''
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
          payload_json TEXT NOT NULL,
          payload_fingerprint TEXT NOT NULL DEFAULT '',
          state TEXT NOT NULL DEFAULT 'pending',
          attempt_count INTEGER NOT NULL DEFAULT 0,
          next_attempt_at_utc_millis INTEGER,
          created_at_utc_millis INTEGER NOT NULL DEFAULT 0
        );
        PRAGMA user_version = 2;
      ''');
        legacy.execute(
          'INSERT INTO offline_set_projections '
          '(operation_id, owner_id, workout_id, payload_json) VALUES (?, ?, ?, ?)',
          [operationA, ownerA, workoutA, markedPayloadJson],
        );
        legacy.execute(
          'INSERT INTO offline_write_intents (operation_id, owner_id, '
          'workout_id, contract_version, mutation_kind, payload_json, '
          'payload_fingerprint, state, attempt_count, created_at_utc_millis) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            operationA,
            ownerA,
            workoutA,
            1,
            'set_create_v1',
            markedPayloadJson,
            List.filled(64, 'a').join(),
            'pending',
            0,
            1000,
          ],
        );
      } finally {
        legacy.dispose();
      }

      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final queue = OwnerScopedOfflineQueue.encrypted(
        NativeDatabase(file),
        session: session,
        cipher: OfflinePayloadCipher(
          keyStore: InMemoryOfflinePayloadKeyStore(),
        ),
      );

      // The migrated row survives and is still readable through the queue.
      final before = await queue.pendingForOwnerWorkout(ownerA, workoutA);
      expect(before, hasLength(1));
      expect(before.single.payloadJson, markedPayloadJson);
      expect(before.single.attemptCount, 0);
      expect(await queue.projectedForOwner(ownerA), hasLength(1));

      final raw = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      addTearDown(raw.close);
      final migrationVersion = await rawRows(raw, 'PRAGMA user_version');
      expect(migrationVersion.single['user_version'], 3);

      expect(await queue.encryptLegacyRowsForOwner(ownerA), 1);
      final encryptedIntents = await rawRows(
        raw,
        'SELECT payload_json, payload_ciphertext FROM offline_write_intents',
      );
      expect(encryptedIntents.single['payload_json'], isNull);
      expect(encryptedIntents.single['payload_ciphertext'], isA<Uint8List>());
      final encryptedProjections = await rawRows(
        raw,
        'SELECT payload_json, payload_ciphertext FROM offline_set_projections',
      );
      expect(encryptedProjections.single['payload_json'], isNull);
      expect(
        encryptedProjections.single['payload_ciphertext'],
        isA<Uint8List>(),
      );
      await expectNoStoredPlaintext(raw);

      // Still readable, now through the key store.
      final after = await queue.pendingForOwnerWorkout(ownerA, workoutA);
      expect(after.single.payloadJson, markedPayloadJson);
      expect(after.single.operationId, operationA);
      await queue.close();
    },
  );

  test('legacy encryption is owner-checked and idempotent', () async {
    final file = await temporaryDatabase('encrypted-owner-check');
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final encrypted = OwnerScopedOfflineQueue.encrypted(
      NativeDatabase(file),
      session: session,
      cipher: OfflinePayloadCipher(keyStore: InMemoryOfflinePayloadKeyStore()),
    );
    addTearDown(encrypted.close);
    await encrypted.enqueueSetCreate(identity(operationA), markedPayload);
    expect(await encrypted.encryptLegacyRowsForOwner(ownerA), 0);

    await expectLater(
      encrypted.encryptLegacyRowsForOwner(ownerB),
      throwsStateError,
    );
    session.logout();
    await expectLater(
      encrypted.encryptLegacyRowsForOwner(ownerA),
      throwsStateError,
    );
  });

  test('whole-queue transitions still work over encrypted rows', () async {
    final file = await temporaryDatabase('encrypted-transitions');
    final session = SyntheticOfflineAuthSession(ownerA);
    addTearDown(session.close);
    final queue = OwnerScopedOfflineQueue.encrypted(
      NativeDatabase(file),
      session: session,
      cipher: OfflinePayloadCipher(keyStore: InMemoryOfflinePayloadKeyStore()),
    );
    addTearDown(queue.close);
    await queue.enqueueSetCreate(
      identity(operationA),
      markedPayload,
      createdAtUtcMillis: 1000,
    );
    await queue.enqueueSetCreate(
      identity(operationB),
      markedPayload,
      createdAtUtcMillis: 2000,
    );

    expect(await queue.claim(ownerA, workoutA, operationA, 3000), 1);
    expect(
      await queue.scheduleRetry(ownerA, workoutA, operationA, 4000, 1),
      isTrue,
    );
    expect(await queue.claim(ownerA, workoutA, operationA, 4000), 2);
    expect(await queue.markConflict(ownerA, workoutA, operationA, 2), isTrue);
    final conflict = (await queue.pendingForOwner(
      ownerA,
    )).firstWhere((row) => row.operationId == operationA);
    expect(conflict.state, 'conflict');

    final transport = AckTransport();
    final coordinator = OfflineSyncCoordinator.syntheticOwnerScopedTest(
      store: queue,
      transport: transport,
      session: session,
      clock: () => DateTime.utc(2026, 11, 4),
    );
    // The conflict blocks the head of the queue, exactly as with plaintext rows.
    final blocked = await coordinator.pump(
      ownerId: ownerA,
      workoutId: workoutA,
    );
    expect(blocked.acknowledged, 0);
    expect(transport.calls, 0);

    expect(await queue.discardPendingForOwner(ownerA, ownerConfirmed: true), 2);
    expect(await queue.pendingForOwner(ownerA), isEmpty);
    expect(await queue.projectedForOwner(ownerA), isEmpty);

    final raw = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
    addTearDown(raw.close);
    expect(
      (await rawRows(
        raw,
        'SELECT count(*) AS total FROM offline_write_intents',
      )).single['total'],
      0,
    );
  });

  test(
    'encrypted writes stay free of plaintext across the whole suite',
    () async {
      final file = await temporaryDatabase('encrypted-suite');
      final session = SyntheticOfflineAuthSession(ownerA);
      addTearDown(session.close);
      final queue = OwnerScopedOfflineQueue.encrypted(
        NativeDatabase(file),
        session: session,
        cipher: OfflinePayloadCipher(
          keyStore: InMemoryOfflinePayloadKeyStore(),
        ),
      );
      addTearDown(queue.close);
      final raw = OfflineWorkoutStore.syntheticTest(NativeDatabase(file));
      addTearDown(raw.close);

      await queue.enqueueSetCreate(
        identity(operationA),
        markedPayload,
        createdAtUtcMillis: 1000,
      );
      await expectNoStoredPlaintext(raw);
      await queue.claim(ownerA, workoutA, operationA, 2000);
      await expectNoStoredPlaintext(raw);
      await queue.acknowledge(ownerA, workoutA, operationA, 1);
      await expectNoStoredPlaintext(raw);
      await queue.enqueueSetCreate(
        identity(operationB),
        markedPayload,
        createdAtUtcMillis: 3000,
      );
      await expectNoStoredPlaintext(raw);
      await queue.enqueueSetCreate(
        identity(operationB),
        markedPayload,
        createdAtUtcMillis: 3000,
      );
      await expectNoStoredPlaintext(raw);
    },
  );
}
