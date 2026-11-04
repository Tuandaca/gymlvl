import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/analytics/domain/analytics_engine.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

Exercise exercise(String id, String category) => Exercise(
      id: id,
      name: 'Exercise $id',
      category: category,
      equipment: 'Barbell',
    );

Workout workout(String id, DateTime completedAt) => Workout(
      id: id,
      userId: 'user',
      status: WorkoutStatus.completed,
      completedAt: completedAt,
    );

WorkoutExercise workoutExercise(String id, String workoutId, String exerciseId) =>
      WorkoutExercise(
        id: id,
        workoutId: workoutId,
        exerciseId: exerciseId,
      );

WorkoutSet workoutSet(String id, String workoutExerciseId,
        {int reps = 10, double weightKg = 20, bool isCompleted = true,
        int durationSeconds = 0}) =>
      WorkoutSet(
        id: id,
        workoutExerciseId: workoutExerciseId,
        reps: reps,
        weightKg: weightKg,
        isCompleted: isCompleted,
        durationSeconds: durationSeconds,
      );

PrRecord prRecord(String exerciseId,
        {double maxWeightKg = 20, int maxReps = 10,
        double estimated1rm = 26.67, DateTime? updatedAt}) =>
      PrRecord(
        exerciseId: exerciseId,
        maxWeightKg: maxWeightKg,
        maxReps: maxReps,
        estimated1rm: estimated1rm,
        updatedAt: updatedAt ?? DateTime.utc(2026, 11, 1),
      );

final kChest = 'chest-exercise';
final kBack = 'back-exercise';
final kLegs = 'legs-exercise';
final kUser = 'user-11111111-1111-1111-1111-111111111111';

void main() {
  group('AnalyticsEngine empty history', () {
    test('all metrics are empty lists with no data', () {
      final engine = AnalyticsEngine();
      final result = engine.aggregate(
        workouts: [],
        sets: [],
        workoutExercises: [],
        exercises: [],
        prRecords: [],
      );
      expect(result.heatmap, isEmpty);
      expect(result.weightTrend, isEmpty);
      expect(result.prChart, isEmpty);
      expect(result.muscleBalance, isEmpty);
    });
  });

  group('single workout', () {
    test('heatmap, weight trend and muscle balance aggregate correctly', () {
      final engine = AnalyticsEngine();
      final completedAt = DateTime.utc(2026, 11, 3, 10, 0, 0);
      final we1 = workoutExercise('we1', 'w1', kChest);
      final we2 = workoutExercise('we2', 'w1', kBack);
      final sets = [
        workoutSet('s1', 'we1', reps: 10, weightKg: 20),
        workoutSet('s2', 'we1', reps: 8, weightKg: 30),
        workoutSet('s3', 'we2', reps: 12, weightKg: 15),
      ];
      final workouts = [workout('w1', completedAt)];
      final exercises = [exercise(kChest, 'Chest'), exercise(kBack, 'Back')];

      final heatmap = engine.heatmap(workouts: workouts);
      expect(heatmap, hasLength(1));
      expect(heatmap[0].date, DateTime(2026, 11, 3));
      expect(heatmap[0].workoutCount, 1);

      final trend = engine.weightTrend(
        sets: sets,
        workoutExercises: [we1, we2],
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend, hasLength(1));
      expect(trend[0].date, DateTime(2026, 11, 3));
      // volume = 10*20 + 8*30 + 12*15 = 200 + 240 + 180 = 620
      expect(trend[0].volumeKg, 620.0);
      expect(trend[0].totalReps, 30);
      expect(trend[0].totalSets, 3);

      final balance = engine.muscleBalance(
        sets: sets,
        workoutExercises: [we1, we2],
        workouts: workouts,
        exercises: exercises,
      );
      expect(balance, hasLength(2));
      final chest = balance.firstWhere((p) => p.category == 'Chest');
      expect(chest.volumeKg, 440.0);
      expect(chest.percent, 70.97); // 440/620*100 rounded to 2 dp
      expect(chest.totalSets, 2);
    });

    test('prChart is empty when no PR records', () {
      final engine = AnalyticsEngine();
      final chart = engine.prChart(
        prRecords: [],
        exercises: [exercise(kChest, 'Chest')],
      );
      expect(chart, isEmpty);
    });
  });

  group('multiple workouts', () {
    test('heatmap counts distinct workouts per local day', () {
      final engine = AnalyticsEngine();
      final day1 = DateTime.utc(2026, 11, 3, 10, 0, 0);
      final day2 = DateTime.utc(2026, 11, 4, 10, 0, 0);
      final workouts = [
        workout('w1', day1),
        workout('w2', day1), // same local day as w1
        workout('w3', day2),
      ];
      final sets = [
        workoutSet('s1', 'we1', isCompleted: true),
        workoutSet('s2', 'we2', isCompleted: true),
        workoutSet('s3', 'we3', isCompleted: true),
      ];
      final we = [
        workoutExercise('we1', 'w1', kChest),
        workoutExercise('we2', 'w2', kChest),
        workoutExercise('we3', 'w3', kChest),
      ];
      final exercises = [exercise(kChest, 'Chest')];

      final heatmap = engine.heatmap(workouts: workouts);
      expect(heatmap, hasLength(2));
      expect(heatmap[0].date, DateTime(2026, 11, 3));
      expect(heatmap[0].workoutCount, 2);
      expect(heatmap[1].date, DateTime(2026, 11, 4));
      expect(heatmap[1].workoutCount, 1);

      final trend = engine.weightTrend(
        sets: sets,
        workoutExercises: we,
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend, hasLength(2));
      // Nov 3 has w1+w2 (2 completed sets), Nov 4 has w3 (1 completed set).
      expect(trend[0].date, DateTime(2026, 11, 3));
      expect(trend[0].totalSets, 2);
      expect(trend[0].volumeKg, 400.0);
      expect(trend[1].date, DateTime(2026, 11, 4));
      expect(trend[1].totalSets, 1);
      expect(trend[1].volumeKg, 200.0);
    });
  });

  group('deterministic aggregation', () {
    test('identical input yields identical output across runs', () {
      final engine = AnalyticsEngine();
      final completedAt = DateTime.utc(2026, 11, 3, 10, 0, 0);
      final we = workoutExercise('we1', 'w1', kChest);
      final sets = [
        workoutSet('s1', 'we1', reps: 10, weightKg: 20),
        workoutSet('s2', 'we1', reps: 5, weightKg: 40),
      ];
      final workouts = [workout('w1', completedAt)];
      final exercises = [exercise(kChest, 'Chest')];
      final prRecords = [prRecord(kChest)];

      final a = engine.aggregate(
        workouts: workouts, sets: sets,
        workoutExercises: [we], exercises: exercises,
        prRecords: prRecords,
      );
      final b = engine.aggregate(
        workouts: workouts, sets: sets,
        workoutExercises: [we], exercises: exercises,
        prRecords: prRecords,
      );
      expect(a, b);
    });
  });

  group('time window and timezone boundary', () {
    test('window excludes workouts outside start/end (UTC instants)', () {
      final engine = AnalyticsEngine();
      final inside = DateTime.utc(2026, 11, 3, 10, 0, 0);
      final outside = DateTime.utc(2026, 11, 2, 10, 0, 0);
      final sets = [
        workoutSet('s1', 'we1', reps: 10, weightKg: 20),
        workoutSet('s2', 'we2', reps: 10, weightKg: 20),
      ];
      final workouts = [
        workout('w1', inside),
        workout('w2', outside),
      ];
      final weList = [
        workoutExercise('we1', 'w1', kChest),
        workoutExercise('we2', 'w2', kChest),
      ];
      final exercises = [exercise(kChest, 'Chest')];

      final trend = engine.weightTrend(
        sets: sets,
        workoutExercises: weList,
        workouts: workouts,
        exercises: exercises,
        start: DateTime.utc(2026, 11, 3),
        end: DateTime.utc(2026, 11, 4),
      );
      expect(trend, hasLength(1));
      expect(trend[0].totalSets, 1);
    });

    test('timezone offset buckets UTC instant into correct local date', () {
      final engine = AnalyticsEngine(timezoneOffsetHours: 7);
      // 23:00 UTC on Nov 3 -> 06:00 local on Nov 4 (+7)
      final completedAt = DateTime.utc(2026, 11, 3, 23, 0, 0);
      final workouts = [workout('w1', completedAt)];

      final heatmap = engine.heatmap(workouts: workouts);
      expect(heatmap, hasLength(1));
      expect(heatmap[0].date, DateTime(2026, 11, 4));
    });
  });

  group('legacy records and inactive sets', () {
    test('null-mode completed sets count; uncompleted sets are skipped', () {
      final engine = AnalyticsEngine();
      final completedAt = DateTime.utc(2026, 11, 3, 10, 0, 0);
      final we = workoutExercise('we1', 'w1', kChest);
      final sets = [
        workoutSet('s1', 'we1', reps: 10, weightKg: 20, isCompleted: true),
        workoutSet('s2', 'we1', reps: 10, weightKg: 20, isCompleted: false),
        // timed/cardio: reps 0, weight 0, duration > 0 -> 0 volume but a set
        workoutSet('s3', 'we1', reps: 0, weightKg: 0,
            isCompleted: true, durationSeconds: 60),
      ];
      final workouts = [workout('w1', completedAt)];
      final exercises = [exercise(kChest, 'Chest')];

      final heatmap = engine.heatmap(workouts: workouts);
      expect(heatmap[0].workoutCount, 1);

      final trend = engine.weightTrend(
        sets: sets,
        workoutExercises: [we],
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend[0].totalSets, 2); // only completed sets count
      expect(trend[0].totalReps, 10);
      expect(trend[0].volumeKg, 200.0); // timed set contributes 0 volume
    });
  });

  group('exercise ID validation', () {
    test('sets with unknown exercise_id are excluded from muscle balance', () {
      final engine = AnalyticsEngine();
      final completedAt = DateTime.utc(2026, 11, 3, 10, 0, 0);
      final validWe = workoutExercise('we1', 'w1', kChest);
      final invalidWe = workoutExercise('we2', 'w1', 'unknown-exercise');
      final sets = [
        workoutSet('s1', 'we1', reps: 10, weightKg: 20),
        workoutSet('s2', 'we2', reps: 10, weightKg: 20),
      ];
      final workouts = [workout('w1', completedAt)];
      final exercises = [exercise(kChest, 'Chest')];

      final balance = engine.muscleBalance(
        sets: sets,
        workoutExercises: [validWe, invalidWe],
        workouts: workouts,
        exercises: exercises,
      );
      expect(balance, hasLength(1));
      expect(balance[0].category, 'Chest');
      expect(balance[0].totalSets, 1);

      final trend = engine.weightTrend(
        sets: sets,
        workoutExercises: [validWe, invalidWe],
        workouts: workouts,
        exercises: exercises,
      );
      expect(trend[0].totalSets, 1);
      expect(trend[0].volumeKg, 200.0);
    });
  });

  group('PR chart authoritative source', () {
    test('prChart comes from exercise_prs, never recalculated', () {
      final engine = AnalyticsEngine();
      final prRecords = [
        prRecord(kBack, maxWeightKg: 100, maxReps: 5,
            estimated1rm: 116.67, updatedAt: DateTime.utc(2026, 11, 5)),
        prRecord(kChest, maxWeightKg: 60, maxReps: 10,
            estimated1rm: 80.0, updatedAt: DateTime.utc(2026, 11, 4)),
      ];
      final exercises = [exercise(kChest, 'Chest'), exercise(kBack, 'Back')];

      final chart = engine.prChart(prRecords: prRecords, exercises: exercises);
      expect(chart, hasLength(2));
      // sorted by updatedAt descending: Back (Nov 5) first
      expect(chart[0].exerciseId, kBack);
      expect(chart[0].maxWeightKg, 100.0);
      expect(chart[0].estimated1rm, 116.67);
      expect(chart[1].exerciseId, kChest);
      expect(chart[1].exerciseName, 'Exercise chest-exercise');
    });

    test('prChart skips records with unknown exercise_id', () {
      final engine = AnalyticsEngine();
      final prRecords = [
        prRecord(kChest),
        prRecord('unknown-exercise', maxWeightKg: 50),
      ];
      final exercises = [exercise(kChest, 'Chest')];

      final chart = engine.prChart(prRecords: prRecords, exercises: exercises);
      expect(chart, hasLength(1));
      expect(chart[0].exerciseId, kChest);
    });
  });
}
