import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/analytics/domain/structural_balance.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

void main() {
  // Push exercise (force_type Push, category Chest/Shoulders/Arms).
  final pushEx = Exercise(
    id: 'ex_bench',
    name: 'Bench Press',
    category: 'Chest',
    equipment: 'Barbell',
    forceType: 'Push',
  );
  // Pull exercise (force_type Pull, category Back).
  final pullEx = Exercise(
    id: 'ex_row',
    name: 'Barbell Row',
    category: 'Back',
    equipment: 'Barbell',
    forceType: 'Pull',
  );
  // Lower-body exercise (category Legs).
  final legsEx = Exercise(
    id: 'ex_squat',
    name: 'Squat',
    category: 'Legs',
    equipment: 'Barbell',
    forceType: 'Push',
  );

  final exercises = [pushEx, pullEx, legsEx];

  Workout _completed(
    String id,
    DateTime completedAt, {
    required String exerciseId,
    required List<WorkoutSet> sets,
  }) {
    final weId = 'we_$id';
    return Workout(
      id: id,
      userId: 'user_1',
      status: WorkoutStatus.completed,
      completedAt: completedAt,
      exercises: [
        WorkoutExercise(
          id: weId,
          workoutId: id,
          exerciseId: exerciseId,
          orderIndex: 0,
          sets: sets.map((s) => s.copyWith(workoutExerciseId: weId)).toList(),
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

  group('StructuralBalanceEngine', () {
    test('classify maps push/pull/upper/lower/anterior/posterior', () {
      final engine = StructuralBalanceEngine();
      final classes = {
        for (final c in engine.classify(exercises)) c.exerciseId: c,
      };
      expect(classes['ex_bench']!.pushPull, 'push');
      expect(classes['ex_bench']!.upperLower, 'upper');
      expect(classes['ex_bench']!.anteriorPosterior, 'anterior');
      expect(classes['ex_row']!.pushPull, 'pull');
      expect(
        classes['ex_row']!.upperLower,
        isNull,
      ); // Back is neutral for upper/lower
      expect(classes['ex_row']!.anteriorPosterior, 'posterior');
      expect(classes['ex_squat']!.pushPull, 'push');
      expect(classes['ex_squat']!.upperLower, 'lower');
      expect(classes['ex_squat']!.anteriorPosterior, 'posterior');
    });

    test('balanced fixture -> balanced emphasis push/pull', () {
      final engine = StructuralBalanceEngine();
      final d = DateTime.utc(2026, 10, 1);
      // Equal push and pull volume.
      final workouts = [
        _completed(
          'w1',
          d,
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 50)],
        ), // 500 push
        _completed(
          'w2',
          d,
          exerciseId: 'ex_row',
          sets: [working('s2', 10, 50)],
        ), // 500 pull
      ];
      final result = engine.assess(
        sets: setsFor(workouts),
        workoutExercises: weFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(result.pushPull.emphasis, BalanceEmphasis.balanced);
      expect(result.pushPull.sideA.percent, 50.0);
      expect(result.pushPull.sideB.percent, 50.0);
    });

    test('upper/lower with legs -> lower present', () {
      final engine = StructuralBalanceEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed(
          'w1',
          d,
          exerciseId: 'ex_squat',
          sets: [working('s1', 10, 50)],
        ), // 500 lower
      ];
      final result = engine.assess(
        sets: setsFor(workouts),
        workoutExercises: weFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(result.upperLower.sideB.percent, 100.0); // legs = lower = sideB
      expect(result.upperLower.emphasis, BalanceEmphasis.sideBDominant);
    });

    test('push-heavy fixture -> push dominant', () {
      final engine = StructuralBalanceEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed(
          'w1',
          d,
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 100)],
        ), // 1000 push
        _completed(
          'w2',
          d,
          exerciseId: 'ex_row',
          sets: [working('s2', 10, 20)],
        ), // 200 pull
      ];
      final result = engine.assess(
        sets: setsFor(workouts),
        workoutExercises: weFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(result.pushPull.emphasis, BalanceEmphasis.sideADominant);
      expect(result.pushPull.sideA.percent, greaterThan(60.0));
      expect(result.pushPull.anyUnderTrained, true); // pull < 40%
    });

    test('pull-heavy fixture -> pull dominant', () {
      final engine = StructuralBalanceEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed(
          'w1',
          d,
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 20)],
        ), // 200 push
        _completed(
          'w2',
          d,
          exerciseId: 'ex_row',
          sets: [working('s2', 10, 100)],
        ), // 1000 pull
      ];
      final result = engine.assess(
        sets: setsFor(workouts),
        workoutExercises: weFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(result.pushPull.emphasis, BalanceEmphasis.sideBDominant);
      expect(result.pushPull.sideB.percent, greaterThan(60.0));
    });

    test('empty inputs yield balanced empty splits', () {
      final engine = StructuralBalanceEngine();
      final result = engine.assess(
        sets: const [],
        workoutExercises: const [],
        workouts: const [],
        exercises: const [],
      );
      expect(result.pushPull.sideA.percent, 0.0);
      expect(result.pushPull.sideB.percent, 0.0);
      expect(result.pushPull.emphasis, BalanceEmphasis.balanced);
      expect(result.categoryDistribution, isEmpty);
    });

    test('deterministic replay', () {
      final engine = StructuralBalanceEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed(
          'w1',
          d,
          exerciseId: 'ex_bench',
          sets: [working('s1', 10, 50)],
        ),
        _completed(
          'w2',
          d,
          exerciseId: 'ex_row',
          sets: [working('s2', 10, 50)],
        ),
      ];
      final ss = setsFor(workouts);
      final ww = weFor(workouts);
      final a = engine.assess(
        sets: ss,
        workoutExercises: ww,
        workouts: workouts,
        exercises: exercises,
      );
      final b = engine.assess(
        sets: ss,
        workoutExercises: ww,
        workouts: workouts,
        exercises: exercises,
      );
      expect(a.pushPull.sideA.percent, b.pushPull.sideA.percent);
      expect(a.pushPull.emphasis, b.pushPull.emphasis);
    });
  });
}
