/// Riverpod providers for the M5 analytics presentation.
///
/// All values are client-side estimates computed by [AnalyticsEngine] from
/// existing workout/progression data. PostgreSQL remains authoritative; this
/// provider never writes XP, levels, streaks, PRs, or completed workouts.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/analytics/domain/analytics_engine.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';

/// Aggregated analytics result for the current user.
///
/// Flattens completed workout history into the sets / workout-exercises the
/// engine expects. PR records come from the authoritative `exercise_prs`
/// table (currently none wired client-side, so an empty list).
final analyticsProvider = FutureProvider<AnalyticsResult>((ref) async {
  final workouts = await ref
      .read(workoutRepositoryProvider)
      .getWorkoutHistory();
  final exercises = await ref.read(exerciseRepositoryProvider).getExercises();

  final sets = <WorkoutSet>[];
  final workoutExercises = <WorkoutExercise>[];
  for (final w in workouts) {
    for (final we in w.exercises) {
      workoutExercises.add(we);
      sets.addAll(we.sets);
    }
  }

  return AnalyticsEngine().aggregate(
    workouts: workouts,
    sets: sets,
    workoutExercises: workoutExercises,
    exercises: exercises,
    prRecords: const [],
  );
});
