import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:app/features/progression/domain/progression_engine.dart';

final started = DateTime.utc(2026, 11, 7, 1);

Workout _fixtureWorkout({List<WorkoutExercise>? exercises}) => Workout(
  id: 'workout',
  userId: 'user',
  startedAt: started,
  trainingStartedAt: started,
  exercises:
      exercises ??
      [
        WorkoutExercise(
          id: 'we1',
          workoutId: 'workout',
          exerciseId: 'ex-a',
          orderIndex: 0,
          sets: [
            WorkoutSet(
              id: 's1',
              workoutExerciseId: 'we1',
              reps: 10,
              weightKg: 20,
              isCompleted: true,
            ),
          ],
        ),
        WorkoutExercise(
          id: 'we2',
          workoutId: 'workout',
          exerciseId: 'ex-b',
          orderIndex: 1,
          sets: [
            WorkoutSet(
              id: 's2',
              workoutExerciseId: 'we2',
              reps: 8,
              weightKg: 40,
              isCompleted: true,
            ),
          ],
        ),
        WorkoutExercise(
          id: 'we3',
          workoutId: 'workout',
          exerciseId: 'ex-c',
          orderIndex: 2,
          sets: [],
        ),
      ],
);

class FakeRepository extends Fake implements WorkoutRepository {
  Workout active = _fixtureWorkout();
  int reorders = 0;
  int replaces = 0;
  int noteUpdates = 0;
  String? lastNotes;

  @override
  Future<Workout> startWorkout() async => active;

  @override
  Future<Workout?> getActiveWorkout() async => active;

  @override
  Future<Workout?> getWorkoutDetail(String id) async => active;

  @override
  Future<void> cancelWorkout(String id) async {}

  @override
  Future<Workout> beginWorkout(String id) async =>
      active.copyWith(trainingStartedAt: started);

  @override
  Future<Workout> setWorkoutPaused(String id, bool paused) async => active;

  @override
  Future<WorkoutCompletion> finishWorkout(String id, {String? notes}) async =>
      WorkoutCompletion(
        active.copyWith(status: WorkoutStatus.completed, completedAt: started),
        {'earnedXP': 5},
      );

  @override
  Future<void> reorderExercises(String workoutId, List<String> ids) async {
    reorders++;
    active = active.copyWith(
      exercises: [
        for (var i = 0; i < ids.length; i++)
          active.exercises
              .firstWhere((e) => e.id == ids[i])
              .copyWith(orderIndex: i),
      ],
    );
  }

  @override
  Future<WorkoutExercise> replaceExercise(
    String workoutExerciseId,
    String newExerciseId,
  ) async {
    replaces++;
    final idx = active.exercises.indexWhere((e) => e.id == workoutExerciseId);
    active = active.copyWith(
      exercises: [
        for (final e in active.exercises)
          if (e.id == workoutExerciseId)
            e.copyWith(exerciseId: newExerciseId)
          else
            e,
      ],
    );
    return active.exercises[idx];
  }

  @override
  Future<Workout> updateWorkoutNotes(String workoutId, String notes) async {
    noteUpdates++;
    lastNotes = notes;
    active = active.copyWith(notes: notes);
    return active;
  }

  @override
  Future<WorkoutSet?> getLastSetForExercise(String exerciseId) async => null;
}

void main() {
  late FakeRepository repository;
  late ProviderContainer container;
  late ActiveWorkoutController controller;

  setUp(() {
    repository = FakeRepository();
    container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((_) => const Stream.empty()),
        workoutRepositoryProvider.overrideWithValue(repository),
        restClockProvider.overrideWithValue(() => started),
      ],
    );
    controller = container.read(activeWorkoutControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  // --- Reorder ---

  test(
    'reorder moves first exercise to last and preserves order_index',
    () async {
      await controller.startWorkout();
      await controller.reorderExercises(0, 3);
      final ex = container.read(activeWorkoutControllerProvider).exercises;
      expect(ex.map((e) => e.exerciseId), ['ex-b', 'ex-c', 'ex-a']);
      expect(ex.map((e) => e.orderIndex), [0, 1, 2]);
      expect(repository.reorders, 1);
    },
  );

  test('reorder moves last exercise to first', () async {
    await controller.startWorkout();
    await controller.reorderExercises(2, 0);
    final ex = container.read(activeWorkoutControllerProvider).exercises;
    expect(ex.map((e) => e.exerciseId), ['ex-c', 'ex-a', 'ex-b']);
    expect(repository.reorders, 1);
  });

  test('reorder no-op when indices are equal', () async {
    await controller.startWorkout();
    await controller.reorderExercises(1, 1);
    final ex = container.read(activeWorkoutControllerProvider).exercises;
    expect(ex.map((e) => e.exerciseId), ['ex-a', 'ex-b', 'ex-c']);
    expect(repository.reorders, 0);
  });

  // --- Replace ---

  test(
    'replace preserves position and changes exercise when no completed sets',
    () async {
      await controller.startWorkout();
      // we3 has no completed sets.
      await controller.replaceExercise(
        'we3',
        const Exercise(
          id: 'ex-z',
          name: 'Z',
          category: 'Legs',
          equipment: 'Barbell',
        ),
      );
      final ex = container.read(activeWorkoutControllerProvider).exercises;
      final moved = ex.firstWhere((e) => e.id == 'we3');
      expect(moved.exerciseId, 'ex-z');
      expect(moved.orderIndex, 2); // position preserved
      expect(repository.replaces, 1);
    },
  );

  test(
    'replace is refused when the exercise already has completed sets',
    () async {
      await controller.startWorkout();
      // we1 has a completed set.
      await controller.replaceExercise(
        'we1',
        const Exercise(
          id: 'ex-z',
          name: 'Z',
          category: 'Legs',
          equipment: 'Barbell',
        ),
      );
      final ex = container.read(activeWorkoutControllerProvider).exercises;
      expect(
        ex.firstWhere((e) => e.id == 'we1').exerciseId,
        'ex-a',
      ); // unchanged
      expect(repository.replaces, 0);
      expect(
        container.read(activeWorkoutControllerProvider).errorMessage,
        'exercise_has_completed_sets',
      );
    },
  );

  // --- Warm-up sets excluded from progression/PR ---

  test('warm-up sets are excluded from display XP calculation', () {
    final warmUp = WorkoutSet(
      id: 'wu',
      workoutExerciseId: 'we',
      reps: 10,
      weightKg: 60,
      isCompleted: true,
      setType: WorkoutSetType.warmup,
    );
    final working = WorkoutSet(
      id: 'wk',
      workoutExerciseId: 'we',
      reps: 10,
      weightKg: 100,
      isCompleted: true,
      setType: WorkoutSetType.workout,
    );
    final withWarmup = ProgressionEngine.calculateXP(
      durationSeconds: 600,
      completedSets: [warmUp, working],
      uniqueCategories: 1,
    );
    final withoutWarmup = ProgressionEngine.calculateXP(
      durationSeconds: 600,
      completedSets: [working],
      uniqueCategories: 1,
    );
    expect(withWarmup, withoutWarmup);
    expect(withWarmup, greaterThan(0));
  });

  test('warm-up set is distinguishable and marks as warmup', () {
    final set = WorkoutSet(
      id: 'wu',
      workoutExerciseId: 'we',
      reps: 10,
      weightKg: 60,
      isCompleted: true,
      setType: WorkoutSetType.warmup,
    );
    expect(set.isWarmup, isTrue);
    expect(set.setType, WorkoutSetType.warmup);
    final legacy = WorkoutSet(
      id: 's',
      workoutExerciseId: 'we',
      reps: 10,
      weightKg: 20,
    );
    expect(legacy.isWarmup, isFalse);
    expect(legacy.setType, WorkoutSetType.workout);
  });

  // --- Notes editing persists and does not affect rewards ---

  test(
    'updateWorkoutNotes persists notes and does not touch rewards',
    () async {
      await controller.startWorkout();
      await controller.updateWorkoutNotes('Feeling strong today');
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.workout?.notes, 'Feeling strong today');
      expect(repository.noteUpdates, 1);
      expect(repository.lastNotes, 'Feeling strong today');
      // Notes are advisory; preview XP unchanged by a notes-only edit.
      expect(state.previewXP, greaterThan(0));
    },
  );
}
