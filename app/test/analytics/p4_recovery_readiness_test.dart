import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/analytics/domain/recovery_readiness.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

void main() {
  final ref = DateTime.utc(2026, 11, 5); // reference "now"

  final chest = Exercise(
    id: 'ex_bench',
    name: 'Bench',
    category: 'Chest',
    equipment: 'Barbell',
  );
  final back = Exercise(
    id: 'ex_row',
    name: 'Row',
    category: 'Back',
    equipment: 'Barbell',
  );
  final legs = Exercise(
    id: 'ex_squat',
    name: 'Squat',
    category: 'Legs',
    equipment: 'Barbell',
  );
  final exercises = [chest, back, legs];

  Workout _completed(
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
          exercise: exercises.firstWhere((e) => e.id == exerciseId),
        ),
      ],
    );
  }

  WorkoutSet working(String id, int reps, double weightKg) => WorkoutSet(
    id: id,
    workoutExerciseId: 'we',
    setNumber: 1,
    reps: reps,
    weightKg: weightKg,
    isCompleted: true,
    setType: WorkoutSetType.workout,
  );

  List<WorkoutExercise> weFor(List<Workout> workouts) =>
      workouts.expand((w) => w.exercises).toList();
  List<WorkoutSet> setsFor(List<Workout> workouts) =>
      workouts.expand((w) => w.exercises.expand((we) => we.sets)).toList();

  group('RecoveryReadinessEngine', () {
    test('recently trained (0-1 days)', () {
      final engine = RecoveryReadinessEngine();
      final workouts = [
        _completed(
          'w1',
          ref.subtract(const Duration(hours: 10)),
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 50)],
        ),
      ];
      final insight = engine.assessReadiness(
        workouts: workouts,
        exercises: exercises,
        workoutExercises: weFor(workouts),
        sets: setsFor(workouts),
        referenceDate: ref,
      );
      expect(insight.overall, ReadinessClassification.recentlyTrained);
      expect(insight.completedWorkoutCount, 1);
      expect(insight.muscleGroups.length, 1);
      expect(insight.muscleGroups.first.category, 'Chest');
      expect(insight.muscleGroups.first.daysSinceTrained, 0);
      expect(
        insight.muscleGroups.first.classification,
        ReadinessClassification.recentlyTrained,
      );
    });

    test('moderately recovered (2-7 days)', () {
      final engine = RecoveryReadinessEngine();
      final workouts = [
        _completed(
          'w1',
          ref.subtract(const Duration(days: 4)),
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 50)],
        ),
      ];
      final insight = engine.assessReadiness(
        workouts: workouts,
        exercises: exercises,
        workoutExercises: weFor(workouts),
        sets: setsFor(workouts),
        referenceDate: ref,
      );
      expect(insight.overall, ReadinessClassification.moderatelyRecovered);
      expect(insight.muscleGroups.first.daysSinceTrained, 4);
    });

    test('long time since trained (8+ days)', () {
      final engine = RecoveryReadinessEngine();
      final workouts = [
        _completed(
          'w1',
          ref.subtract(const Duration(days: 10)),
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 50)],
        ),
      ];
      final insight = engine.assessReadiness(
        workouts: workouts,
        exercises: exercises,
        workoutExercises: weFor(workouts),
        sets: setsFor(workouts),
        referenceDate: ref,
      );
      expect(insight.overall, ReadinessClassification.longTimeSinceTrained);
      expect(insight.muscleGroups.first.daysSinceTrained, 10);
    });

    test('no history -> noHistory classification', () {
      final engine = RecoveryReadinessEngine();
      final insight = engine.assessReadiness(
        workouts: const [],
        exercises: exercises,
        workoutExercises: const [],
        sets: const [],
        referenceDate: ref,
      );
      expect(insight.overall, ReadinessClassification.noHistory);
      expect(insight.isNoHistory, true);
      expect(insight.muscleGroups, isEmpty);
      expect(insight.completedWorkoutCount, 0);
    });

    test('per muscle group: different days per group', () {
      final engine = RecoveryReadinessEngine();
      final workouts = [
        _completed(
          'w1',
          ref.subtract(const Duration(days: 1)),
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 50)],
        ),
        _completed(
          'w2',
          ref.subtract(const Duration(days: 12)),
          exerciseId: 'ex_squat',
          sets: [working('s2', 10, 50)],
        ),
      ];
      final insight = engine.assessReadiness(
        workouts: workouts,
        exercises: exercises,
        workoutExercises: weFor(workouts),
        sets: setsFor(workouts),
        referenceDate: ref,
      );
      final chest = insight.muscleGroups.firstWhere(
        (g) => g.category == 'Chest',
      );
      final legs = insight.muscleGroups.firstWhere((g) => g.category == 'Legs');
      expect(chest.classification, ReadinessClassification.recentlyTrained);
      expect(chest.daysSinceTrained, 1);
      expect(legs.classification, ReadinessClassification.longTimeSinceTrained);
      expect(legs.daysSinceTrained, 12);
      // Overall based on most recently trained group (Chest, 1 day).
      expect(insight.overall, ReadinessClassification.recentlyTrained);
    });

    test('warm-up sets do not count as training', () {
      final engine = RecoveryReadinessEngine();
      final workouts = [
        _completed(
          'w1',
          ref.subtract(const Duration(days: 1)),
          exerciseId: 'ex_bench',
          sets: [
            WorkoutSet(
              id: 'wu',
              workoutExerciseId: 'we',
              setNumber: 1,
              reps: 10,
              weightKg: 20,
              isCompleted: true,
              setType: WorkoutSetType.warmup,
            ),
          ],
        ),
      ];
      final insight = engine.assessReadiness(
        workouts: workouts,
        exercises: exercises,
        workoutExercises: weFor(workouts),
        sets: setsFor(workouts),
        referenceDate: ref,
      );
      expect(insight.overall, ReadinessClassification.noHistory);
      expect(insight.muscleGroups, isEmpty);
    });

    test('deterministic replay with same reference date', () {
      final engine = RecoveryReadinessEngine();
      final workouts = [
        _completed(
          'w1',
          ref.subtract(const Duration(days: 3)),
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 50)],
        ),
      ];
      final ss = setsFor(workouts);
      final ww = weFor(workouts);
      final a = engine.assessReadiness(
        workouts: workouts,
        exercises: exercises,
        workoutExercises: ww,
        sets: ss,
        referenceDate: ref,
      );
      final b = engine.assessReadiness(
        workouts: workouts,
        exercises: exercises,
        workoutExercises: ww,
        sets: ss,
        referenceDate: ref,
      );
      expect(a.overall, b.overall);
      expect(a.muscleGroups.length, b.muscleGroups.length);
      expect(
        a.muscleGroups.first.daysSinceTrained,
        b.muscleGroups.first.daysSinceTrained,
      );
    });
  });
}
