import 'package:app/features/training_plan/routine_engine.dart';
import 'package:app/features/training_plan/routine_models.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:flutter_test/flutter_test.dart';

RoutineExerciseConfig _config(
  String exerciseId, {
  int orderIndex = 0,
  int sets = 3,
  int reps = 10,
  double weightKg = 20,
  int? durationSeconds,
  WorkoutMode mode = WorkoutMode.repsWeight,
}) {
  return RoutineExerciseConfig(
    exerciseId: exerciseId,
    orderIndex: orderIndex,
    sets: sets,
    reps: reps,
    weightKg: weightKg,
    durationSeconds: durationSeconds,
    mode: mode,
  );
}

Routine _routine(RoutineEngine engine) {
  return engine.create(
    userId: 'user-1',
    name: 'Push Day',
    emoji: '💪',
    exercises: [
      _config('exercise-1', orderIndex: 0),
      _config('exercise-2', orderIndex: 1, weightKg: 30),
      _config('exercise-3', orderIndex: 2, weightKg: 40),
    ],
  );
}

void main() {
  const engine = RoutineEngine();

  group('RoutineEngine.create', () {
    test('creates a routine with ordered exercises and distinct ids', () {
      final routine = engine.create(
        userId: 'user-1',
        name: '  Push Day  ',
        emoji: '💪',
        exercises: [
          _config('exercise-1', orderIndex: 0),
          _config('exercise-2', orderIndex: 1, weightKg: 30),
        ],
      );

      expect(routine.name, 'Push Day');
      expect(routine.userId, 'user-1');
      expect(routine.emoji, '💪');
      expect(routine.exercises.map((e) => e.exerciseId), [
        'exercise-1',
        'exercise-2',
      ]);
      expect(routine.exercises.map((e) => e.orderIndex), [0, 1]);
      expect(
        routine.exercises.map((e) => e.id).toSet().length,
        routine.exercises.length,
      );
    });

    test('rejects an empty name', () {
      expect(
        () => engine.create(userId: 'user-1', name: '   '),
        throwsArgumentError,
      );
    });

    test('supports renaming through the immutable model', () {
      final routine = _routine(engine);
      final renamed = routine.copyWith(name: 'Upper Body');

      expect(renamed.name, 'Upper Body');
      expect(routine.name, 'Push Day');
    });
  });

  group('RoutineEngine exercise mutations', () {
    test('adds an exercise at a position and reindexes later exercises', () {
      final routine = _routine(engine);
      final updated = engine.addExercise(
        routine: routine,
        config: _config('exercise-0', orderIndex: 0, weightKg: 10),
      );

      expect(updated.exercises.map((e) => e.exerciseId), [
        'exercise-0',
        'exercise-1',
        'exercise-2',
        'exercise-3',
      ]);
      expect(updated.exercises.map((e) => e.orderIndex), [0, 1, 2, 3]);
    });

    test('removes an exercise and closes the ordering gap', () {
      final routine = _routine(engine);
      final updated = engine.removeExercise(
        routine: routine,
        routineExerciseId: routine.exercises[1].id,
      );

      expect(updated.exercises.map((e) => e.exerciseId), [
        'exercise-1',
        'exercise-3',
      ]);
      expect(updated.exercises.map((e) => e.orderIndex), [0, 1]);
    });

    test('reorders exercises and reindexes every slot', () {
      final routine = _routine(engine);
      final updated = engine.reorderExercises(
        routine: routine,
        fromIndex: 0,
        toIndex: 2,
      );

      expect(updated.exercises.map((e) => e.exerciseId), [
        'exercise-2',
        'exercise-3',
        'exercise-1',
      ]);
      expect(updated.exercises.map((e) => e.orderIndex), [0, 1, 2]);
    });

    test('replacing an exercise with a compatible mode preserves config', () {
      final routine = _routine(engine);
      final slot = routine.exercises.first;

      final replaced = engine.replaceExercise(
        routine: routine,
        routineExerciseId: slot.id,
        newExerciseId: 'exercise-99',
      );

      final updated = replaced.exercises.first;
      expect(updated.id, slot.id, reason: 'slot identity is preserved');
      expect(updated.exerciseId, 'exercise-99');
      expect(updated.mode, WorkoutMode.repsWeight);
      expect(updated.sets, slot.sets);
      expect(updated.reps, slot.reps);
      expect(updated.weightKg, slot.weightKg);
    });

    test('replacing an exercise can apply an explicit compatible config', () {
      final routine = _routine(engine);
      final slot = routine.exercises.first;

      final replaced = engine.replaceExercise(
        routine: routine,
        routineExerciseId: slot.id,
        newExerciseId: 'exercise-99',
        baseConfig: _config(
          'exercise-99',
          sets: 4,
          reps: 12,
          weightKg: 25,
          mode: WorkoutMode.repsWeight,
        ),
      );

      final updated = replaced.exercises.first;
      expect(updated.sets, 4);
      expect(updated.reps, 12);
      expect(updated.weightKg, 25);
      expect(updated.mode, WorkoutMode.repsWeight);
    });

    test('replacing with an incompatible mode resets incompatible fields', () {
      final routine = _routine(engine);
      final slot = routine.exercises.first;

      final replaced = engine.replaceExercise(
        routine: routine,
        routineExerciseId: slot.id,
        newExerciseId: 'exercise-99',
        baseConfig: _config(
          'exercise-99',
          sets: 3,
          reps: 10,
          weightKg: 20,
          durationSeconds: 60,
          mode: WorkoutMode.timed,
        ),
      );

      final updated = replaced.exercises.first;
      expect(updated.mode, WorkoutMode.timed);
      expect(updated.reps, 0);
      expect(updated.repsMin, isNull);
      expect(updated.weightKg, 0);
      expect(updated.durationSeconds, 60);
    });

    test('creates a superset group with one shared group id', () {
      final routine = _routine(engine);
      final grouped = engine.createSupersetGroup(
        routine: routine,
        positions: [0, 1],
      );

      expect(grouped.supersetGroupIds, hasLength(1));
      expect(
        grouped.exercises[0].supersetGroupId,
        grouped.supersetGroupIds.single,
      );
      expect(
        grouped.exercises[1].supersetGroupId,
        grouped.supersetGroupIds.single,
      );
      expect(grouped.exercises[0].supersetPosition, 0);
      expect(grouped.exercises[1].supersetPosition, 1);
      expect(grouped.exercises[2].supersetGroupId, isNull);
    });
  });

  group('RoutineEngine.duplicate', () {
    test('creates an independent copy with remapped identities', () {
      final source = engine.createSupersetGroup(
        routine: _routine(engine),
        positions: [0, 1],
      );

      final copy = engine.duplicate(source, newName: 'Push Day (Copy)');

      expect(copy.id, isNot(source.id));
      expect(copy.name, 'Push Day (Copy)');
      expect(
        copy.exercises.map((e) => e.exerciseId),
        source.exercises.map((e) => e.exerciseId),
      );
      expect(
        copy.exercises
            .map((e) => e.id)
            .toSet()
            .intersection(source.exercises.map((e) => e.id).toSet()),
        isEmpty,
      );
      expect(copy.supersetGroupIds, hasLength(1));
      expect(
        copy.supersetGroupIds.single,
        isNot(source.supersetGroupIds.single),
      );
      expect(
        copy.exercises.first.supersetGroupId,
        copy.supersetGroupIds.single,
      );
      expect(
        copy.exercises.first.supersetGroupId,
        isNot(source.exercises.first.supersetGroupId),
      );
    });

    test('editing a duplicate does not mutate the source routine', () {
      final source = _routine(engine);
      final copy = engine.duplicate(source);

      final editedCopy = engine.addExercise(
        routine: copy,
        config: _config('exercise-extra', orderIndex: copy.exercises.length),
      );

      expect(source.exercises, hasLength(3));
      expect(editedCopy.exercises, hasLength(4));
      expect(
        source.exercises.map((e) => e.exerciseId),
        isNot(contains('exercise-extra')),
      );
    });
  });
}
