import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import 'offline_payload_cipher.dart';
import 'offline_security_session.dart';
import '../domain/workout_write_identity.dart';

part 'offline_workout_store.g.dart';

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

void _requireCanonicalUuid(String value, String field) {
  if (!_uuidPattern.hasMatch(value)) {
    throw FormatException('$field must be a canonical lowercase UUID');
  }
}

/// A synthetic-only foundation. No production code opens this database yet.
///
/// Payload invariant, enforced by code and by raw-SQL tests:
/// - an encrypted row sets all four `payload*` envelope columns and leaves
///   `payload_json` NULL;
/// - a legacy plaintext row sets `payload_json` and leaves every envelope
///   column NULL;
/// - plaintext and ciphertext never coexist in one row.
class OfflineSetProjections extends Table {
  TextColumn get operationId => text()();
  TextColumn get ownerId => text()();
  TextColumn get workoutId => text()();
  TextColumn get payloadJson => text().nullable()();
  IntColumn get payloadCipherVersion => integer().nullable()();
  IntColumn get payloadKeyVersion => integer().nullable()();
  BlobColumn get payloadNonce => blob().nullable()();
  BlobColumn get payloadCiphertext => blob().nullable()();

  @override
  Set<Column> get primaryKey => {operationId};
}

class OfflineWriteIntents extends Table {
  TextColumn get operationId => text()();
  TextColumn get ownerId => text()();
  TextColumn get workoutId => text()();
  IntColumn get contractVersion => integer()();
  TextColumn get mutationKind => text()();
  TextColumn get payloadJson => text().nullable()();
  IntColumn get payloadCipherVersion => integer().nullable()();
  IntColumn get payloadKeyVersion => integer().nullable()();
  BlobColumn get payloadNonce => blob().nullable()();
  BlobColumn get payloadCiphertext => blob().nullable()();
  TextColumn get payloadFingerprint => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAtUtcMillis => integer().nullable()();
  IntColumn get createdAtUtcMillis =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {operationId};
}

/// Existing set fields only. Mode-specific fields remain undefined.
final class SetCreateIntent {
  final String workoutExerciseId;
  final int setNumber;
  final int reps;
  final double weightKg;
  final int durationSeconds;
  final int restSeconds;
  final bool isCompleted;

  const SetCreateIntent({
    required this.workoutExerciseId,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    required this.durationSeconds,
    required this.restSeconds,
    required this.isCompleted,
  });

  Map<String, Object> toJson() {
    if (!_uuidPattern.hasMatch(workoutExerciseId) ||
        setNumber < 1 ||
        setNumber > 100 ||
        reps < 0 ||
        reps > 1000 ||
        !weightKg.isFinite ||
        weightKg < 0 ||
        weightKg > 1000 ||
        durationSeconds < 0 ||
        durationSeconds > 7200 ||
        restSeconds < 0 ||
        restSeconds > 7200 ||
        (isCompleted && reps == 0 && durationSeconds == 0)) {
      throw const FormatException('Invalid set create intent');
    }
    return {
      'workout_exercise_id': workoutExerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight_kg': weightKg,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
      'is_completed': isCompleted,
    };
  }
}

/// Narrow queue operations required by the coordinator. Authenticated callers
/// receive only [OwnerScopedOfflineQueue], never the Drift database instance.
abstract interface class OfflineQueueAccess {
  Future<List<OfflineWriteIntent>> pendingForOwnerWorkout(
    String ownerId,
    String workoutId,
  );

  Future<int?> claim(
    String ownerId,
    String workoutId,
    String operationId,
    int nowUtcMillis,
  );

  Future<bool> scheduleRetry(
    String ownerId,
    String workoutId,
    String operationId,
    int nextAttemptAtUtcMillis,
    int expectedAttemptCount,
  );

  Future<bool> markConflict(
    String ownerId,
    String workoutId,
    String operationId,
    int expectedAttemptCount,
  );

  Future<bool> releaseExpiredInFlight(
    String ownerId,
    String workoutId,
    String operationId,
    int nowUtcMillis,
  );

  Future<bool> acknowledge(
    String ownerId,
    String workoutId,
    String operationId,
    int expectedAttemptCount,
  );
}

@DriftDatabase(tables: [OfflineSetProjections, OfflineWriteIntents])
class OfflineWorkoutStore extends _$OfflineWorkoutStore
    implements OfflineQueueAccess {
  final OfflineAuthenticatedSession? _session;
  final OfflinePayloadCipher? _cipher;

  /// Legacy synthetic fixtures may inspect all owners in one disposable DB.
  /// Rows stay plaintext; no key store and no cipher are involved.
  factory OfflineWorkoutStore.syntheticTest(QueryExecutor executor) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      throw StateError('Synthetic raw store is unavailable in product builds');
    }
    return OfflineWorkoutStore._synthetic(executor);
  }

  OfflineWorkoutStore._synthetic(super.executor)
    : _session = null,
      _cipher = null;

  /// Only the facade below can construct an owner-scoped database.
  ///
  /// With a [cipher] every write stores an authenticated envelope and every read
  /// decrypts in memory; without one the store only serves disposable fixtures.
  OfflineWorkoutStore._ownerScoped(
    super.executor, {
    required OfflineAuthenticatedSession session,
    OfflinePayloadCipher? cipher,
  }) : _session = session,
       _cipher = cipher;

  int? _requireOwner(String ownerId) {
    final session = _session;
    if (session == null) return null;
    final generation = session.generation;
    if (session.authenticatedOwnerId != ownerId) {
      throw StateError('Authenticated owner does not match local row owner');
    }
    return generation;
  }

  void _confirmOwner(String ownerId, int? generation) {
    final session = _session;
    if (session == null) return;
    if (session.generation != generation ||
        session.authenticatedOwnerId != ownerId) {
      throw StateError('Offline owner session changed during operation');
    }
  }

  Future<T> _ownerTransaction<T>(
    String ownerId,
    Future<T> Function() action,
  ) async {
    final generation = _requireOwner(ownerId);
    return transaction(() async {
      _confirmOwner(ownerId, generation);
      final result = await action();
      _confirmOwner(ownerId, generation);
      return result;
    });
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(
          offlineWriteIntents,
          offlineWriteIntents.payloadFingerprint,
        );
        await m.addColumn(offlineWriteIntents, offlineWriteIntents.state);
        await m.addColumn(
          offlineWriteIntents,
          offlineWriteIntents.attemptCount,
        );
        await m.addColumn(
          offlineWriteIntents,
          offlineWriteIntents.nextAttemptAtUtcMillis,
        );
        await m.addColumn(
          offlineWriteIntents,
          offlineWriteIntents.createdAtUtcMillis,
        );
        final oldRows = await customSelect(
          'SELECT operation_id, owner_id, workout_id, payload_json '
          'FROM offline_write_intents',
        ).get();
        for (final row in oldRows) {
          _requireCanonicalUuid(
            row.read<String>('operation_id'),
            'operationId',
          );
          _requireCanonicalUuid(row.read<String>('owner_id'), 'ownerId');
          _requireCanonicalUuid(row.read<String>('workout_id'), 'workoutId');
          final payload = jsonDecode(row.read<String>('payload_json'));
          if (payload is! Map<String, dynamic> ||
              payload['workout_exercise_id'] is! String) {
            throw const FormatException('Invalid legacy set payload');
          }
          _requireCanonicalUuid(
            payload['workout_exercise_id'] as String,
            'workoutExerciseId',
          );
          await customUpdate(
            'UPDATE offline_write_intents SET payload_fingerprint = ? '
            'WHERE operation_id = ?',
            variables: [
              Variable.withString(
                _fingerprint(
                  row.read<String>('workout_id'),
                  row.read<String>('payload_json'),
                ),
              ),
              Variable.withString(row.read<String>('operation_id')),
            ],
            updates: {offlineWriteIntents},
          );
        }
      }
      if (from < 3) {
        // Envelope columns are added first so the table rebuild below copies
        // them by name; the rebuild only relaxes `payload_json` to nullable.
        for (final column in [
          offlineWriteIntents.payloadCipherVersion,
          offlineWriteIntents.payloadKeyVersion,
          offlineWriteIntents.payloadNonce,
          offlineWriteIntents.payloadCiphertext,
        ]) {
          await m.addColumn(offlineWriteIntents, column);
        }
        for (final column in [
          offlineSetProjections.payloadCipherVersion,
          offlineSetProjections.payloadKeyVersion,
          offlineSetProjections.payloadNonce,
          offlineSetProjections.payloadCiphertext,
        ]) {
          await m.addColumn(offlineSetProjections, column);
        }
        await m.alterTable(TableMigration(offlineWriteIntents));
        await m.alterTable(TableMigration(offlineSetProjections));
      }
    },
  );

  static String _fingerprint(String workoutId, String payloadJson) {
    final normalized = jsonEncode([
      1,
      'set_create_v1',
      workoutId,
      jsonDecode(payloadJson),
    ]);
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  /// The projection and immutable outbox intent are committed together.
  ///
  /// In encrypted mode the payload is sealed before the write transaction, so a
  /// slow platform key store never holds the transaction open. The owner and
  /// session generation still bracket the write.
  Future<void> enqueueSetCreate(
    WorkoutWriteIdentity identity,
    SetCreateIntent intent, {
    int? createdAtUtcMillis,
  }) async {
    _requireCanonicalUuid(identity.ownerId, 'ownerId');
    _requireCanonicalUuid(identity.workoutId, 'workoutId');
    _requireCanonicalUuid(identity.operationId, 'operationId');
    final payloadJson = jsonEncode(intent.toJson());
    final payloadFingerprint = _fingerprint(identity.workoutId, payloadJson);
    final createdAt =
        createdAtUtcMillis ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    if (createdAt < 0) {
      throw const FormatException(
        'Creation time must be non-negative UTC milliseconds',
      );
    }
    final cipher = _cipher;
    OfflinePayloadEnvelope? envelope;
    if (cipher != null) {
      // Bracket the write: sealing may await platform secure storage, so it runs
      // outside the transaction but still under an authenticated owner check.
      _requireOwner(identity.ownerId);
      envelope = await cipher.seal(
        binding: OfflineWriteBinding.setCreate(identity),
        plaintext: Uint8List.fromList(utf8.encode(payloadJson)),
      );
    }
    await _ownerTransaction(identity.ownerId, () async {
      final existing =
          await (select(offlineWriteIntents)
                ..where((row) => row.operationId.equals(identity.operationId)))
              .getSingleOrNull();
      if (existing != null) {
        final sameContent =
            existing.ownerId == identity.ownerId &&
            existing.workoutId == identity.workoutId &&
            existing.contractVersion ==
                OfflineWriteBinding.setCreateContractVersion &&
            existing.mutationKind ==
                OfflineWriteBinding.setCreateMutationKind &&
            existing.payloadFingerprint == payloadFingerprint &&
            (existing.payloadJson == null ||
                existing.payloadJson == payloadJson);
        if (sameContent) return;
        throw StateError('Operation ID reused with different content');
      }
      await into(offlineSetProjections).insert(
        OfflineSetProjectionsCompanion.insert(
          operationId: identity.operationId,
          ownerId: identity.ownerId,
          workoutId: identity.workoutId,
          payloadJson: Value<String?>(envelope == null ? payloadJson : null),
          payloadCipherVersion: Value<int?>(envelope?.cipherVersion),
          payloadKeyVersion: Value<int?>(envelope?.keyVersion),
          payloadNonce: Value<Uint8List?>(envelope?.nonce),
          payloadCiphertext: Value<Uint8List?>(envelope?.ciphertextWithTag),
        ),
      );
      await into(offlineWriteIntents).insert(
        OfflineWriteIntentsCompanion.insert(
          operationId: identity.operationId,
          ownerId: identity.ownerId,
          workoutId: identity.workoutId,
          contractVersion: OfflineWriteBinding.setCreateContractVersion,
          mutationKind: OfflineWriteBinding.setCreateMutationKind,
          payloadJson: Value<String?>(envelope == null ? payloadJson : null),
          payloadCipherVersion: Value<int?>(envelope?.cipherVersion),
          payloadKeyVersion: Value<int?>(envelope?.keyVersion),
          payloadNonce: Value<Uint8List?>(envelope?.nonce),
          payloadCiphertext: Value<Uint8List?>(envelope?.ciphertextWithTag),
          payloadFingerprint: Value(payloadFingerprint),
          state: const Value('pending'),
          attemptCount: const Value(0),
          createdAtUtcMillis: Value(createdAt),
        ),
      );
    });
  }

  /// Decrypts one stored intent in memory, leaving the row untouched.
  ///
  /// A legacy plaintext row is returned as-is; anything else must carry a
  /// complete envelope. Missing keys and failed authentication throw and never
  /// fall back to plaintext or mutate the row.
  Future<OfflineWriteIntent> _openIntent(OfflineWriteIntent row) async {
    final envelope = OfflinePayloadEnvelope.fromColumns(
      cipherVersion: row.payloadCipherVersion,
      keyVersion: row.payloadKeyVersion,
      nonce: row.payloadNonce,
      ciphertextWithTag: row.payloadCiphertext,
      hasPlaintext: row.payloadJson != null,
    );
    if (envelope == null) return row;
    final cipher = _cipher;
    if (cipher == null) {
      throw const OfflinePayloadFormatException(
        'Synthetic store cannot decrypt a protected payload',
      );
    }
    final clearText = await cipher.open(
      binding: OfflineWriteBinding(
        ownerId: row.ownerId,
        workoutId: row.workoutId,
        operationId: row.operationId,
        contractVersion: row.contractVersion,
        mutationKind: row.mutationKind,
      ),
      envelope: envelope,
    );
    return row.copyWith(payloadJson: Value<String?>(utf8.decode(clearText)));
  }

  /// Decrypts one stored projection in memory.
  ///
  /// Projections exist only for set creates, so they bind the set-create
  /// contract version and mutation kind.
  Future<OfflineSetProjection> _openProjection(OfflineSetProjection row) async {
    final envelope = OfflinePayloadEnvelope.fromColumns(
      cipherVersion: row.payloadCipherVersion,
      keyVersion: row.payloadKeyVersion,
      nonce: row.payloadNonce,
      ciphertextWithTag: row.payloadCiphertext,
      hasPlaintext: row.payloadJson != null,
    );
    if (envelope == null) return row;
    final cipher = _cipher;
    if (cipher == null) {
      throw const OfflinePayloadFormatException(
        'Synthetic store cannot decrypt a protected payload',
      );
    }
    final clearText = await cipher.open(
      binding: OfflineWriteBinding(
        ownerId: row.ownerId,
        workoutId: row.workoutId,
        operationId: row.operationId,
        contractVersion: OfflineWriteBinding.setCreateContractVersion,
        mutationKind: OfflineWriteBinding.setCreateMutationKind,
      ),
      envelope: envelope,
    );
    return row.copyWith(payloadJson: Value<String?>(utf8.decode(clearText)));
  }

  Future<List<OfflineWriteIntent>> _openIntents(
    List<OfflineWriteIntent> rows,
  ) async {
    final opened = <OfflineWriteIntent>[];
    for (final row in rows) {
      opened.add(await _openIntent(row));
    }
    return opened;
  }

  Future<List<OfflineWriteIntent>> pendingForOwner(String ownerId) async {
    _requireCanonicalUuid(ownerId, 'ownerId');
    final generation = _requireOwner(ownerId);
    final rows =
        await (select(offlineWriteIntents)
              ..where((row) => row.ownerId.equals(ownerId))
              ..orderBy([(row) => OrderingTerm.asc(row.operationId)]))
            .get();
    _confirmOwner(ownerId, generation);
    return _openIntents(rows);
  }

  /// Includes in-flight rows so a restarted coordinator can reconcile them.
  @override
  Future<List<OfflineWriteIntent>> pendingForOwnerWorkout(
    String ownerId,
    String workoutId,
  ) async {
    _requireCanonicalUuid(ownerId, 'ownerId');
    _requireCanonicalUuid(workoutId, 'workoutId');
    final generation = _requireOwner(ownerId);
    final rows =
        await (select(offlineWriteIntents)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.workoutId.equals(workoutId),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.createdAtUtcMillis),
                (row) => OrderingTerm.asc(row.operationId),
              ]))
            .get();
    _confirmOwner(ownerId, generation);
    return _openIntents(rows);
  }

  /// A conditional SQL update prevents duplicate claims across connections.
  @override
  Future<int?> claim(
    String ownerId,
    String workoutId,
    String operationId,
    int nowUtcMillis,
  ) async {
    _requireCanonicalUuid(ownerId, 'ownerId');
    _requireCanonicalUuid(workoutId, 'workoutId');
    _requireCanonicalUuid(operationId, 'operationId');
    if (nowUtcMillis < 0) {
      throw ArgumentError.value(nowUtcMillis, 'nowUtcMillis');
    }
    return _ownerTransaction(ownerId, () async {
      final updated = await customUpdate(
        'UPDATE offline_write_intents '
        'SET state = ?, attempt_count = attempt_count + 1, '
        'next_attempt_at_utc_millis = ? '
        'WHERE owner_id = ? AND workout_id = ? AND operation_id = ? '
        'AND (state = ? OR (state = ? AND next_attempt_at_utc_millis <= ?))',
        variables: [
          Variable.withString('in_flight'),
          Variable.withInt(nowUtcMillis + 30000),
          Variable.withString(ownerId),
          Variable.withString(workoutId),
          Variable.withString(operationId),
          Variable.withString('pending'),
          Variable.withString('retry_scheduled'),
          Variable.withInt(nowUtcMillis),
        ],
        updates: {offlineWriteIntents},
      );
      if (updated != 1) return null;
      final claimed =
          await (select(offlineWriteIntents)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.workoutId.equals(workoutId) &
                    row.operationId.equals(operationId),
              ))
              .getSingle();
      return claimed.attemptCount;
    });
  }

  @override
  Future<bool> scheduleRetry(
    String ownerId,
    String workoutId,
    String operationId,
    int nextAttemptAtUtcMillis,
    int expectedAttemptCount,
  ) async {
    _requireCanonicalUuid(ownerId, 'ownerId');
    _requireCanonicalUuid(workoutId, 'workoutId');
    _requireCanonicalUuid(operationId, 'operationId');
    if (nextAttemptAtUtcMillis < 0 || expectedAttemptCount < 1) {
      throw ArgumentError.value(
        nextAttemptAtUtcMillis,
        'nextAttemptAtUtcMillis',
      );
    }
    return _ownerTransaction(ownerId, () async {
      final updated = await customUpdate(
        'UPDATE offline_write_intents '
        'SET state = ?, next_attempt_at_utc_millis = ? '
        'WHERE owner_id = ? AND workout_id = ? AND operation_id = ? '
        'AND state = ? AND attempt_count = ?',
        variables: [
          Variable.withString('retry_scheduled'),
          Variable.withInt(nextAttemptAtUtcMillis),
          Variable.withString(ownerId),
          Variable.withString(workoutId),
          Variable.withString(operationId),
          Variable.withString('in_flight'),
          Variable.withInt(expectedAttemptCount),
        ],
        updates: {offlineWriteIntents},
      );
      return updated == 1;
    });
  }

  @override
  Future<bool> markConflict(
    String ownerId,
    String workoutId,
    String operationId,
    int expectedAttemptCount,
  ) async {
    _requireCanonicalUuid(ownerId, 'ownerId');
    _requireCanonicalUuid(workoutId, 'workoutId');
    _requireCanonicalUuid(operationId, 'operationId');
    if (expectedAttemptCount < 1) {
      throw ArgumentError.value(expectedAttemptCount, 'expectedAttemptCount');
    }
    return _ownerTransaction(ownerId, () async {
      final updated = await customUpdate(
        'UPDATE offline_write_intents '
        'SET state = ?, next_attempt_at_utc_millis = NULL '
        'WHERE owner_id = ? AND workout_id = ? AND operation_id = ? '
        'AND state = ? AND attempt_count = ?',
        variables: [
          Variable.withString('conflict'),
          Variable.withString(ownerId),
          Variable.withString(workoutId),
          Variable.withString(operationId),
          Variable.withString('in_flight'),
          Variable.withInt(expectedAttemptCount),
        ],
        updates: {offlineWriteIntents},
      );
      return updated == 1;
    });
  }

  /// Reclaims an uncertain ACK only after its prior claim lease expires.
  @override
  Future<bool> releaseExpiredInFlight(
    String ownerId,
    String workoutId,
    String operationId,
    int nowUtcMillis,
  ) async {
    _requireCanonicalUuid(ownerId, 'ownerId');
    _requireCanonicalUuid(workoutId, 'workoutId');
    _requireCanonicalUuid(operationId, 'operationId');
    if (nowUtcMillis < 0) {
      throw ArgumentError.value(nowUtcMillis, 'nowUtcMillis');
    }
    return _ownerTransaction(ownerId, () async {
      final updated = await customUpdate(
        'UPDATE offline_write_intents '
        'SET state = ?, next_attempt_at_utc_millis = NULL '
        'WHERE owner_id = ? AND workout_id = ? AND operation_id = ? '
        'AND state = ? AND next_attempt_at_utc_millis <= ?',
        variables: [
          Variable.withString('pending'),
          Variable.withString(ownerId),
          Variable.withString(workoutId),
          Variable.withString(operationId),
          Variable.withString('in_flight'),
          Variable.withInt(nowUtcMillis),
        ],
        updates: {offlineWriteIntents},
      );
      return updated == 1;
    });
  }

  Future<List<OfflineSetProjection>> projectedForOwner(String ownerId) async {
    _requireCanonicalUuid(ownerId, 'ownerId');
    final generation = _requireOwner(ownerId);
    final rows = await (select(
      offlineSetProjections,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    _confirmOwner(ownerId, generation);
    final opened = <OfflineSetProjection>[];
    for (final row in rows) {
      opened.add(await _openProjection(row));
    }
    return opened;
  }

  /// Called only after a matching server acknowledgement has been verified.
  @override
  Future<bool> acknowledge(
    String ownerId,
    String workoutId,
    String operationId,
    int expectedAttemptCount,
  ) {
    _requireCanonicalUuid(ownerId, 'ownerId');
    _requireCanonicalUuid(workoutId, 'workoutId');
    _requireCanonicalUuid(operationId, 'operationId');
    return _ownerTransaction(ownerId, () async {
      if (expectedAttemptCount < 1) {
        throw ArgumentError.value(expectedAttemptCount, 'expectedAttemptCount');
      }
      final deletedIntent =
          await (delete(offlineWriteIntents)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.workoutId.equals(workoutId) &
                    row.operationId.equals(operationId) &
                    row.state.equals('in_flight') &
                    row.attemptCount.equals(expectedAttemptCount),
              ))
              .go();
      if (deletedIntent == 0) return false;
      final deletedProjection =
          await (delete(offlineSetProjections)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.workoutId.equals(workoutId) &
                    row.operationId.equals(operationId),
              ))
              .go();
      if (deletedProjection != 1) {
        throw StateError('Acknowledged intent lacks its local projection');
      }
      return true;
    });
  }

  /// Documented forward path for legacy plaintext rows.
  ///
  /// Owner-checked: it converts that owner's plaintext intents and projections
  /// to envelopes and nulls `payload_json` in a single transaction. Returns the
  /// number of intents converted. Sealing runs before the transaction because a
  /// platform key store may await secure storage.
  Future<int> encryptLegacyRowsForOwner(String ownerId) async {
    final cipher = _cipher;
    if (cipher == null) {
      throw StateError('An encrypted offline queue is required');
    }
    _requireCanonicalUuid(ownerId, 'ownerId');
    final generation = _requireOwner(ownerId);
    final intentRows =
        (await (select(offlineWriteIntents)
                  ..where((row) => row.ownerId.equals(ownerId))
                  ..orderBy([(row) => OrderingTerm.asc(row.operationId)]))
                .get())
            .where((row) => row.payloadJson != null)
            .toList();
    final projectionRows =
        (await (select(
              offlineSetProjections,
            )..where((row) => row.ownerId.equals(ownerId))).get())
            .where((row) => row.payloadJson != null)
            .toList();
    _confirmOwner(ownerId, generation);

    final sealedIntents =
        <({OfflineWriteIntent row, OfflinePayloadEnvelope envelope})>[];
    for (final row in intentRows) {
      final envelope = await cipher.seal(
        binding: OfflineWriteBinding(
          ownerId: row.ownerId,
          workoutId: row.workoutId,
          operationId: row.operationId,
          contractVersion: row.contractVersion,
          mutationKind: row.mutationKind,
        ),
        plaintext: Uint8List.fromList(utf8.encode(row.payloadJson!)),
      );
      sealedIntents.add((row: row, envelope: envelope));
    }
    final sealedProjections =
        <({OfflineSetProjection row, OfflinePayloadEnvelope envelope})>[];
    for (final row in projectionRows) {
      final envelope = await cipher.seal(
        binding: OfflineWriteBinding(
          ownerId: row.ownerId,
          workoutId: row.workoutId,
          operationId: row.operationId,
          contractVersion: OfflineWriteBinding.setCreateContractVersion,
          mutationKind: OfflineWriteBinding.setCreateMutationKind,
        ),
        plaintext: Uint8List.fromList(utf8.encode(row.payloadJson!)),
      );
      sealedProjections.add((row: row, envelope: envelope));
    }

    await _ownerTransaction(ownerId, () async {
      for (final sealed in sealedIntents) {
        await customUpdate(
          'UPDATE offline_write_intents SET payload_json = NULL, '
          'payload_cipher_version = ?, payload_key_version = ?, '
          'payload_nonce = ?, payload_ciphertext = ? '
          'WHERE owner_id = ? AND operation_id = ? AND payload_json IS NOT NULL',
          variables: [
            Variable.withInt(sealed.envelope.cipherVersion),
            Variable.withInt(sealed.envelope.keyVersion),
            Variable.withBlob(sealed.envelope.nonce),
            Variable.withBlob(sealed.envelope.ciphertextWithTag),
            Variable.withString(ownerId),
            Variable.withString(sealed.row.operationId),
          ],
          updates: {offlineWriteIntents},
        );
      }
      for (final sealed in sealedProjections) {
        await customUpdate(
          'UPDATE offline_set_projections SET payload_json = NULL, '
          'payload_cipher_version = ?, payload_key_version = ?, '
          'payload_nonce = ?, payload_ciphertext = ? '
          'WHERE owner_id = ? AND operation_id = ? AND payload_json IS NOT NULL',
          variables: [
            Variable.withInt(sealed.envelope.cipherVersion),
            Variable.withInt(sealed.envelope.keyVersion),
            Variable.withBlob(sealed.envelope.nonce),
            Variable.withBlob(sealed.envelope.ciphertextWithTag),
            Variable.withString(ownerId),
            Variable.withString(sealed.row.operationId),
          ],
          updates: {offlineSetProjections},
        );
      }
    });
    return sealedIntents.length;
  }

  /// Explicit owner action. No age-based or automatic deletion path exists.
  Future<int> discardPendingForOwner(
    String ownerId, {
    required bool ownerConfirmed,
  }) {
    _requireCanonicalUuid(ownerId, 'ownerId');
    if (!ownerConfirmed) {
      throw StateError('Explicit owner confirmation is required to discard');
    }
    return _ownerTransaction(ownerId, () async {
      final count = await (select(
        offlineWriteIntents,
      )..where((row) => row.ownerId.equals(ownerId))).get();
      await (delete(
        offlineSetProjections,
      )..where((row) => row.ownerId.equals(ownerId))).go();
      await (delete(
        offlineWriteIntents,
      )..where((row) => row.ownerId.equals(ownerId))).go();
      return count.length;
    });
  }
}

/// Restricted synthetic owner-bound API. It deliberately exposes no Drift
/// database, query executor, custom SQL, or table objects to its caller.
final class OwnerScopedOfflineQueue implements OfflineQueueAccess {
  final OfflineWorkoutStore _store;

  /// Disposable plaintext fixtures. Production never uses this constructor.
  OwnerScopedOfflineQueue.syntheticTest(
    QueryExecutor executor, {
    required OfflineAuthenticatedSession session,
  }) : _store = OfflineWorkoutStore._ownerScoped(executor, session: session);

  /// Encrypted queue: every write stores an authenticated envelope and reads
  /// decrypt in memory. Still gated behind the production offline flags.
  OwnerScopedOfflineQueue.encrypted(
    QueryExecutor executor, {
    required OfflineAuthenticatedSession session,
    required OfflinePayloadCipher cipher,
  }) : _store = OfflineWorkoutStore._ownerScoped(
         executor,
         session: session,
         cipher: cipher,
       );

  Future<void> close() => _store.close();

  /// Converts this owner's legacy plaintext rows to envelopes. Owner-checked.
  Future<int> encryptLegacyRowsForOwner(String ownerId) =>
      _store.encryptLegacyRowsForOwner(ownerId);

  Future<void> enqueueSetCreate(
    WorkoutWriteIdentity identity,
    SetCreateIntent intent, {
    int? createdAtUtcMillis,
  }) => _store.enqueueSetCreate(
    identity,
    intent,
    createdAtUtcMillis: createdAtUtcMillis,
  );

  Future<List<OfflineWriteIntent>> pendingForOwner(String ownerId) =>
      _store.pendingForOwner(ownerId);

  Future<List<OfflineSetProjection>> projectedForOwner(String ownerId) =>
      _store.projectedForOwner(ownerId);

  Future<int> discardPendingForOwner(
    String ownerId, {
    required bool ownerConfirmed,
  }) => _store.discardPendingForOwner(ownerId, ownerConfirmed: ownerConfirmed);

  @override
  Future<List<OfflineWriteIntent>> pendingForOwnerWorkout(
    String ownerId,
    String workoutId,
  ) => _store.pendingForOwnerWorkout(ownerId, workoutId);

  @override
  Future<int?> claim(
    String ownerId,
    String workoutId,
    String operationId,
    int nowUtcMillis,
  ) => _store.claim(ownerId, workoutId, operationId, nowUtcMillis);

  @override
  Future<bool> scheduleRetry(
    String ownerId,
    String workoutId,
    String operationId,
    int nextAttemptAtUtcMillis,
    int expectedAttemptCount,
  ) => _store.scheduleRetry(
    ownerId,
    workoutId,
    operationId,
    nextAttemptAtUtcMillis,
    expectedAttemptCount,
  );

  @override
  Future<bool> markConflict(
    String ownerId,
    String workoutId,
    String operationId,
    int expectedAttemptCount,
  ) => _store.markConflict(
    ownerId,
    workoutId,
    operationId,
    expectedAttemptCount,
  );

  @override
  Future<bool> releaseExpiredInFlight(
    String ownerId,
    String workoutId,
    String operationId,
    int nowUtcMillis,
  ) => _store.releaseExpiredInFlight(
    ownerId,
    workoutId,
    operationId,
    nowUtcMillis,
  );

  @override
  Future<bool> acknowledge(
    String ownerId,
    String workoutId,
    String operationId,
    int expectedAttemptCount,
  ) =>
      _store.acknowledge(ownerId, workoutId, operationId, expectedAttemptCount);
}
