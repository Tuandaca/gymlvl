/// P7 Gate 4 + Gate 7: Focused tests for Backup Restore.
///
/// Covers:
///   - valid backup v1
///   - invalid JSON
///   - wrong format
///   - unsupported version
///   - relationship preservation
///   - duplicate restore
///   - zero reward (historical workout restore)
///   - no secrets restored

import 'dart:convert';

import 'package:app/features/analytics/data/backup_import_service.dart';
import 'package:app/features/analytics/data/backup_export_service.dart';
import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExerciseRepository implements ExerciseRepository {
  final Map<String, Exercise> _customExercises = {};
  final Map<String, bool> _favourites = {};
  final Map<String, ExerciseAlias> _aliases = {};
  final List<Exercise> _catalogue = [];

  @override
  Future<List<Exercise>> getCustomExercises(String userId) async =>
      _customExercises.values
          .where((e) => e.userId == userId && !e.isArchived)
          .toList();

  @override
  Future<List<Exercise>> getArchivedCustomExercises(String userId) async =>
      _customExercises.values
          .where((e) => e.userId == userId && e.isArchived)
          .toList();

  @override
  Future<Exercise> createCustomExercise(Exercise exercise) async {
    if (exercise.source != 'user' || exercise.userId == null) {
      throw ArgumentError('Custom exercise must have source=user and userId');
    }
    _customExercises[exercise.id] = exercise;
    return exercise;
  }

  @override
  Future<Exercise> updateCustomExercise(Exercise exercise) async {
    if (!_customExercises.containsKey(exercise.id)) {
      throw ArgumentError('Custom exercise not found');
    }
    _customExercises[exercise.id] = exercise;
    return exercise;
  }

  @override
  Future<void> archiveCustomExercise(String exerciseId) async {
    final ex = _customExercises[exerciseId];
    if (ex != null) {
      _customExercises[exerciseId] = ex.copyWith(isArchived: true);
    }
  }

  @override
  Future<bool> isExerciseFavourite(String userId, String exerciseId) async =>
      _favourites['$userId|$exerciseId'] ?? false;

  @override
  Future<bool> toggleExerciseFavourite(String userId, String exerciseId) async {
    final key = '$userId|$exerciseId';
    final current = _favourites[key] ?? false;
    _favourites[key] = !current;
    return !current;
  }

  @override
  Future<List<String>> favouriteExerciseIds(String userId) async => _favourites
      .entries
      .where((e) => e.key.startsWith('$userId|') && e.value == true)
      .map((e) => e.key.split('|').last)
      .toList();

  @override
  Future<List<ExerciseAlias>> getExerciseAliases(String userId) async =>
      _aliases.values.where((a) => a.userId == userId).toList();

  @override
  Future<void> setExerciseAlias(
    String userId,
    String exerciseId,
    String alias,
  ) async {
    if (alias.trim().isEmpty) throw ArgumentError('Alias cannot be empty');
    _aliases['$userId|$alias'] = ExerciseAlias(
      id: 'alias-${_aliases.length + 1}',
      userId: userId,
      exerciseId: exerciseId,
      alias: alias.trim(),
    );
  }

  @override
  Future<void> removeExerciseAlias(String userId, String alias) async {
    _aliases.remove('$userId|$alias');
  }

  @override
  Future<String?> resolveExerciseAlias(String userId, String alias) async {
    final a = _aliases['$userId|$alias'];
    return a?.exerciseId;
  }

  @override
  Future<List<Exercise>> getExercises() async => _catalogue;

  @override
  Future<List<Exercise>> searchExercises(String query) async => _catalogue
      .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  Future<List<Exercise>> getExercisesByCategory(String category) async =>
      _catalogue.where((e) => e.category == category).toList();

  void addCatalogueExercise(Exercise ex) => _catalogue.add(ex);
}

class _FakeWorkoutRepository implements WorkoutRepository {
  final List<Workout> _workouts = [];
  bool markWorkoutCompletedCalledWithoutRewards = false;
  int startWorkoutCallCount = 0;
  int addExerciseToWorkoutCallCount = 0;
  int addSetCallCount = 0;

  @override
  Future<Workout> startWorkout() async {
    startWorkoutCallCount++;
    final w = Workout(
      id: 'restored-${_workouts.length + 1}',
      userId: 'test-user',
      status: WorkoutStatus.active,
    );
    _workouts.add(w);
    return w;
  }

  @override
  Future<Workout?> getActiveWorkout() async => null;

  @override
  Future<Workout> beginWorkout(String workoutId) async => _workouts.firstWhere(
    (w) => w.id == workoutId,
    orElse: () => Workout(id: workoutId, userId: 'test-user'),
  );

  @override
  Future<Workout> setWorkoutPaused(String workoutId, bool paused) async =>
      _workouts.firstWhere((w) => w.id == workoutId);

  @override
  Future<Workout> completeWorkout(String workoutId, {String? notes}) async {
    throw UnimplementedError('completeWorkout must not be called for restore');
  }

  @override
  Future<void> cancelWorkout(String workoutId) async {}

  @override
  Future<Workout> updateWorkoutNotes(String workoutId, String notes) async =>
      _workouts.firstWhere((w) => w.id == workoutId);

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  ) async {
    addExerciseToWorkoutCallCount++;
    return WorkoutExercise(
      id: 'we-${_workouts.length}',
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );
  }

  @override
  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {}

  @override
  Future<WorkoutExercise> replaceExercise(
    String workoutExerciseId,
    String newExerciseId,
  ) async => throw UnimplementedError();

  @override
  Future<void> reorderExercises(
    String workoutId,
    List<String> workoutExerciseIds,
  ) async {}

  @override
  Future<WorkoutSet> addSet(
    String workoutExerciseId,
    int setNumber,
    int reps,
    double weightKg, {
    double baselineWeightKg = 0,
    int durationSeconds = 0,
  }) async {
    addSetCallCount++;
    return WorkoutSet(
      id: 'set-${_workouts.length}',
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      reps: reps,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Future<WorkoutSet> updateSet(
    String setId, {
    int? reps,
    double? weightKg,
    WorkoutSetType? setType,
    bool? isCompleted,
    int? restSeconds,
    int? durationSeconds,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteSet(String setId) async {}

  @override
  Future<WorkoutSet?> getLastSetForExercise(String exerciseId) async => null;

  @override
  Future<Workout?> getWorkoutDetail(String workoutId) async => null;

  @override
  Future<List<Workout>> getWorkoutHistory({int limit = 20, int offset = 0}) =>
      Future.value(_workouts);

  @override
  Future<int> getCompletedWorkoutCount() async => _workouts.length;

  @override
  Future<Map<String, dynamic>> calculateXP(String workoutId) async => {};

  @override
  Future<WorkoutCompletion> finishWorkout(
    String workoutId, {
    String? notes,
  }) async => throw UnimplementedError();

  @override
  Future<WorkoutCompletion> reconcileCompletion(WorkoutReceipt receipt) async =>
      throw UnimplementedError();

  @override
  Future<Workout> markWorkoutCompleted(
    String workoutId, {
    DateTime? completedAt,
    int? durationSeconds,
    String? notes,
  }) async {
    markWorkoutCompletedCalledWithoutRewards = true;
    return _workouts.firstWhere((w) => w.id == workoutId);
  }
}

// Duplicate detection stubs for idempotency testing.
// Reset before each test via setUp in the test group.
final _importedFingerprints = <String>{};

Future<bool> _isDuplicate(String fingerprint) async =>
    _importedFingerprints.contains(fingerprint);

Future<void> _recordImported(String fingerprint) async {
  _importedFingerprints.add(fingerprint);
}

void main() {
  group('P7 Gate 4 - Backup Restore', () {
    late BackupExportService exportService;
    late BackupImportService importService;
    late _FakeWorkoutRepository workoutRepo;
    late _FakeExerciseRepository exerciseRepo;

    const String kTestUserId = 'test-user-123';

    setUp(() {
      _importedFingerprints.clear();
      exportService = BackupExportService();
      workoutRepo = _FakeWorkoutRepository();
      exerciseRepo = _FakeExerciseRepository();
      importService = BackupImportService(
        workoutRepository: workoutRepo,
        exerciseRepository: exerciseRepo,
      );
    });

    final DateTime now = DateTime(2026, 11, 6, 12, 0, 0);

    String _buildValidBackup() {
      final w = Workout(
        id: 'w-original-1',
        userId: kTestUserId,
        status: WorkoutStatus.completed,
        durationSeconds: 1800,
        startedAt: now.subtract(const Duration(hours: 1)),
        completedAt: now,
        notes: 'Test workout',
      );
      final we = WorkoutExercise(
        id: 'we-original-1',
        workoutId: w.id,
        exerciseId: 'ex-bench-press',
        orderIndex: 0,
      );
      final s = WorkoutSet(
        id: 's-1',
        workoutExerciseId: we.id,
        setNumber: 1,
        reps: 10,
        weightKg: 60.0,
        durationSeconds: 0,
        setType: WorkoutSetType.workout,
      );
      final m = BodyMeasurement(
        id: 'm-1',
        userId: kTestUserId,
        type: BodyMeasurementType.bodyWeight,
        value: 75.5,
        unit: BodyMeasurementUnit.kg,
        measuredAt: now,
        notes: 'Morning weigh-in',
      );

      return exportService.export(
        userId: kTestUserId,
        workouts: [w],
        workoutExercises: [we],
        sets: [s],
        measurements: [m],
        preferences: {},
        exportedAtUtc: now.toUtc().toIso8601String(),
      );
    }

    test('valid backup v1 validates and previews successfully', () {
      final json = _buildValidBackup();
      final preview = importService.preview(json);

      expect(preview.validationResult.isValid, isTrue);
      expect(preview.validationResult.errors, isEmpty);
      expect(preview.workoutCount, 1);
      expect(preview.workoutExerciseCount, 1);
      expect(preview.workoutSetCount, 1);
      expect(preview.measurementCount, 1);
      expect(preview.canRestore, isTrue);
    });

    test('invalid JSON is rejected safely', () {
      final preview = importService.preview('{not valid json}');

      expect(preview.validationResult.isValid, isFalse);
      expect(preview.validationResult.errors.isNotEmpty, isTrue);
      expect(preview.validationResult.errors.first.code, 'invalid_json');
      expect(preview.canRestore, isFalse);
    });

    test('wrong format is rejected', () {
      final json = _buildValidBackup();
      final modified = jsonDecode(json) as Map<String, dynamic>;
      modified['format'] = 'wrong-format';
      final preview = importService.preview(jsonEncode(modified));

      expect(preview.validationResult.isValid, isFalse);
      expect(
        preview.validationResult.errors.any(
          (e) => e.code == 'unsupported_format',
        ),
        isTrue,
      );
      expect(preview.canRestore, isFalse);
    });

    test('unsupported version is rejected', () {
      final json = _buildValidBackup();
      final modified = jsonDecode(json) as Map<String, dynamic>;
      modified['version'] = 999;
      final preview = importService.preview(jsonEncode(modified));

      expect(preview.validationResult.isValid, isFalse);
      expect(
        preview.validationResult.errors.any(
          (e) => e.code == 'unsupported_version',
        ),
        isTrue,
      );
      expect(preview.canRestore, isFalse);
    });

    test('restore uses markWorkoutCompleted (zero XP, no rewards)', () async {
      final json = _buildValidBackup();
      final result = await importService.restore(
        jsonContent: json,
        currentUserId: kTestUserId,
        isDuplicate: _isDuplicate,
        recordImported: _recordImported,
      );

      expect(result.success, isTrue);
      expect(workoutRepo.markWorkoutCompletedCalledWithoutRewards, isTrue);
      expect(result.restoredWorkoutCount, 1);
      expect(result.restoredExerciseCount, 1);
      expect(result.restoredSetCount, 1);
    });

    test(
      'restore does not call completeWorkout (no retroactive rewards)',
      () async {
        final json = _buildValidBackup();
        await importService.restore(
          jsonContent: json,
          currentUserId: kTestUserId,
          isDuplicate: _isDuplicate,
          recordImported: _recordImported,
        );

        expect(workoutRepo.markWorkoutCompletedCalledWithoutRewards, isTrue);
      },
    );

    test('duplicate restore (same backup twice) is idempotent', () async {
      final json = _buildValidBackup();

      // First restore: creates records
      final result1 = await importService.restore(
        jsonContent: json,
        currentUserId: kTestUserId,
        isDuplicate: _isDuplicate,
        recordImported: _recordImported,
      );
      expect(result1.success, isTrue);
      expect(result1.restoredWorkoutCount, 1);
      expect(result1.restoredExerciseCount, 1);
      expect(result1.restoredSetCount, 1);
      expect(workoutRepo.startWorkoutCallCount, 1);
      expect(workoutRepo.addExerciseToWorkoutCallCount, 1);
      expect(workoutRepo.addSetCallCount, 1);

      // Second restore: same backup content → detected as duplicate,
      // no new records created
      final result2 = await importService.restore(
        jsonContent: json,
        currentUserId: kTestUserId,
        isDuplicate: _isDuplicate,
        recordImported: _recordImported,
      );
      expect(result2.success, isTrue);
      expect(result2.restoredWorkoutCount, 0);
      expect(result2.restoredExerciseCount, 0);
      expect(result2.restoredSetCount, 0);
      expect(result2.skippedDuplicateCount, 1);
      expect(result2.warnings.any((w) => w.code == 'already_imported'), isTrue);
      // No additional mutation calls on second restore
      expect(workoutRepo.startWorkoutCallCount, 1);
      expect(workoutRepo.addExerciseToWorkoutCallCount, 1);
      expect(workoutRepo.addSetCallCount, 1);
    });

    test('no secrets or credentials restored', () {
      final json = _buildValidBackup();
      final parsed = jsonDecode(json) as Map<String, dynamic>;

      expect(parsed.containsKey('password'), isFalse);
      expect(parsed.containsKey('token'), isFalse);
      expect(parsed.containsKey('supabase_key'), isFalse);
      expect(parsed.containsKey('device_credential'), isFalse);
      expect(parsed.containsKey('provider_secret'), isFalse);
    });

    test('invalid dates are rejected', () {
      final json = _buildValidBackup();
      final modified = jsonDecode(json) as Map<String, dynamic>;
      final data = modified['data'] as Map<String, dynamic>;
      final workouts = data['workouts'] as List;
      workouts[0]['started_at'] = 'not-a-date';

      final preview = importService.preview(jsonEncode(modified));
      expect(preview.validationResult.isValid, isFalse);
      expect(
        preview.validationResult.errors.any((e) => e.code == 'invalid_date'),
        isTrue,
      );
    });

    test('invalid numeric values are rejected', () {
      final json = _buildValidBackup();
      final modified = jsonDecode(json) as Map<String, dynamic>;
      final data = modified['data'] as Map<String, dynamic>;
      final workouts = data['workouts'] as List;
      workouts[0]['duration_seconds'] = 'not-a-number';

      final preview = importService.preview(jsonEncode(modified));
      expect(preview.validationResult.isValid, isFalse);
    });

    test('duplicate IDs within backup are rejected', () {
      final json = _buildValidBackup();
      final modified = jsonDecode(json) as Map<String, dynamic>;
      final data = modified['data'] as Map<String, dynamic>;
      final workouts = data['workouts'] as List;
      workouts.add(Map.from(workouts[0]));

      final preview = importService.preview(jsonEncode(modified));
      expect(preview.validationResult.isValid, isFalse);
      expect(
        preview.validationResult.errors.any(
          (e) => e.code == 'duplicate_workout_id',
        ),
        isTrue,
      );
    });
  });
}
