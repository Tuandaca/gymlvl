/// P4 Gate 5: Deterministic recovery / readiness insight.
///
/// Lightweight, non-clinical readiness computed from existing completed
/// workout history. For each muscle group (exercise category) it reports how
/// many days have elapsed since it was last trained and classifies it into a
/// descriptive bucket. Output is informational only — it describes training
/// distribution and relative emphasis, NOT physiological certainty or medical
/// diagnosis. No wearable/HRV/sleep data is used (Health integrations are out
/// of scope).
///
/// All values are client-side estimates. `complete_workout` remains the sole
/// reward path; this module never writes XP, levels, streaks, or completed
/// workouts. Identical input always yields identical output given the same
/// reference date (no clock beyond the explicit reference).
library;

import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

/// Descriptive readiness classification.
enum ReadinessClassification {
  /// Trained within the last 0-1 days.
  recentlyTrained,

  /// Trained 2-7 days ago.
  moderatelyRecovered,

  /// Not trained for 8+ days.
  longTimeSinceTrained,

  /// No completed workout history at all.
  noHistory,
}

extension ReadinessClassificationX on ReadinessClassification {
  /// Localization key for the user-facing label.
  String get labelKey {
    switch (this) {
      case ReadinessClassification.recentlyTrained:
        return 'readiness_recently_trained';
      case ReadinessClassification.moderatelyRecovered:
        return 'readiness_moderately_recovered';
      case ReadinessClassification.longTimeSinceTrained:
        return 'readiness_long_since_trained';
      case ReadinessClassification.noHistory:
        return 'readiness_no_history';
    }
  }
}

/// Thresholds (days since a muscle group was last trained).
const int kRecentlyTrainedMaxDays = 1;
const int kModeratelyRecoveredMaxDays = 7;

/// Readiness for a single muscle group (exercise category).
class MuscleGroupReadiness {
  /// Exercise category (muscle group).
  final String category;

  /// Days since this group was last trained (whole days, floored).
  final int daysSinceTrained;

  /// The readiness classification.
  final ReadinessClassification classification;

  /// ISO-8601 UTC of the most recent completed workout touching this group,
  /// or null when never trained.
  final DateTime? lastTrainedAt;

  const MuscleGroupReadiness({
    required this.category,
    required this.daysSinceTrained,
    required this.classification,
    this.lastTrainedAt,
  });

  /// Human-readable label localization key.
  String get labelKey => classification.labelKey;
}

/// Overall readiness insight.
class ReadinessInsight {
  /// Overall classification (based on the most recently trained muscle group).
  final ReadinessClassification overall;

  /// Per-muscle-group readiness (empty when no history).
  final List<MuscleGroupReadiness> muscleGroups;

  /// Total completed workouts considered.
  final int completedWorkoutCount;

  /// Most recent completed workout date (UTC), or null when none.
  final DateTime? mostRecentWorkoutAt;

  /// True when there is no completed workout history.
  bool get isNoHistory => overall == ReadinessClassification.noHistory;

  const ReadinessInsight({
    required this.overall,
    required this.muscleGroups,
    required this.completedWorkoutCount,
    this.mostRecentWorkoutAt,
  });
}

/// Classifies a day offset into a readiness bucket.
ReadinessClassification _classifyDays(int daysSinceTrained) {
  if (daysSinceTrained <= kRecentlyTrainedMaxDays) {
    return ReadinessClassification.recentlyTrained;
  }
  if (daysSinceTrained <= kModeratelyRecoveredMaxDays) {
    return ReadinessClassification.moderatelyRecovered;
  }
  return ReadinessClassification.longTimeSinceTrained;
}

/// Engine that computes deterministic recovery / readiness from history.
class RecoveryReadinessEngine {
  /// Assess overall and per-muscle-group readiness.
  ///
  /// [referenceDate] is the "now" used to compute elapsed days (UTC midnight).
  /// Only completed workouts with completed sets are considered; warm-up sets
  /// do not count as training a muscle group. Returns [ReadinessInsight] with
  /// [ReadinessClassification.noHistory] when there is no completed history.
  ReadinessInsight assessReadiness({
    required List<Workout> workouts,
    required List<Exercise> exercises,
    required List<WorkoutExercise> workoutExercises,
    required List<WorkoutSet> sets,
    required DateTime referenceDate,
  }) {
    final completed = <Workout>[];
    for (final w in workouts) {
      if (w.status != WorkoutStatus.completed || w.completedAt == null) {
        continue;
      }
      completed.add(w);
    }

    if (completed.isEmpty) {
      return const ReadinessInsight(
        overall: ReadinessClassification.noHistory,
        muscleGroups: [],
        completedWorkoutCount: 0,
        mostRecentWorkoutAt: null,
      );
    }

    final nameByCategory = <String, String>{};
    for (final e in exercises) {
      nameByCategory[e.id] = e.category;
    }
    final weById = <String, WorkoutExercise>{};
    for (final we in workoutExercises) {
      weById[we.id] = we;
    }

    // Most recent completed-at per category (UTC instant).
    final lastByCategory = <String, DateTime>{};
    for (final w in completed) {
      for (final we in w.exercises) {
        final hasCompletedSet = we.sets.any(
          (s) => s.isCompleted && !s.isWarmup,
        );
        if (!hasCompletedSet) continue;
        final category = nameByCategory[we.exerciseId];
        if (category == null) continue;
        final instant = w.completedAt!;
        final existing = lastByCategory[category];
        if (existing == null || instant.isAfter(existing)) {
          lastByCategory[category] = instant;
        }
      }
    }

    if (lastByCategory.isEmpty) {
      // Completed workouts exist but none trained a muscle group (e.g. only
      // warm-up sets). Treat as no meaningful history.
      return ReadinessInsight(
        overall: ReadinessClassification.noHistory,
        muscleGroups: [],
        completedWorkoutCount: completed.length,
        mostRecentWorkoutAt: null,
      );
    }

    final referenceUtcMidnight = DateTime.utc(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    final groups = <MuscleGroupReadiness>[];
    int minDays = 999999;
    for (final entry in lastByCategory.entries) {
      final category = entry.key;
      final lastTrained = entry.value;
      final daysSince = referenceUtcMidnight.difference(lastTrained).inDays;
      if (daysSince < minDays) minDays = daysSince;
      groups.add(
        MuscleGroupReadiness(
          category: category,
          daysSinceTrained: daysSince,
          classification: _classifyDays(daysSince),
          lastTrainedAt: lastTrained,
        ),
      );
    }
    groups.sort((a, b) {
      final c = b.daysSinceTrained.compareTo(a.daysSinceTrained);
      if (c != 0) return c;
      return a.category.compareTo(b.category);
    });

    final overall = _classifyDays(minDays);
    final mostRecent = completed
        .map((w) => w.completedAt!)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return ReadinessInsight(
      overall: overall,
      muscleGroups: groups,
      completedWorkoutCount: completed.length,
      mostRecentWorkoutAt: mostRecent,
    );
  }
}
