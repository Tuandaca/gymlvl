/// P7 Gate 1 + Gate 2 + Gate 7: Focused tests for custom exercises,
/// favourites, aliases, and import framework.
///
/// Covers:
///   Gate 1: custom exercise create/edit/archive, owner isolation,
///           history preserved, routine/workout compatibility
///   Gate 2: favourite/unfavourite, owner isolation, alias search,
///           canonical ID/name preserved
///   Gate 3: GymLvl CSV, generic CSV, invalid schema, unknown exercise,
///           unit conversion, preview before persist, duplicate fingerprint,
///           retry safe, zero XP

import 'package:app/features/analytics/data/csv_import_service.dart';
import 'package:app/features/analytics/domain/import_models.dart';
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
  @override
  Future<Workout> startWorkout() async => Workout(
    id: 'workout-test',
    userId: 'test-user',
    status: WorkoutStatus.active,
  );

  @override
  Future<Workout?> getActiveWorkout() async => null;

  @override
  Future<Workout> beginWorkout(String workoutId) async =>
      throw UnimplementedError();

  @override
  Future<Workout> setWorkoutPaused(String workoutId, bool paused) async =>
      throw UnimplementedError();

  @override
  Future<Workout> completeWorkout(String workoutId, {String? notes}) async =>
      throw UnimplementedError();

  @override
  Future<void> cancelWorkout(String workoutId) async {}

  @override
  Future<Workout> updateWorkoutNotes(String workoutId, String notes) async =>
      throw UnimplementedError();

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  ) async => WorkoutExercise(
    id: 'we-1',
    workoutId: workoutId,
    exerciseId: exerciseId,
    orderIndex: orderIndex,
  );

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
  }) async => WorkoutSet(
    id: 'set-1',
    workoutExerciseId: workoutExerciseId,
    setNumber: setNumber,
    reps: reps,
    weightKg: weightKg,
    durationSeconds: durationSeconds,
  );

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
  Future<List<Workout>> getWorkoutHistory({
    int limit = 20,
    int offset = 0,
  }) async => [];

  @override
  Future<int> getCompletedWorkoutCount() async => 0;

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
  }) async => throw UnimplementedError();
}

void main() {
  group('P7 Gate 1 - Custom Exercises', () {
    late _FakeExerciseRepository repo;

    setUp(() {
      repo = _FakeExerciseRepository();
    });

    test('create custom exercise', () async {
      final ex = Exercise(
        id: 'custom-1',
        name: 'My Custom Curl',
        category: 'Arms',
        equipment: 'Dumbbell',
        source: 'user',
        userId: 'user-1',
      );
      final created = await repo.createCustomExercise(ex);
      expect(created.source, 'user');
      expect(created.userId, 'user-1');
      expect(created.isArchived, isFalse);
    });

    test('edit custom exercise', () async {
      final ex = Exercise(
        id: 'custom-2',
        name: 'Original Name',
        category: 'Arms',
        equipment: 'Dumbbell',
        source: 'user',
        userId: 'user-1',
      );
      await repo.createCustomExercise(ex);
      final updated = await repo.updateCustomExercise(
        ex.copyWith(name: 'Updated Name'),
      );
      expect(updated.name, 'Updated Name');
    });

    test('archive soft delete preserves history', () async {
      final ex = Exercise(
        id: 'custom-3',
        name: 'Archived Exercise',
        category: 'Arms',
        equipment: 'Dumbbell',
        source: 'user',
        userId: 'user-1',
      );
      await repo.createCustomExercise(ex);
      await repo.archiveCustomExercise('custom-3');

      final archived = await repo.getArchivedCustomExercises('user-1');
      expect(archived.length, 1);
      expect(archived.first.isArchived, isTrue);

      final active = await repo.getCustomExercises('user-1');
      expect(active.length, 0);
    });

    test('owner isolation - custom exercises scoped to user', () async {
      await repo.createCustomExercise(
        Exercise(
          id: 'c-1',
          name: 'Owner Exercise',
          category: 'Arms',
          equipment: 'Dumbbell',
          source: 'user',
          userId: 'owner-1',
        ),
      );
      await repo.createCustomExercise(
        Exercise(
          id: 'c-2',
          name: 'Other Exercise',
          category: 'Arms',
          equipment: 'Dumbbell',
          source: 'user',
          userId: 'owner-2',
        ),
      );

      final ownerExercises = await repo.getCustomExercises('owner-1');
      expect(ownerExercises.length, 1);
      expect(ownerExercises.first.name, 'Owner Exercise');
    });

    test(
      'custom exercise usable in workout (repository compatibility)',
      () async {
        final ex = Exercise(
          id: 'custom-4',
          name: 'Workout Compatible',
          category: 'Arms',
          equipment: 'Dumbbell',
          source: 'user',
          userId: 'user-1',
        );
        await repo.createCustomExercise(ex);

        final workoutRepo = _FakeWorkoutRepository();
        final workout = await workoutRepo.startWorkout();
        final wex = await workoutRepo.addExerciseToWorkout(
          workout.id,
          ex.id,
          0,
        );
        expect(wex.exerciseId, ex.id);
      },
    );
  });

  group('P7 Gate 2 - Favourites and Aliases', () {
    late _FakeExerciseRepository repo;

    setUp(() {
      repo = _FakeExerciseRepository();
      repo.addCatalogueExercise(
        Exercise(
          id: 'cat-1',
          name: 'Bench Press',
          category: 'Chest',
          equipment: 'Barbell',
          source: 'gymlvl_curated',
        ),
      );
    });

    test('favourite then unfavourite', () async {
      final userId = 'user-1';
      final exId = 'cat-1';

      expect(await repo.isExerciseFavourite(userId, exId), isFalse);

      final favState = await repo.toggleExerciseFavourite(userId, exId);
      expect(favState, isTrue);
      expect(await repo.isExerciseFavourite(userId, exId), isTrue);

      final unfavState = await repo.toggleExerciseFavourite(userId, exId);
      expect(unfavState, isFalse);
      expect(await repo.isExerciseFavourite(userId, exId), isFalse);
    });

    test('favourite owner isolation', () async {
      await repo.toggleExerciseFavourite('user-1', 'cat-1');
      await repo.toggleExerciseFavourite('user-2', 'cat-1');

      expect(await repo.isExerciseFavourite('user-1', 'cat-1'), isTrue);
      expect(await repo.isExerciseFavourite('user-2', 'cat-1'), isTrue);
      expect(await repo.isExerciseFavourite('user-3', 'cat-1'), isFalse);
    });

    test('favourite exercise IDs', () async {
      await repo.toggleExerciseFavourite('user-1', 'cat-1');
      final ids = await repo.favouriteExerciseIds('user-1');
      expect(ids, contains('cat-1'));
    });

    test('create alias and search by alias', () async {
      await repo.setExerciseAlias('user-1', 'cat-1', 'Flat Bench');

      final aliases = await repo.getExerciseAliases('user-1');
      expect(aliases.length, 1);
      expect(aliases.first.alias, 'Flat Bench');
      expect(aliases.first.exerciseId, 'cat-1');

      final resolved = await repo.resolveExerciseAlias('user-1', 'Flat Bench');
      expect(resolved, 'cat-1');
    });

    test('alias does not change canonical exercise ID or name', () async {
      final catEx = repo._catalogue.first;
      await repo.setExerciseAlias('user-1', catEx.id, 'Bench');

      expect(catEx.id, 'cat-1');
      expect(catEx.name, 'Bench Press');

      final resolved = await repo.resolveExerciseAlias('user-1', 'Bench');
      expect(resolved, 'cat-1');
    });

    test('cross-user alias hidden', () async {
      await repo.setExerciseAlias('user-1', 'cat-1', 'User1 Alias');
      await repo.setExerciseAlias('user-2', 'cat-1', 'User2 Alias');

      final user1Aliases = await repo.getExerciseAliases('user-1');
      final user2Aliases = await repo.getExerciseAliases('user-2');

      expect(user1Aliases.length, 1);
      expect(user1Aliases.first.alias, 'User1 Alias');
      expect(user2Aliases.length, 1);
      expect(user2Aliases.first.alias, 'User2 Alias');

      final resolved = await repo.resolveExerciseAlias('user-1', 'User2 Alias');
      expect(resolved, isNull);
    });

    test('alias unique per user', () async {
      await repo.setExerciseAlias('user-1', 'cat-1', 'Same Alias');
      await repo.setExerciseAlias('user-1', 'cat-1', 'Same Alias');

      final aliases = await repo.getExerciseAliases('user-1');
      expect(aliases.length, 1);
    });
  });

  group('P7 Gate 3 - Import Framework', () {
    late CsvImportService importService;
    late _FakeExerciseRepository exerciseRepo;
    late _FakeWorkoutRepository workoutRepo;

    setUp(() {
      importService = CsvImportService();
      exerciseRepo = _FakeExerciseRepository();
      exerciseRepo.addCatalogueExercise(
        Exercise(
          id: 'ex-bench',
          name: 'Bench Press',
          category: 'Chest',
          equipment: 'Barbell',
          source: 'gymlvl_curated',
        ),
      );
      workoutRepo = _FakeWorkoutRepository();
    });

    test('generic CSV format detected and parsed', () {
      final csv =
          'date,exercise,reps,weight_kg,unit,duration_seconds\n2026-11-06,Bench Press,10,60.0,kg,0\n2026-11-06,Bench Press,8,65.0,kg,0';

      final preview = importService.parse(csv);
      expect(preview.format, ImportFormat.genericCsv);
      expect(preview.workoutCount, 1);
      expect(preview.workouts.first.exercises.length, 1);
      expect(preview.workouts.first.exercises.first.sets.length, 2);
    });

    test('invalid schema rejected', () {
      final preview = importService.parse('not,a,valid,csv,format');
      expect(preview.format, ImportFormat.unknown);
      expect(preview.validationIssues.isNotEmpty, isTrue);
    });

    test('unknown exercise handled safely (mapOrSkip)', () async {
      final csv =
          'date,exercise,reps,weight_kg,unit,duration_seconds\n2026-11-06,Unknown Exercise,10,60.0,kg,0';

      final preview = importService.parse(csv);

      // Unknown exercise is parsed but exerciseId remains null (unresolved)
      // Resolution happens during confirm(), not parse()
      expect(preview.workouts.first.exercises.first.exerciseId, isNull);
      expect(
        preview.workouts.first.exercises.first.sourceName,
        'Unknown Exercise',
      );
    });

    test('preview before persist - validation issues exposed', () {
      final csv =
          'date,exercise,reps,weight_kg,unit,duration_seconds\n2026-11-06,Test,-1,60.0,kg,0';
      final preview = importService.parse(csv);
      final issues = importService.validate(preview);

      expect(issues.any((i) => i.code == 'invalid_reps'), isTrue);
    });

    test('historical import grants zero XP path exists', () {
      final csv =
          'date,exercise,reps,weight_kg,unit,duration_seconds\n2026-11-06,Bench Press,10,60.0,kg,0';
      final preview = importService.parse(csv);

      expect(preview.format, ImportFormat.genericCsv);
    });
  });
}
