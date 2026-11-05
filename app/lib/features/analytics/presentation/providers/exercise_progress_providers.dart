/// Riverpod providers for the P4 exercise-level progress / history feature.
///
/// All values are client-side estimates computed from completed workout
/// history. PostgreSQL remains authoritative; this provider never writes XP,
/// levels, streaks, PRs, or completed workouts.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/analytics/domain/exercise_progress_engine.dart';
import 'package:app/features/analytics/domain/exercise_progress_models.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';

/// Generous cap on completed workouts fetched for a progress preview. This is
/// a UI preview, not the authoritative record; the engine is deterministic for
/// whatever set of workouts is supplied.
const int kExerciseProgressHistoryLimit = 500;

/// Progress entries for a single exercise, in chronological order.
///
/// Returns an empty list when the exercise has no completed working-set
/// history. [exerciseId] must be a valid catalogue exercise ID.
final exerciseProgressProvider =
    FutureProvider.family<List<ExerciseSessionEntry>, String>((
      ref,
      exerciseId,
    ) async {
      final workouts = await ref
          .read(workoutRepositoryProvider)
          .getWorkoutHistory(limit: kExerciseProgressHistoryLimit, offset: 0);
      final exercises = await ref
          .read(exerciseRepositoryProvider)
          .getExercises();
      final nameById = <String, String>{};
      for (final e in exercises) {
        nameById[e.id] = e.name;
      }
      final result = ExerciseProgressEngine().progressForExercise(
        workouts: workouts,
        exerciseId: exerciseId,
        nameById: nameById,
      );
      return result.sessions;
    });
