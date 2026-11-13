import 'dart:convert';

import 'package:app/features/analytics/data/backup_import_service.dart';
import 'package:app/features/analytics/data/csv_import_service.dart';
import 'package:app/features/analytics/domain/import_models.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:flutter_test/flutter_test.dart';

const _exerciseId = '11111111-1111-4111-8111-111111111111';
const _ownerId = '22222222-2222-4222-8222-222222222222';
const _sourceWorkoutId = '22222222-2222-4222-8222-222222222241';

class _CatalogueRepository extends Fake implements ExerciseRepository {
  final List<Exercise> created = [];

  @override
  Future<List<Exercise>> getExercises() async => [
    const Exercise(
      id: _exerciseId,
      name: 'Bench Press',
      category: 'Chest',
      equipment: 'Barbell',
    ),
  ];

  @override
  Future<Exercise> createCustomExercise(Exercise exercise) async {
    created.add(exercise);
    return exercise;
  }
}

/// startWorkout deliberately models the production RPC: it replays an active
/// workout instead of creating a new row when one already exists.
class _ImportWorkoutRepository extends Fake
    implements WorkoutRepository, HistoricalImportIdentity {
  _ImportWorkoutRepository({
    this.existingActive = false,
    this.denyCompletion = false,
    this.authenticatedOwner = _ownerId,
    this.existingSourceId,
  });

  final bool existingActive;
  final bool denyCompletion;
  final String authenticatedOwner;
  final String? existingSourceId;
  @override
  String get authenticatedUserId => authenticatedOwner;
  final List<String> exerciseWritesTo = [];
  int startCalls = 0;
  int setWrites = 0;
  int markCalls = 0;

  String get workoutId =>
      existingActive ? 'active-owner-workout' : 'new-import';

  @override
  Future<Workout?> getActiveWorkout() async => existingActive
      ? Workout(id: workoutId, userId: _ownerId, status: WorkoutStatus.active)
      : null;

  @override
  Future<Workout?> getWorkoutDetail(String workoutId) async =>
      workoutId == existingSourceId
      ? Workout(
          id: workoutId,
          userId: _ownerId,
          status: WorkoutStatus.completed,
          completedAt: DateTime.utc(2026, 11, 1, 11),
        )
      : null;

  @override
  Future<Workout> startWorkout() async {
    startCalls++;
    return Workout(
      id: workoutId,
      userId: _ownerId,
      status: WorkoutStatus.active,
    );
  }

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  ) async {
    exerciseWritesTo.add(workoutId);
    return WorkoutExercise(
      id: 'new-workout-exercise',
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );
  }

  @override
  Future<WorkoutSet> addSet(
    String workoutExerciseId,
    int setNumber,
    int reps,
    double weightKg, {
    double baselineWeightKg = 0,
    int durationSeconds = 0,
  }) async {
    setWrites++;
    return WorkoutSet(
      id: 'new-set-$setWrites',
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      reps: reps,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Future<Workout> markWorkoutCompleted(
    String workoutId, {
    DateTime? completedAt,
    int? durationSeconds,
    String? notes,
  }) async {
    markCalls++;
    if (denyCompletion) throw StateError('permission denied for workouts');
    return Workout(
      id: workoutId,
      userId: _ownerId,
      status: WorkoutStatus.completed,
      completedAt: completedAt ?? DateTime.utc(2026, 11, 1),
    );
  }
}

class _AtomicImportRepository extends _ImportWorkoutRepository
    implements HistoricalWorkoutImportRepository {
  _AtomicImportRepository({
    this.failAttempt,
    super.authenticatedOwner,
    super.existingSourceId,
  });

  final int? failAttempt;
  final Map<String, String> committed = {};
  final Map<String, List<String>> createdCustomIdsByKey = {};
  final List<Map<String, dynamic>> payloads = [];
  int attempts = 0;

  @override
  Future<HistoricalWorkoutImportReceipt> importHistoricalWorkout({
    required String importKey,
    required Map<String, dynamic> payload,
  }) async {
    attempts++;
    payloads.add(payload);
    if (attempts == failAttempt) {
      throw StateError('simulated atomic import failure');
    }
    final prior = committed[importKey];
    if (prior != null) {
      return HistoricalWorkoutImportReceipt(
        workoutId: prior,
        alreadyImported: true,
        createdCustomExerciseIds: createdCustomIdsByKey[importKey] ?? const [],
      );
    }
    final newId = 'history-${committed.length + 1}';
    final createdCustomIds = (payload['exercises'] as List)
        .map((exercise) => (exercise as Map)['custom_exercise'])
        .whereType<Map>()
        .map((custom) => custom['id'] as String)
        .toList();
    committed[importKey] = newId;
    createdCustomIdsByKey[importKey] = createdCustomIds;
    return HistoricalWorkoutImportReceipt(
      workoutId: newId,
      alreadyImported: false,
      createdCustomExerciseIds: createdCustomIds,
    );
  }
}

const _csv =
    'date,exercise,reps,weight_kg,unit,duration_seconds\n'
    '2026-11-01,Bench Press,10,60,kg,0';

ImportPreview _validPreview({
  int count = 1,
  String sourceName = 'Bench Press',
  bool resolved = true,
  double weightKg = 60,
  String? sourceId,
}) => ImportPreview(
  format: ImportFormat.gymLvlCsv,
  warnings: const [],
  workouts: [
    for (var index = 0; index < count; index++)
      ImportedWorkout(
        sourceId: sourceId ?? '22222222-2222-4222-8222-22222222225${index + 1}',
        sourceFile: 'history.csv',
        startedAt: DateTime.utc(2026, 11, index + 1, 10),
        completedAt: DateTime.utc(2026, 11, index + 1, 11),
        durationSeconds: 3600,
        exercises: [
          ImportedExercise(
            sourceName: sourceName,
            exerciseId: resolved ? _exerciseId : null,
            sets: [
              ImportedSet(
                setNumber: 1,
                reps: 10,
                weightKg: weightKg,
                durationSeconds: 0,
              ),
            ],
          ),
        ],
      ),
  ],
);

String _backup() => jsonEncode({
  'format': kBackupFormat,
  'version': kBackupVersion,
  'exported_at': '2026-11-02T00:00:00Z',
  'data': {
    'user_id': _ownerId,
    'workouts': [
      {
        'workout_id': _sourceWorkoutId,
        'user_id': _ownerId,
        'status': 'completed',
        'started_at': '2026-11-01T10:00:00Z',
        'completed_at': '2026-11-01T11:00:00Z',
        'duration_seconds': 3600,
      },
    ],
    'workout_exercises': [
      {
        'workout_exercise_id': 'source-exercise',
        'workout_id': _sourceWorkoutId,
        'exercise_id': _exerciseId,
        'order_index': 0,
      },
    ],
    'workout_sets': [
      {
        'set_id': 'source-set',
        'workout_exercise_id': 'source-exercise',
        'set_number': 1,
        'reps': 10,
        'weight_kg': 60,
        'duration_seconds': 0,
      },
    ],
    'body_measurements': <Map<String, dynamic>>[],
  },
});

String _legacyBackupFingerprint(String input) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(input)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

void main() {
  group('P9 import write boundary', () {
    test('CSV import never mutates a replayed active workout', () async {
      final workouts = _ImportWorkoutRepository(existingActive: true);
      final service = CsvImportService();
      final preview = _validPreview();
      expect(preview.workoutCount, 1);

      await service.confirm(
        preview,
        workoutRepository: workouts,
        exerciseRepository: _CatalogueRepository(),
        userId: _ownerId,
      );

      expect(workouts.exerciseWritesTo, isNot(contains(workouts.workoutId)));
      expect(workouts.setWrites, 0);
      expect(workouts.markCalls, 0);
    });

    test('backup restore never mutates a replayed active workout', () async {
      final workouts = _ImportWorkoutRepository(existingActive: true);
      final service = BackupImportService(
        workoutRepository: workouts,
        exerciseRepository: _CatalogueRepository(),
      );
      expect(service.preview(_backup()).canRestore, isTrue);

      await service.restore(jsonContent: _backup(), currentUserId: _ownerId);

      expect(workouts.exerciseWritesTo, isNot(contains(workouts.workoutId)));
      expect(workouts.setWrites, 0);
      expect(workouts.markCalls, 0);
    });

    test('CSV import does not count denied completion as imported', () async {
      final workouts = _ImportWorkoutRepository(denyCompletion: true);
      final service = CsvImportService();

      final result = await service.confirm(
        _validPreview(),
        workoutRepository: workouts,
        exerciseRepository: _CatalogueRepository(),
        userId: _ownerId,
      );

      expect(result.importedCount, 0);
      expect(result.warnings.any((w) => w.code == 'persistence_error'), isTrue);
    });

    test(
      'CSV retries only the failed workout after partial file import',
      () async {
        final workouts = _AtomicImportRepository(failAttempt: 2);
        final service = CsvImportService();
        final preview = _validPreview(count: 2);
        expect(preview.workoutCount, 2);

        final first = await service.confirm(
          preview,
          workoutRepository: workouts,
          exerciseRepository: _CatalogueRepository(),
          userId: _ownerId,
        );
        expect(first.importedCount, 1);
        expect(
          first.warnings.any((w) => w.code == 'persistence_error'),
          isTrue,
        );
        expect(workouts.committed.length, 1);

        final retry = await service.confirm(
          preview,
          workoutRepository: workouts,
          exerciseRepository: _CatalogueRepository(),
          userId: _ownerId,
        );
        expect(retry.importedCount, 1);
        expect(retry.skippedDuplicates, 1);
        expect(retry.warnings, isEmpty);
        expect(workouts.committed.length, 2);
        expect(workouts.startCalls, 0);
        expect(workouts.exerciseWritesTo, isEmpty);
        expect(workouts.markCalls, 0);
        expect(
          (workouts.payloads.first['exercises'] as List)
              .first['sets']
              .first['is_completed'],
          isTrue,
        );
      },
    );

    test(
      'date-only generic CSV is rejected without invented chronology',
      () async {
        final workouts = _AtomicImportRepository();
        final result = await CsvImportService().confirm(
          CsvImportService().parse(_csv),
          workoutRepository: workouts,
          exerciseRepository: _CatalogueRepository(),
          userId: _ownerId,
        );

        expect(result.importedCount, 0);
        expect(result.warnings.any((w) => w.code == 'invalid_history'), isTrue);
        expect(workouts.attempts, 0);
      },
    );

    test('changed CSV set content gets a distinct import key', () async {
      final workouts = _AtomicImportRepository();
      final service = CsvImportService();
      final fingerprints = <String>[];
      Future<bool> isDuplicate(String fingerprint) async {
        fingerprints.add(fingerprint);
        return false;
      }

      final first = await service.confirm(
        _validPreview(weightKg: 60),
        workoutRepository: workouts,
        exerciseRepository: _CatalogueRepository(),
        userId: _ownerId,
        isDuplicate: isDuplicate,
      );
      final changed = await service.confirm(
        _validPreview(weightKg: 65),
        workoutRepository: workouts,
        exerciseRepository: _CatalogueRepository(),
        userId: _ownerId,
        isDuplicate: isDuplicate,
      );

      expect(first.importedCount, 1);
      expect(changed.importedCount, 1);
      expect(workouts.committed.length, 2);
      final strongFingerprints = fingerprints
          .where((fingerprint) => fingerprint.startsWith('csv:v2:sha256:'))
          .toList();
      expect(strongFingerprints, hasLength(2));
      expect(strongFingerprints[0], isNot(strongFingerprints[1]));
    });

    test('GymLvl CSV refuses an existing owner source workout UUID', () async {
      const sourceId = '22222222-2222-4222-8222-222222222251';
      final preview = _validPreview(sourceId: sourceId);
      final existing = _AtomicImportRepository(existingSourceId: sourceId);
      final denied = await CsvImportService().confirm(
        preview,
        workoutRepository: existing,
        exerciseRepository: _CatalogueRepository(),
        userId: _ownerId,
      );
      expect(denied.importedCount, 0);
      expect(
        denied.warnings.any((w) => w.code == 'source_workout_exists'),
        isTrue,
      );
      expect(existing.attempts, 0);

      final absent = _AtomicImportRepository();
      final accepted = await CsvImportService().confirm(
        preview,
        workoutRepository: absent,
        exerciseRepository: _CatalogueRepository(),
        userId: _ownerId,
      );
      expect(accepted.importedCount, 1);
      expect(absent.payloads.single['source_workout_id'], sourceId);
    });

    test('legacy CSV FNV marker requires review before any import', () async {
      final preview = _validPreview();
      final legacyInput = preview.workouts
          .map((w) => '${w.sourceId}|${w.startedAt.toIso8601String()}')
          .join(';');
      final legacyFingerprint = _legacyBackupFingerprint(legacyInput);
      final workouts = _AtomicImportRepository();
      final checked = <String>[];

      final result = await CsvImportService().confirm(
        preview,
        workoutRepository: workouts,
        exerciseRepository: _CatalogueRepository(),
        userId: _ownerId,
        isDuplicate: (fingerprint) async {
          checked.add(fingerprint);
          return fingerprint == legacyFingerprint;
        },
      );

      expect(checked, contains(legacyFingerprint));
      expect(result.importedCount, 0);
      expect(
        result.warnings.any((w) => w.code == 'legacy_import_requires_review'),
        isTrue,
      );
      expect(workouts.attempts, 0);
    });

    test('failed CSV import leaves no pre-created custom exercise', () async {
      final workouts = _AtomicImportRepository(failAttempt: 1);
      final catalogue = _CatalogueRepository();
      final service = CsvImportService();
      final result = await service.confirm(
        _validPreview(sourceName: 'Unlisted Lift', resolved: false),
        workoutRepository: workouts,
        exerciseRepository: catalogue,
        unknownPolicy: ImportUnknownExercisePolicy.createCustom,
        userId: _ownerId,
      );

      expect(result.importedCount, 0);
      expect(catalogue.created, isEmpty);
      expect(workouts.committed, isEmpty);
      expect(workouts.attempts, 1);
    });

    test(
      'CSV custom descriptor is created once inside acknowledged RPC',
      () async {
        final workouts = _AtomicImportRepository();
        final catalogue = _CatalogueRepository();
        final service = CsvImportService();
        final preview = _validPreview(
          sourceName: 'Unlisted Lift',
          resolved: false,
        );

        final first = await service.confirm(
          preview,
          workoutRepository: workouts,
          exerciseRepository: catalogue,
          unknownPolicy: ImportUnknownExercisePolicy.createCustom,
          userId: _ownerId,
        );
        final retry = await service.confirm(
          preview,
          workoutRepository: workouts,
          exerciseRepository: catalogue,
          unknownPolicy: ImportUnknownExercisePolicy.createCustom,
          userId: _ownerId,
        );

        expect(first.importedCount, 1);
        expect(first.createdCustomExerciseIds, hasLength(1));
        expect(retry.importedCount, 0);
        expect(retry.skippedDuplicates, 1);
        expect(workouts.committed, hasLength(1));
        expect(catalogue.created, isEmpty);
        final descriptor =
            (workouts.payloads.first['exercises'] as List)
                    .single['custom_exercise']
                as Map<String, dynamic>;
        expect(descriptor['id'], first.createdCustomExerciseIds.single);
        expect(descriptor['name'], 'Unlisted Lift');
      },
    );

    test(
      'backup restore does not count denied completion as restored',
      () async {
        final workouts = _ImportWorkoutRepository(denyCompletion: true);
        final service = BackupImportService(
          workoutRepository: workouts,
          exerciseRepository: _CatalogueRepository(),
        );
        var fingerprintRecorded = false;

        final result = await service.restore(
          jsonContent: _backup(),
          currentUserId: _ownerId,
          recordImported: (_) async => fingerprintRecorded = true,
        );

        expect(result.success, isFalse);
        expect(result.restoredWorkoutCount, 0);
        expect(fingerprintRecorded, isFalse);
      },
    );

    test(
      'backup records fingerprint only after every workout receipt',
      () async {
        final workouts = _AtomicImportRepository(failAttempt: 2);
        final backup = jsonDecode(_backup()) as Map<String, dynamic>;
        final data = backup['data'] as Map<String, dynamic>;
        (data['workouts'] as List).add({
          ...(data['workouts'] as List).first as Map,
          'workout_id': '22222222-2222-4222-8222-222222222242',
        });
        (data['workout_exercises'] as List).add({
          ...(data['workout_exercises'] as List).first as Map,
          'workout_exercise_id': 'second-source-exercise',
          'workout_id': '22222222-2222-4222-8222-222222222242',
        });
        (data['workout_sets'] as List).add({
          ...(data['workout_sets'] as List).first as Map,
          'set_id': 'second-source-set',
          'workout_exercise_id': 'second-source-exercise',
        });
        final content = jsonEncode(backup);
        final service = BackupImportService(
          workoutRepository: workouts,
          exerciseRepository: _CatalogueRepository(),
        );
        final recorded = <String>[];

        final first = await service.restore(
          jsonContent: content,
          currentUserId: _ownerId,
          recordImported: (fingerprint) async => recorded.add(fingerprint),
        );
        expect(first.success, isFalse);
        expect(first.restoredWorkoutCount, 1);
        expect(workouts.committed, hasLength(1));
        expect(recorded, isEmpty);

        final retry = await service.restore(
          jsonContent: content,
          currentUserId: _ownerId,
          recordImported: (fingerprint) async => recorded.add(fingerprint),
        );
        expect(retry.success, isTrue);
        expect(retry.restoredWorkoutCount, 1);
        expect(retry.skippedDuplicateCount, 1);
        expect(workouts.committed, hasLength(2));
        expect(recorded, hasLength(1));
      },
    );

    test(
      'legacy FNV duplicate marker requires review before any restore',
      () async {
        final content = _backup();
        final legacyFingerprint = _legacyBackupFingerprint(content);
        final workouts = _AtomicImportRepository();
        final checked = <String>[];
        final recorded = <String>[];
        final result =
            await BackupImportService(
              workoutRepository: workouts,
              exerciseRepository: _CatalogueRepository(),
            ).restore(
              jsonContent: content,
              currentUserId: _ownerId,
              isDuplicate: (fingerprint) async {
                checked.add(fingerprint);
                return fingerprint == legacyFingerprint;
              },
              recordImported: (fingerprint) async => recorded.add(fingerprint),
            );

        expect(legacyFingerprint, hasLength(8));
        expect(checked, contains(legacyFingerprint));
        expect(result.success, isFalse);
        expect(
          result.errors.any((e) => e.code == 'legacy_import_requires_review'),
          isTrue,
        );
        expect(workouts.attempts, 0);
        expect(recorded, isEmpty);
      },
    );

    for (final foreignOwnerLocation in ['data', 'workout']) {
      test(
        'backup rejects foreign owner in $foreignOwnerLocation before writes',
        () async {
          final workouts = _ImportWorkoutRepository();
          final service = BackupImportService(
            workoutRepository: workouts,
            exerciseRepository: _CatalogueRepository(),
          );
          final backup = jsonDecode(_backup()) as Map<String, dynamic>;
          final data = backup['data'] as Map<String, dynamic>;
          if (foreignOwnerLocation == 'data') {
            data['user_id'] = '33333333-3333-4333-8333-333333333333';
          } else {
            (data['workouts'] as List).first['user_id'] =
                '33333333-3333-4333-8333-333333333333';
          }

          final result = await service.restore(
            jsonContent: jsonEncode(backup),
            currentUserId: _ownerId,
          );

          expect(result.success, isFalse);
          expect(workouts.startCalls, 0);
          expect(workouts.exerciseWritesTo, isEmpty);
        },
      );
    }

    test(
      'backup rejects a forged owner parameter against authenticated identity',
      () async {
        final workouts = _AtomicImportRepository(
          authenticatedOwner: '33333333-3333-4333-8333-333333333333',
        );
        final service = BackupImportService(
          workoutRepository: workouts,
          exerciseRepository: _CatalogueRepository(),
        );

        final result = await service.restore(
          jsonContent: _backup(),
          currentUserId: _ownerId,
        );

        expect(result.success, isFalse);
        expect(
          result.errors.any((error) => error.code == 'owner_mismatch'),
          isTrue,
        );
        expect(workouts.attempts, 0);
        expect(workouts.startCalls, 0);
      },
    );

    for (final orphanLocation in ['workout_exercise', 'set']) {
      test('backup rejects orphan $orphanLocation before writes', () async {
        final workouts = _ImportWorkoutRepository();
        final service = BackupImportService(
          workoutRepository: workouts,
          exerciseRepository: _CatalogueRepository(),
        );
        final backup = jsonDecode(_backup()) as Map<String, dynamic>;
        final data = backup['data'] as Map<String, dynamic>;
        if (orphanLocation == 'workout_exercise') {
          (data['workout_exercises'] as List).first['workout_id'] =
              'missing-workout';
        } else {
          (data['workout_sets'] as List).first['workout_exercise_id'] =
              'missing-exercise';
        }
        final content = jsonEncode(backup);

        expect(service.preview(content).canRestore, isFalse);
        final result = await service.restore(
          jsonContent: content,
          currentUserId: _ownerId,
        );
        expect(result.success, isFalse);
        expect(workouts.startCalls, 0);
      });
    }

    test('malformed backup order is rejected before any write', () async {
      final workouts = _AtomicImportRepository();
      final service = BackupImportService(
        workoutRepository: workouts,
        exerciseRepository: _CatalogueRepository(),
      );
      final backup = jsonDecode(_backup()) as Map<String, dynamic>;
      final data = backup['data'] as Map<String, dynamic>;
      (data['workout_exercises'] as List).first['order_index'] = 'oops';
      final content = jsonEncode(backup);

      expect(service.preview(content).canRestore, isFalse);
      final result = await service.restore(
        jsonContent: content,
        currentUserId: _ownerId,
      );
      expect(result.success, isFalse);
      expect(workouts.attempts, 0);
      expect(workouts.startCalls, 0);
    });
  });
}
