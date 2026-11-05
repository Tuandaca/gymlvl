/// Exercise-level progress / history computed from completed workouts.
///
/// For a single catalogue exercise this returns the completed-session
/// history, working sets, weight, reps, estimated 1RM and PR markers, in
/// deterministic chronological order. Warm-up sets are excluded from
/// working-set progression. Only completed workouts are considered.
///
/// All values are client-side estimates. `ProgressionEngine` (Epley 1RM and
/// PR detection semantics) is reused; `complete_workout` remains the sole
/// reward path. This engine never writes XP, levels, streaks, PRs, or
/// completed workouts. Identical input always yields identical output
/// (no clock, locale, or random dependence).
library;

import 'package:app/features/progression/domain/progression_engine.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'exercise_progress_models.dart';

/// Round [value] to 2 decimal places deterministically.
double _round2(double value) {
  if (!value.isFinite) return 0.0;
  return (value * 100).round() / 100;
}

/// Engine that derives per-exercise progress from completed workout history.
class ExerciseProgressEngine {
  /// Progress for [exerciseId] across [workouts].
  ///
  /// [nameById] optionally maps exercise ID to display name; when a workout's
  /// nested exercise carries a name it takes precedence. Sessions with no
  /// completed working sets are omitted. Results are sorted ascending by
  /// completion time (then workout ID) for deterministic output. Returns an
  /// empty [ExerciseProgressResult] when no history exists.
  ExerciseProgressResult progressForExercise({
    required List<Workout> workouts,
    required String exerciseId,
    required Map<String, String> nameById,
  }) {
    final completed = <Workout>[];
    for (final w in workouts) {
      if (w.status != WorkoutStatus.completed || w.completedAt == null) {
        continue;
      }
      completed.add(w);
    }
    completed.sort((a, b) {
      final c = a.completedAt!.compareTo(b.completedAt!);
      if (c != 0) return c;
      return a.id.compareTo(b.id);
    });

    final sessions = <ExerciseSessionEntry>[];
    double maxWeightSoFar = 0;
    int maxRepsAtMax = 0;
    bool haveMax = false;

    for (final w in completed) {
      WorkoutExercise? target;
      for (final we in w.exercises) {
        if (we.exerciseId == exerciseId) {
          target = we;
          break;
        }
      }
      if (target == null) continue;

      final workingSets = target.sets
          .where((s) => s.isCompleted && !s.isWarmup)
          .toList();
      if (workingSets.isEmpty) continue;

      double bestWeight = 0;
      int bestReps = 0;
      int totalReps = 0;
      double totalVolume = 0;
      for (final s in workingSets) {
        totalReps += s.reps;
        totalVolume += s.reps * s.weightKg;
        if (s.weightKg > bestWeight ||
            (s.weightKg == bestWeight && s.reps > bestReps)) {
          bestWeight = s.weightKg;
          bestReps = s.reps;
        }
      }

      final estimated1rm = ProgressionEngine.calculateOneRepMax(
        weightKg: bestWeight,
        reps: bestReps,
      );

      bool isWeightPr = false;
      bool isRepsPr = false;
      if (!haveMax) {
        // First recorded session: any completed working set is a weight PR.
        isWeightPr = true;
        maxWeightSoFar = bestWeight;
        maxRepsAtMax = bestReps;
        haveMax = true;
      } else if (bestWeight > maxWeightSoFar) {
        isWeightPr = true;
        maxWeightSoFar = bestWeight;
        maxRepsAtMax = bestReps;
      } else if (bestWeight == maxWeightSoFar && bestReps > maxRepsAtMax) {
        isRepsPr = true;
        maxRepsAtMax = bestReps;
      }

      final String prKind;
      if (isWeightPr && isRepsPr) {
        prKind = 'both';
      } else if (isWeightPr) {
        prKind = 'weight';
      } else if (isRepsPr) {
        prKind = 'reps';
      } else {
        prKind = 'none';
      }

      final exerciseName = target.exercise?.name.isNotEmpty == true
          ? target.exercise!.name
          : (nameById[exerciseId] ?? exerciseId);

      sessions.add(
        ExerciseSessionEntry(
          workoutId: w.id,
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          completedAt: w.completedAt!,
          workingSetCount: workingSets.length,
          totalReps: totalReps,
          totalVolumeKg: _round2(totalVolume),
          bestWeightKg: bestWeight,
          bestReps: bestReps,
          estimated1rm: estimated1rm,
          isWeightPr: isWeightPr,
          isRepsPr: isRepsPr,
          prKind: prKind,
        ),
      );
    }

    double maxWeightKg = 0;
    double? maxEstimated1rm;
    for (final s in sessions) {
      if (s.bestWeightKg > maxWeightKg) maxWeightKg = s.bestWeightKg;
      if (s.estimated1rm != null &&
          (maxEstimated1rm == null || s.estimated1rm! > maxEstimated1rm)) {
        maxEstimated1rm = s.estimated1rm;
      }
    }

    final exerciseName = sessions.isNotEmpty
        ? sessions.first.exerciseName
        : (nameById[exerciseId] ?? exerciseId);

    return ExerciseProgressResult(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sessions: sessions,
      sessionCount: sessions.length,
      maxWeightKg: maxWeightKg,
      maxEstimated1rm: maxEstimated1rm,
    );
  }
}
