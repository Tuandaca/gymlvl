import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/analytics/domain/analytics_engine.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

void main() {
  const exA = 'ex_squat';
  const exB = 'ex_bench';

  final exercises = [
    Exercise(id: exA, name: 'Squat', category: 'Legs', equipment: 'Barbell'),
    Exercise(
      id: exB,
      name: 'Bench Press',
      category: 'Chest',
      equipment: 'Barbell',
    ),
  ];

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

  WorkoutSet warmup(String id, int reps, double weightKg) => WorkoutSet(
    id: id,
    workoutExerciseId: 'we',
    setNumber: 1,
    reps: reps,
    weightKg: weightKg,
    isCompleted: true,
    setType: WorkoutSetType.warmup,
  );

  List<WorkoutExercise> workoutExercisesFor(List<Workout> workouts) =>
      workouts.expand((w) => w.exercises).toList();

  List<WorkoutSet> allSets(List<Workout> workouts) =>
      workouts.expand((w) => w.exercises.expand((we) => we.sets)).toList();

  bool sameCalendarDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  group('P4 AnalyticsEngine', () {
    test('oneRepMaxTrend computes best daily 1RM', () {
      final engine = AnalyticsEngine();
      final d1 = DateTime.utc(2026, 10, 1, 10);
      final d2 = DateTime.utc(2026, 10, 1, 16); // same local day
      final d3 = DateTime.utc(2026, 10, 2);
      final workouts = [
        _completed(
          'w1',
          d1,
          exerciseId: exA,
          sets: [working('s1', 10, 50)],
        ), // 1RM 66.67
        _completed(
          'w2',
          d2,
          exerciseId: exA,
          sets: [working('s2', 5, 100)],
        ), // 1RM 116.67 -> day max
        _completed(
          'w3',
          d3,
          exerciseId: exA,
          sets: [working('s3', 10, 40)],
        ), // 1RM 53.33
      ];
      final trend = engine.oneRepMaxTrend(
        sets: allSets(workouts),
        workoutExercises: workoutExercisesFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend.length, 2);
      expect(trend[0].estimated1rm, 116.67); // day 1 max of 66.67 and 116.67
      expect(trend[1].estimated1rm, 53.33);
    });

    test('oneRepMaxTrend excludes warm-up sets', () {
      final engine = AnalyticsEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed(
          'w1',
          d,
          exerciseId: exA,
          sets: [
            warmup('wu', 10, 120), // warm-up: excluded (would be 152 1RM)
            working('s1', 10, 50), // working: 66.67
          ],
        ),
      ];
      final trend = engine.oneRepMaxTrend(
        sets: allSets(workouts),
        workoutExercises: workoutExercisesFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend.length, 1);
      expect(trend.first.estimated1rm, 66.67);
    });

    test('exerciseStrengthTrend per exercise per day', () {
      final engine = AnalyticsEngine();
      final d1 = DateTime.utc(2026, 10, 1);
      final d2 = DateTime.utc(2026, 10, 2);
      final workouts = [
        _completed('w1', d1, exerciseId: exA, sets: [working('s1', 10, 50)]),
        _completed('w2', d1, exerciseId: exB, sets: [working('s2', 10, 60)]),
        _completed('w3', d2, exerciseId: exA, sets: [working('s3', 10, 70)]),
      ];
      final trend = engine.exerciseStrengthTrend(
        sets: allSets(workouts),
        workoutExercises: workoutExercisesFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend.length, 3);
      // Sorted by exercise name then date: Bench Press (exB), Squat (exA) d1, Squat d2
      expect(trend[0].exerciseId, exB);
      expect(trend[1].exerciseId, exA);
      expect(sameCalendarDate(trend[1].date, d1), true);
      expect(trend[2].exerciseId, exA);
      expect(sameCalendarDate(trend[2].date, d2), true);
      expect(trend[2].maxWeightKg, 70);
    });

    test('exerciseStrengthTrend excludes warm-up sets', () {
      final engine = AnalyticsEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed(
          'w1',
          d,
          exerciseId: exA,
          sets: [warmup('wu', 10, 120), working('s1', 10, 50)],
        ),
      ];
      final trend = engine.exerciseStrengthTrend(
        sets: allSets(workouts),
        workoutExercises: workoutExercisesFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend.length, 1);
      expect(trend.first.maxWeightKg, 50);
    });

    test('time range filtering excludes out-of-window workouts', () {
      final engine = AnalyticsEngine();
      final now = DateTime.utc(2026, 11, 5);
      final inWindow = now.subtract(const Duration(days: 10));
      final outOfWindow = now.subtract(const Duration(days: 40));
      final workouts = [
        _completed(
          'w1',
          inWindow,
          exerciseId: exA,
          sets: [working('s1', 10, 50)],
        ),
        _completed(
          'w2',
          outOfWindow,
          exerciseId: exA,
          sets: [working('s2', 10, 100)],
        ),
      ];
      final start = TimeRange.fourWeeks.start(now: now)!;
      final trend = engine.oneRepMaxTrend(
        sets: allSets(workouts),
        workoutExercises: workoutExercisesFor(workouts),
        workouts: workouts,
        exercises: exercises,
        start: start,
        end: now,
      );
      expect(trend.length, 1);
      expect(trend.first.estimated1rm, 66.67);
    });

    test('volume trend sums reps * weight_kg per day', () {
      final engine = AnalyticsEngine();
      final d1 = DateTime.utc(2026, 10, 1);
      final d2 = DateTime.utc(2026, 10, 2);
      final workouts = [
        _completed(
          'w1',
          d1,
          exerciseId: exA,
          sets: [working('s1', 10, 50)],
        ), // 500
        _completed(
          'w2',
          d1,
          exerciseId: exA,
          sets: [working('s2', 5, 40)],
        ), // 200 -> day total 700
        _completed(
          'w3',
          d2,
          exerciseId: exA,
          sets: [working('s3', 10, 60)],
        ), // 600
      ];
      final trend = engine.weightTrend(
        sets: allSets(workouts),
        workoutExercises: workoutExercisesFor(workouts),
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend.length, 2);
      expect(trend[0].volumeKg, 700.0);
      expect(trend[1].volumeKg, 600.0);
    });

    test('heatmap counts distinct completed workouts per day', () {
      final engine = AnalyticsEngine();
      final d1 = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed('w1', d1, exerciseId: exA, sets: [working('s1', 10, 50)]),
        _completed(
          'w2',
          d1,
          exerciseId: exB,
          sets: [working('s2', 10, 60)],
        ), // same day
        Workout(
          id: 'w_active',
          userId: 'u',
          status: WorkoutStatus.active,
        ), // not completed
      ];
      final heatmap = engine.heatmap(workouts: workouts);
      expect(heatmap.length, 1);
      expect(heatmap.first.workoutCount, 2);
    });

    test('empty inputs yield empty results', () {
      final engine = AnalyticsEngine();
      expect(
        engine.oneRepMaxTrend(
          sets: const [],
          workoutExercises: const [],
          workouts: const [],
          exercises: const [],
        ),
        isEmpty,
      );
      expect(
        engine.exerciseStrengthTrend(
          sets: const [],
          workoutExercises: const [],
          workouts: const [],
          exercises: const [],
        ),
        isEmpty,
      );
      expect(
        engine.weightTrend(
          sets: const [],
          workoutExercises: const [],
          workouts: const [],
          exercises: const [],
        ),
        isEmpty,
      );
      expect(engine.heatmap(workouts: const []), isEmpty);
    });

    test('deterministic replay', () {
      final engine = AnalyticsEngine();
      final d = DateTime.utc(2026, 10, 1);
      final workouts = [
        _completed('w1', d, exerciseId: exA, sets: [working('s1', 10, 50)]),
      ];
      final sets = allSets(workouts);
      final workoutExercises = workoutExercisesFor(workouts);
      final a = engine.oneRepMaxTrend(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
      );
      final b = engine.oneRepMaxTrend(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
      );
      expect(a, equals(b));
    });
  });
}
