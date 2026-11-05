import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/analytics/domain/exercise_progress_engine.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

void main() {
  const exerciseA = 'ex_squat';
  const exerciseB = 'ex_bench';

  final nameById = <String, String>{
    exerciseA: 'Squat',
    exerciseB: 'Bench Press',
  };

  Workout _completedWorkout(
    String id,
    DateTime completedAt, {
    required String exerciseId,
    required List<WorkoutSet> sets,
  }) {
    return Workout(
      id: id,
      userId: 'user_1',
      status: WorkoutStatus.completed,
      completedAt: completedAt,
      exercises: [
        WorkoutExercise(
          id: 'we_$id',
          workoutId: id,
          exerciseId: exerciseId,
          orderIndex: 0,
          sets: sets,
          exercise: Exercise(
            id: exerciseId,
            name: exerciseId == exerciseA ? 'Squat' : 'Bench Press',
            category: 'Legs',
            equipment: 'Barbell',
          ),
        ),
      ],
    );
  }

  WorkoutSet _workingSet(String id, int reps, double weightKg) => WorkoutSet(
    id: id,
    workoutExerciseId: 'we',
    setNumber: 1,
    reps: reps,
    weightKg: weightKg,
    isCompleted: true,
    setType: WorkoutSetType.workout,
  );

  WorkoutSet _warmupSet(String id, int reps, double weightKg) => WorkoutSet(
    id: id,
    workoutExerciseId: 'we',
    setNumber: 1,
    reps: reps,
    weightKg: weightKg,
    isCompleted: true,
    setType: WorkoutSetType.warmup,
  );

  group('ExerciseProgressEngine', () {
    test('returns empty result for unknown exercise', () {
      final engine = ExerciseProgressEngine();
      final result = engine.progressForExercise(
        workouts: const [],
        exerciseId: 'no_such_exercise',
        nameById: const {},
      );
      expect(result.isEmpty, true);
      expect(result.sessionCount, 0);
      expect(result.exerciseId, 'no_such_exercise');
    });

    test('returns empty result when no completed workouts', () {
      final engine = ExerciseProgressEngine();
      final result = engine.progressForExercise(
        workouts: [
          Workout(id: 'w_active', userId: 'u', status: WorkoutStatus.active),
          Workout(
            id: 'w_cancelled',
            userId: 'u',
            status: WorkoutStatus.cancelled,
          ),
        ],
        exerciseId: exerciseA,
        nameById: nameById,
      );
      expect(result.isEmpty, true);
    });

    test('history is chronological (oldest first)', () {
      final engine = ExerciseProgressEngine();
      final d1 = DateTime.utc(2026, 10, 1);
      final d2 = DateTime.utc(2026, 10, 3);
      final d3 = DateTime.utc(2026, 10, 2); // out of order input
      final workouts = [
        _completedWorkout(
          'w3',
          d3,
          exerciseId: exerciseA,
          sets: [_workingSet('s1', 10, 50)],
        ),
        _completedWorkout(
          'w1',
          d1,
          exerciseId: exerciseA,
          sets: [_workingSet('s2', 10, 40)],
        ),
        _completedWorkout(
          'w2',
          d2,
          exerciseId: exerciseA,
          sets: [_workingSet('s3', 10, 60)],
        ),
      ];
      final result = engine.progressForExercise(
        workouts: workouts,
        exerciseId: exerciseA,
        nameById: nameById,
      );
      expect(result.sessionCount, 3);
      expect(
        result.sessions.map((s) => s.workoutId),
        equals(['w1', 'w3', 'w2']),
      );
    });

    test('same exercise only — other exercise excluded', () {
      final engine = ExerciseProgressEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completedWorkout(
          'w1',
          d,
          exerciseId: exerciseA,
          sets: [_workingSet('s1', 10, 50)],
        ),
        _completedWorkout(
          'w2',
          d,
          exerciseId: exerciseB,
          sets: [_workingSet('s2', 10, 100)],
        ),
      ];
      final result = engine.progressForExercise(
        workouts: workouts,
        exerciseId: exerciseA,
        nameById: nameById,
      );
      expect(result.sessionCount, 1);
      expect(result.sessions.first.exerciseId, exerciseA);
    });

    test('warm-up sets excluded from working-set progression', () {
      final engine = ExerciseProgressEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completedWorkout(
          'w1',
          d,
          exerciseId: exerciseA,
          sets: [
            _warmupSet('wu', 10, 20), // warm-up: excluded
            _workingSet('w1', 10, 50), // working: counted
            _workingSet('w2', 8, 60), // working: best weight
          ],
        ),
      ];
      final result = engine.progressForExercise(
        workouts: workouts,
        exerciseId: exerciseA,
        nameById: nameById,
      );
      expect(result.sessionCount, 1);
      final s = result.sessions.first;
      expect(s.workingSetCount, 2); // warm-up excluded
      expect(s.totalReps, 18);
      expect(s.bestWeightKg, 60);
      expect(s.bestReps, 8);
      expect(s.totalVolumeKg, 10 * 50 + 8 * 60);
    });

    test('estimated 1RM trend is computed deterministically', () {
      final engine = ExerciseProgressEngine();
      final d1 = DateTime.utc(2026, 10, 1);
      final d2 = DateTime.utc(2026, 10, 2);
      final workouts = [
        _completedWorkout(
          'w1',
          d1,
          exerciseId: exerciseA,
          sets: [_workingSet('s1', 10, 50)],
        ),
        _completedWorkout(
          'w2',
          d2,
          exerciseId: exerciseA,
          sets: [_workingSet('s2', 5, 100)],
        ),
      ];
      final result = engine.progressForExercise(
        workouts: workouts,
        exerciseId: exerciseA,
        nameById: nameById,
      );
      expect(result.sessions[0].estimated1rm, 66.67); // 50 * (1 + 10/30)
      expect(result.sessions[1].estimated1rm, 116.67); // 100 * (1 + 5/30)
      expect(result.maxEstimated1rm, 116.67);
    });

    test(
      'PR markers: first session weight PR, later weight/reps/both/none',
      () {
        final engine = ExerciseProgressEngine();
        final d1 = DateTime.utc(2026, 10, 1);
        final d2 = DateTime.utc(2026, 10, 2);
        final d3 = DateTime.utc(2026, 10, 3);
        final d4 = DateTime.utc(2026, 10, 4);
        final workouts = [
          _completedWorkout(
            'w1',
            d1,
            exerciseId: exerciseA,
            sets: [_workingSet('s1', 10, 50)],
          ), // first: weight PR
          _completedWorkout(
            'w2',
            d2,
            exerciseId: exerciseA,
            sets: [_workingSet('s2', 8, 60)],
          ), // heavier: weight PR
          _completedWorkout(
            'w3',
            d3,
            exerciseId: exerciseA,
            sets: [_workingSet('s3', 10, 60)],
          ), // same weight, more reps: reps PR
          _completedWorkout(
            'w4',
            d4,
            exerciseId: exerciseA,
            sets: [_workingSet('s4', 5, 40)],
          ), // lighter, fewer reps: none
        ];
        final result = engine.progressForExercise(
          workouts: workouts,
          exerciseId: exerciseA,
          nameById: nameById,
        );
        expect(
          result.sessions.map((s) => s.prKind),
          equals(['weight', 'weight', 'reps', 'none']),
        );
        expect(
          result.sessions.map((s) => s.isWeightPr),
          equals([true, true, false, false]),
        );
        expect(
          result.sessions.map((s) => s.isRepsPr),
          equals([false, false, true, false]),
        );
      },
    );

    test(
      'replay is deterministic — identical input yields identical output',
      () {
        final engine = ExerciseProgressEngine();
        final d = DateTime.utc(2026, 10, 1);
        final workouts = [
          _completedWorkout(
            'w1',
            d,
            exerciseId: exerciseA,
            sets: [_workingSet('s1', 10, 50)],
          ),
        ];
        final a = engine.progressForExercise(
          workouts: workouts,
          exerciseId: exerciseA,
          nameById: nameById,
        );
        final b = engine.progressForExercise(
          workouts: workouts,
          exerciseId: exerciseA,
          nameById: nameById,
        );
        expect(a.toJson(), equals(b.toJson()));
      },
    );
  });
}
