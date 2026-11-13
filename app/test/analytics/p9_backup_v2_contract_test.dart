import 'dart:convert';

import 'package:app/features/analytics/data/backup_export_service.dart';
import 'package:app/features/analytics/data/backup_import_service.dart';
import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:flutter_test/flutter_test.dart';

const _ownerId = '94000000-0000-4000-8000-000000000001';
const _exerciseId = '94000000-0000-4000-8000-000000000011';
const _sourceWorkoutId = '94000000-0000-4000-8000-000000000041';

class _ExerciseRepository extends Fake implements ExerciseRepository {}

class _ImportRepository extends Fake
    implements
        WorkoutRepository,
        HistoricalWorkoutImportRepository,
        HistoricalMeasurementImportRepository,
        HistoricalCustomExerciseImportRepository,
        HistoricalImportIdentity {
  _ImportRepository({
    this.failMeasurementAttempt,
    this.reuseExistingCustom = false,
    this.existingSourceWorkout = false,
  });

  final int? failMeasurementAttempt;
  final bool reuseExistingCustom;
  final bool existingSourceWorkout;
  int measurementAttempts = 0;
  final List<String> callOrder = [];
  final Map<String, String> workoutReceipts = {};
  final Map<String, String> workoutPayloadsByKey = {};
  final List<String> workoutKeys = [];
  final Map<String, String> measurementReceipts = {};
  final Map<String, String> customReceipts = {};
  final List<Map<String, dynamic>> customs = [];

  @override
  Future<Workout?> getWorkoutDetail(String workoutId) async =>
      existingSourceWorkout && workoutId == _sourceWorkoutId
      ? Workout(
          id: workoutId,
          userId: _ownerId,
          status: WorkoutStatus.completed,
          completedAt: DateTime.utc(2026, 11, 1, 11),
        )
      : null;
  @override
  String get authenticatedUserId => _ownerId;
  final List<Map<String, dynamic>> workouts = [];
  final List<Map<String, dynamic>> measurements = [];

  @override
  Future<HistoricalWorkoutImportReceipt> importHistoricalWorkout({
    required String importKey,
    required Map<String, dynamic> payload,
  }) async {
    workoutKeys.add(importKey);
    callOrder.add('workout');
    if (workoutReceipts.containsKey(importKey)) {
      if (workoutPayloadsByKey[importKey] != jsonEncode(payload)) {
        throw StateError('conflicting import payload');
      }
      return HistoricalWorkoutImportReceipt(
        workoutId: workoutReceipts[importKey]!,
        alreadyImported: true,
      );
    }
    workouts.add(payload);
    workoutReceipts[importKey] = 'new-historical-workout';
    workoutPayloadsByKey[importKey] = jsonEncode(payload);
    return const HistoricalWorkoutImportReceipt(
      workoutId: 'new-historical-workout',
      alreadyImported: false,
    );
  }

  @override
  Future<HistoricalMeasurementImportReceipt> importHistoricalMeasurement({
    required String importKey,
    required Map<String, dynamic> payload,
  }) async {
    measurementAttempts++;
    callOrder.add('measurement');
    if (measurementAttempts == failMeasurementAttempt) {
      throw StateError('measurement failure');
    }
    if (measurementReceipts.containsKey(importKey)) {
      return HistoricalMeasurementImportReceipt(
        measurementId: measurementReceipts[importKey]!,
        alreadyImported: true,
      );
    }
    measurements.add(payload);
    measurementReceipts[importKey] = 'new-historical-measurement';
    return const HistoricalMeasurementImportReceipt(
      measurementId: 'new-historical-measurement',
      alreadyImported: false,
    );
  }

  @override
  Future<HistoricalCustomExerciseImportReceipt> importCustomExercise({
    required String importKey,
    required Map<String, dynamic> payload,
  }) async {
    callOrder.add('custom');
    final prior = customReceipts[importKey];
    if (prior != null) {
      return HistoricalCustomExerciseImportReceipt(
        exerciseId: prior,
        alreadyImported: true,
        created: !reuseExistingCustom,
      );
    }
    customs.add(payload);
    final id = payload['id'] as String;
    customReceipts[importKey] = id;
    return HistoricalCustomExerciseImportReceipt(
      exerciseId: id,
      alreadyImported: false,
      created: !reuseExistingCustom,
    );
  }
}

const _curated = Exercise(
  id: _exerciseId,
  name: 'Bench Press',
  category: 'Chest',
  equipment: 'Barbell',
  source: 'gymlvl_curated',
);

String _exportV2({
  List<Exercise> customExercises = const [],
  Exercise linkedExercise = _curated,
  String exportedAtUtc = '2026-11-02T00:00:00Z',
  bool legacyV1 = false,
}) {
  final workout = Workout(
    id: _sourceWorkoutId,
    userId: _ownerId,
    status: WorkoutStatus.completed,
    durationSeconds: 3500,
    notes: 'history note',
    startedAt: DateTime.utc(2026, 11, 1, 10),
    trainingStartedAt: DateTime.utc(2026, 11, 1, 10, 5),
    pausedSeconds: 100,
    completedAt: DateTime.utc(2026, 11, 1, 11),
  );
  final exercise = WorkoutExercise(
    id: 'source-workout-exercise',
    workoutId: workout.id,
    exerciseId: linkedExercise.id,
    orderIndex: 0,
    mode: WorkoutMode.repsWeight,
    notes: 'exercise note',
    exercise: linkedExercise,
  );
  final sets = [
    const WorkoutSet(
      id: 'warmup-set',
      workoutExerciseId: 'source-workout-exercise',
      setNumber: 1,
      reps: 5,
      weightKg: 20,
      baselineWeightKg: 10,
      restSeconds: 45,
      setType: WorkoutSetType.warmup,
      isCompleted: true,
      rpe: 5,
      rir: 3,
    ),
    const WorkoutSet(
      id: 'working-set',
      workoutExerciseId: 'source-workout-exercise',
      setNumber: 2,
      reps: 10,
      weightKg: 40,
      baselineWeightKg: 20,
      restSeconds: 90,
      setType: WorkoutSetType.workout,
      isCompleted: true,
      rpe: 8,
      rir: 2,
    ),
  ];
  final measurement = BodyMeasurement(
    id: 'source-measurement',
    userId: _ownerId,
    type: BodyMeasurementType.bodyFatPercentage,
    value: 18.5,
    unit: BodyMeasurementUnit.percent,
    measuredAt: DateTime.utc(2026, 11, 1, 7),
  );
  if (legacyV1) {
    return BackupExportService().export(
      userId: _ownerId,
      workouts: [workout],
      workoutExercises: [exercise],
      sets: sets,
      measurements: [measurement],
      preferences: const {},
      exportedAtUtc: exportedAtUtc,
    );
  }
  return BackupExportService().exportV2(
    userId: _ownerId,
    workouts: [workout],
    workoutExercises: [exercise],
    sets: sets,
    measurements: [measurement],
    customExercises: customExercises,
    exportedAtUtc: exportedAtUtc,
  );
}

void main() {
  test(
    'v2 export preserves supported history fields and omits preferences',
    () {
      final data =
          (jsonDecode(_exportV2()) as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      final workout = (data['workouts'] as List).single as Map<String, dynamic>;
      final exercise =
          (data['workout_exercises'] as List).single as Map<String, dynamic>;
      final sets = (data['workout_sets'] as List).cast<Map<String, dynamic>>();
      final measurement =
          (data['body_measurements'] as List).single as Map<String, dynamic>;

      expect(workout['training_started_at'], '2026-11-01T10:05:00.000Z');
      expect(workout['paused_seconds'], 100);
      expect(workout.containsKey('created_at'), isFalse);
      expect(exercise['mode'], 'reps-weight');
      expect(exercise['exercise_source'], 'gymlvl_curated');
      expect(sets.first['set_type'], 'warmup');
      expect(sets.first['baseline_weight_kg'], 10);
      expect(sets.first['rpe'], 5);
      expect(sets.first['rir'], 3);
      expect(sets.last['rest_seconds'], 90);
      expect(measurement['unit'], 'percent');
      expect(data.containsKey('preferences'), isFalse);
      expect(
        (jsonDecode(_exportV2())
            as Map<String, dynamic>)['unsupported_sections'],
        contains('preferences'),
      );
    },
  );

  test('v2 export includes archived custom text without media', () {
    const custom = Exercise(
      id: '94000000-0000-4000-8000-000000000021',
      name: 'Owner Lift',
      category: 'Arms',
      equipment: 'Dumbbell',
      slug: 'owner-lift',
      source: 'user',
      userId: _ownerId,
      isArchived: true,
      nameVi: 'Bài tập riêng',
    );
    final json = _exportV2(customExercises: [custom]);
    final data =
        (jsonDecode(json) as Map<String, dynamic>)['data']
            as Map<String, dynamic>;
    final customRow =
        (data['custom_exercises'] as List).single as Map<String, dynamic>;

    expect(customRow['id'], custom.id);
    expect(customRow['user_id'], _ownerId);
    expect(customRow['is_archived'], isTrue);
    expect(customRow['name_vi'], 'Bài tập riêng');
    expect(customRow['name_en'], '');
    expect(json, isNot(contains('image_url')));
  });

  test('v2 export fails closed on custom media or duplicate identity', () {
    const custom = Exercise(
      id: '94000000-0000-4000-8000-000000000021',
      name: 'Owner Lift',
      category: 'Arms',
      equipment: 'Dumbbell',
      source: 'user',
      userId: _ownerId,
      isArchived: true,
    );
    expect(
      () => _exportV2(
        customExercises: [
          custom.copyWith(imageUrl: 'https://example.invalid/never-export.jpg'),
        ],
      ),
      throwsStateError,
    );
    expect(
      () => _exportV2(customExercises: [custom, custom]),
      throwsStateError,
    );
  });

  test(
    'v2 export restores supported workout and measurement payloads',
    () async {
      final content = _exportV2();
      final repository = _ImportRepository();
      final service = BackupImportService(
        workoutRepository: repository,
        exerciseRepository: _ExerciseRepository(),
      );

      final result = await service.restore(
        jsonContent: content,
        currentUserId: _ownerId,
      );

      expect(result.success, isTrue);
      expect(result.restoredWorkoutCount, 1);
      expect(result.restoredSetCount, 2);
      expect(result.restoredMeasurementCount, 1);
      expect(repository.workouts, hasLength(1));
      expect(repository.measurements, hasLength(1));
      final payload = repository.workouts.single;
      expect(payload['training_started_at'], '2026-11-01T10:05:00.000Z');
      expect(payload['paused_seconds'], 100);
      final exercise = (payload['exercises'] as List).single as Map;
      expect(exercise['mode'], 'reps-weight');
      final sets = (exercise['sets'] as List).cast<Map<String, dynamic>>();
      expect(sets.first['set_type'], 'warmup');
      expect(sets.first['baseline_weight_kg'], 10);
      expect(sets.first['rpe'], 5);
      expect(sets.first['rir'], 3);
      expect(repository.measurements.single['unit'], 'percent');
    },
  );

  test('v2 duplicate fingerprint ignores export timestamp', () async {
    final repository = _ImportRepository();
    final service = BackupImportService(
      workoutRepository: repository,
      exerciseRepository: _ExerciseRepository(),
    );
    final imported = <String>{};
    final checked = <String>[];
    Future<bool> isDuplicate(String fingerprint) async {
      checked.add(fingerprint);
      return imported.contains(fingerprint);
    }

    final first = await service.restore(
      jsonContent: _exportV2(exportedAtUtc: '2026-11-02T00:00:00Z'),
      currentUserId: _ownerId,
      isDuplicate: isDuplicate,
      recordImported: (fingerprint) async => imported.add(fingerprint),
    );
    final second = await service.restore(
      jsonContent: _exportV2(exportedAtUtc: '2026-11-03T00:00:00Z'),
      currentUserId: _ownerId,
      isDuplicate: isDuplicate,
      recordImported: (fingerprint) async => imported.add(fingerprint),
    );

    expect(first.success, isTrue);
    expect(second.success, isTrue);
    expect(second.skippedDuplicateCount, 1);
    expect(checked, hasLength(2));
    expect(checked[0], checked[1]);
    expect(checked[0], startsWith('backup:v2:sha256:'));
    expect(repository.workouts, hasLength(1));
    expect(repository.measurements, hasLength(1));
  });

  test(
    'v2 restores archived custom before its historical workout link',
    () async {
      const custom = Exercise(
        id: '94000000-0000-4000-8000-000000000021',
        name: 'Owner Lift',
        category: 'Arms',
        equipment: 'Dumbbell',
        slug: 'owner-lift',
        source: 'user',
        userId: _ownerId,
        isArchived: true,
        nameVi: 'Bài tập riêng',
      );
      final repository = _ImportRepository();
      final service = BackupImportService(
        workoutRepository: repository,
        exerciseRepository: _ExerciseRepository(),
      );
      final content = _exportV2(
        customExercises: [custom],
        linkedExercise: custom,
      );
      final result = await service.restore(
        jsonContent: content,
        currentUserId: _ownerId,
      );

      expect(
        result.success,
        isTrue,
        reason: result.errors.map((e) => e.code).join(','),
      );
      expect(result.restoredCustomExerciseCount, 1);
      expect(repository.callOrder, ['custom', 'workout', 'measurement']);
      expect(repository.customs.single['id'], custom.id);
      expect(repository.customs.single['is_archived'], isTrue);
      expect(repository.customs.single['name_en'], '');
      final linked =
          (repository.workouts.single['exercises'] as List).single as Map;
      expect(linked['exercise_id'], custom.id);
      expect(linked['exercise_source'], 'user');
    },
  );

  test(
    'v2 existing identical custom receipt is not counted as newly restored',
    () async {
      const custom = Exercise(
        id: '94000000-0000-4000-8000-000000000021',
        name: 'Owner Lift',
        category: 'Arms',
        equipment: 'Dumbbell',
        slug: 'owner-lift',
        source: 'user',
        userId: _ownerId,
        isArchived: true,
      );
      final repository = _ImportRepository(reuseExistingCustom: true);
      final result =
          await BackupImportService(
            workoutRepository: repository,
            exerciseRepository: _ExerciseRepository(),
          ).restore(
            jsonContent: _exportV2(customExercises: [custom]),
            currentUserId: _ownerId,
          );

      expect(result.success, isTrue);
      expect(result.restoredCustomExerciseCount, 0);
      expect(repository.customs, hasLength(1));
    },
  );

  test(
    'v2 measurement failure leaves fingerprint unrecorded for retry',
    () async {
      final repository = _ImportRepository(failMeasurementAttempt: 1);
      final service = BackupImportService(
        workoutRepository: repository,
        exerciseRepository: _ExerciseRepository(),
      );
      final recorded = <String>[];
      final content = _exportV2();

      final first = await service.restore(
        jsonContent: content,
        currentUserId: _ownerId,
        recordImported: (fingerprint) async => recorded.add(fingerprint),
      );
      expect(first.success, isFalse);
      expect(first.restoredWorkoutCount, 1);
      expect(first.restoredMeasurementCount, 0);
      expect(recorded, isEmpty);

      final retry = await service.restore(
        jsonContent: content,
        currentUserId: _ownerId,
        recordImported: (fingerprint) async => recorded.add(fingerprint),
      );
      expect(retry.success, isTrue);
      expect(retry.restoredWorkoutCount, 0);
      expect(retry.restoredMeasurementCount, 1);
      expect(retry.skippedDuplicateCount, 1);
      expect(repository.workouts, hasLength(1));
      expect(repository.measurements, hasLength(1));
      expect(recorded, hasLength(1));
    },
  );

  test('v2 refuses to clone an existing same-owner source workout', () async {
    final repository = _ImportRepository(existingSourceWorkout: true);
    final recorded = <String>[];
    final result =
        await BackupImportService(
          workoutRepository: repository,
          exerciseRepository: _ExerciseRepository(),
        ).restore(
          jsonContent: _exportV2(),
          currentUserId: _ownerId,
          recordImported: (fingerprint) async => recorded.add(fingerprint),
        );

    expect(result.success, isFalse);
    expect(result.errors.any((e) => e.code == 'source_workout_exists'), isTrue);
    expect(repository.callOrder, isEmpty);
    expect(recorded, isEmpty);
  });

  test(
    'v1 then richer v2 uses one source key and fails digest conflict',
    () async {
      final repository = _ImportRepository();
      final service = BackupImportService(
        workoutRepository: repository,
        exerciseRepository: _ExerciseRepository(),
      );
      final v1 = await service.restore(
        jsonContent: _exportV2(legacyV1: true),
        currentUserId: _ownerId,
      );
      final v2 = await service.restore(
        jsonContent: _exportV2(),
        currentUserId: _ownerId,
      );

      expect(
        v1.success,
        isTrue,
        reason: v1.errors.map((e) => e.code).join(','),
      );
      expect(v2.success, isFalse);
      expect(v2.errors.any((e) => e.code == 'workout_restore_failed'), isTrue);
      expect(repository.workoutKeys, hasLength(2));
      expect(
        repository.workoutKeys.first,
        startsWith('backup:workout:sha256:'),
      );
      expect(repository.workoutKeys.last, repository.workoutKeys.first);
      expect(repository.workouts, hasLength(1));
    },
  );

  test('v2 duplicate graph IDs fail before any import receipt', () async {
    const custom = Exercise(
      id: '94000000-0000-4000-8000-000000000021',
      name: 'Owner Lift',
      category: 'Arms',
      equipment: 'Dumbbell',
      slug: 'owner-lift',
      source: 'user',
      userId: _ownerId,
    );
    for (final section in [
      'workouts',
      'workout_exercises',
      'workout_sets',
      'body_measurements',
      'custom_exercises',
    ]) {
      final raw =
          jsonDecode(_exportV2(customExercises: [custom]))
              as Map<String, dynamic>;
      final data = raw['data'] as Map<String, dynamic>;
      final records = data[section] as List;
      records.add(Map<String, dynamic>.from(records.first as Map));
      final content = jsonEncode(raw);
      final repository = _ImportRepository();
      final service = BackupImportService(
        workoutRepository: repository,
        exerciseRepository: _ExerciseRepository(),
      );
      final recorded = <String>[];

      expect(service.preview(content).canRestore, isFalse, reason: section);
      final result = await service.restore(
        jsonContent: content,
        currentUserId: _ownerId,
        recordImported: (fingerprint) async => recorded.add(fingerprint),
      );
      expect(result.success, isFalse, reason: section);
      expect(result.errors, isNotEmpty, reason: section);
      expect(repository.callOrder, isEmpty, reason: section);
      expect(recorded, isEmpty, reason: section);
    }
  });
}
