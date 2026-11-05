/// P4 Gate 4: Muscle / structural-balance analytics.
///
/// Extends the existing M5 category-based muscle balance with push/pull,
/// upper/lower and anterior/posterior splits, computed from completed
/// workout volume (reps * weight_kg) and existing exercise muscle metadata
/// (category + force_type).
///
/// Output is fitness analytics (training distribution / relative emphasis),
/// NOT clinical diagnosis. Formulas are deterministic and documented below.
/// Identical input always yields identical output (no clock, locale, or
/// random dependence).
///
/// PostgreSQL remains authoritative; this module never writes XP, levels,
/// streaks, PRs, or completed workouts.
library;

import 'package:app/features/analytics/domain/analytics_engine.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

/// One side of a balance split.
class BalanceSide {
  final String labelKey;
  final double volumeKg;
  final double percent; // share of the two-sided total (0-100), rounded 2 dp
  final int totalSets;
  final int totalReps;

  const BalanceSide({
    required this.labelKey,
    required this.volumeKg,
    required this.percent,
    required this.totalSets,
    required this.totalReps,
  });
}

/// Directional emphasis for a two-sided split.
enum BalanceEmphasis { balanced, sideADominant, sideBDominant }

/// Threshold (percent) beyond which a side is considered dominant.
const double kDominanceThresholdPercent = 60.0;

/// Threshold (percent) below which a side is considered under-trained.
const double kUnderTrainedThresholdPercent = 40.0;

/// Result of a two-sided balance split (e.g. push vs pull).
class BalanceSplit {
  final String dimensionLabelKey;
  final BalanceSide sideA;
  final BalanceSide sideB;

  /// Ratio sideA / sideB (null when sideB volume is 0).
  final double? ratio;
  final BalanceEmphasis emphasis;

  /// True when either side is under-trained (< 40% of two-sided volume).
  bool get anyUnderTrained =>
      sideA.percent < kUnderTrainedThresholdPercent ||
      sideB.percent < kUnderTrainedThresholdPercent;

  const BalanceSplit({
    required this.dimensionLabelKey,
    required this.sideA,
    required this.sideB,
    this.ratio,
    required this.emphasis,
  });
}

/// Full structural-balance assessment across all three dimensions.
class StructuralBalanceResult {
  final BalanceSplit pushPull;
  final BalanceSplit upperLower;
  final BalanceSplit anteriorPosterior;
  final List<MuscleBalancePoint> categoryDistribution;

  const StructuralBalanceResult({
    required this.pushPull,
    required this.upperLower,
    required this.anteriorPosterior,
    required this.categoryDistribution,
  });
}

/// Classification of an exercise for balance purposes.
class ExerciseClassification {
  final String exerciseId;
  final String category;
  final String? forceType;

  /// 'push' | 'pull' | null (neutral / static).
  final String? pushPull;

  /// 'upper' | 'lower' | null (neutral).
  final String? upperLower;

  /// 'anterior' | 'posterior' | null (neutral).
  final String? anteriorPosterior;

  ExerciseClassification({
    required this.exerciseId,
    required this.category,
    this.forceType,
    this.pushPull,
    this.upperLower,
    this.anteriorPosterior,
  });
}

/// Engine that computes structural-balance insights from completed workouts.
class StructuralBalanceEngine {
  /// Classify [exercises] for balance purposes.
  ///
  /// Formulas (documented, deterministic):
  /// - push/pull: from [Exercise.forceType]; 'Push'→push, 'Pull'→pull,
  ///   anything else (incl. null/Static)→neutral (excluded from ratio).
  /// - upper/lower: from [Exercise.category]; Chest/Shoulders/Arms/Core→upper,
  ///   Legs→lower, anything else→neutral.
  /// - anterior/posterior: Chest/Shoulders/Arms→anterior, Back/Legs→posterior,
  ///   Core→neutral.
  List<ExerciseClassification> classify(List<Exercise> exercises) {
    return exercises.map((e) => _classifyOne(e)).toList();
  }

  ExerciseClassification _classifyOne(Exercise e) {
    final force = (e.forceType ?? '').trim().toLowerCase();
    final String? pushPull;
    if (force == 'push') {
      pushPull = 'push';
    } else if (force == 'pull') {
      pushPull = 'pull';
    } else {
      pushPull = null;
    }

    final cat = e.category.trim();
    final String? upperLower;
    if (cat == 'Chest' ||
        cat == 'Shoulders' ||
        cat == 'Arms' ||
        cat == 'Core') {
      upperLower = 'upper';
    } else if (cat == 'Legs') {
      upperLower = 'lower';
    } else {
      upperLower = null;
    }

    final String? anteriorPosterior;
    if (cat == 'Chest' || cat == 'Shoulders' || cat == 'Arms') {
      anteriorPosterior = 'anterior';
    } else if (cat == 'Back' || cat == 'Legs') {
      anteriorPosterior = 'posterior';
    } else {
      anteriorPosterior = null;
    }

    return ExerciseClassification(
      exerciseId: e.id,
      category: cat,
      forceType: e.forceType,
      pushPull: pushPull,
      upperLower: upperLower,
      anteriorPosterior: anteriorPosterior,
    );
  }

  /// Two-sided push vs pull split from completed-set volume.
  ///
  /// Only exercises classified as push or pull contribute. Neutral exercises
  /// (static, unknown force type) are excluded from the ratio. When one side
  /// has zero volume, emphasis is balanced and ratio is null.
  BalanceSplit pushPullBalance({
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    return _twoSided(
      sets: sets,
      workoutExercises: workoutExercises,
      workouts: workouts,
      exercises: exercises,
      start: start,
      end: end,
      timezoneOffsetHours: timezoneOffsetHours,
      dimensionLabelKey: 'range_push_pull',
      sideALabelKey: 'push',
      sideBLabelKey: 'pull',
      classifier: (c) => c.pushPull,
      sideAValue: 'push',
      sideBValue: 'pull',
    );
  }

  /// Two-sided upper vs lower split from completed-set volume.
  BalanceSplit upperLowerBalance({
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    return _twoSided(
      sets: sets,
      workoutExercises: workoutExercises,
      workouts: workouts,
      exercises: exercises,
      start: start,
      end: end,
      timezoneOffsetHours: timezoneOffsetHours,
      dimensionLabelKey: 'range_upper_lower',
      sideALabelKey: 'upper',
      sideBLabelKey: 'lower',
      classifier: (c) => c.upperLower,
      sideAValue: 'upper',
      sideBValue: 'lower',
    );
  }

  /// Two-sided anterior vs posterior split from completed-set volume.
  BalanceSplit anteriorPosteriorBalance({
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    return _twoSided(
      sets: sets,
      workoutExercises: workoutExercises,
      workouts: workouts,
      exercises: exercises,
      start: start,
      end: end,
      timezoneOffsetHours: timezoneOffsetHours,
      dimensionLabelKey: 'range_anterior_posterior',
      sideALabelKey: 'anterior',
      sideBLabelKey: 'posterior',
      classifier: (c) => c.anteriorPosterior,
      sideAValue: 'anterior',
      sideBValue: 'posterior',
    );
  }

  /// Full structural-balance assessment plus category distribution.
  ///
  /// Category distribution reuses [AnalyticsEngine.muscleBalance].
  StructuralBalanceResult assess({
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    return StructuralBalanceResult(
      pushPull: pushPullBalance(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
        start: start,
        end: end,
        timezoneOffsetHours: timezoneOffsetHours,
      ),
      upperLower: upperLowerBalance(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
        start: start,
        end: end,
        timezoneOffsetHours: timezoneOffsetHours,
      ),
      anteriorPosterior: anteriorPosteriorBalance(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
        start: start,
        end: end,
        timezoneOffsetHours: timezoneOffsetHours,
      ),
      categoryDistribution: AnalyticsEngine().muscleBalance(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
        start: start,
        end: end,
        timezoneOffsetHours: timezoneOffsetHours,
      ),
    );
  }

  BalanceSplit _twoSided({
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
    required String dimensionLabelKey,
    required String sideALabelKey,
    required String sideBLabelKey,
    required String? Function(ExerciseClassification) classifier,
    required String sideAValue,
    required String sideBValue,
  }) {
    final validExerciseIds = <String>{};
    for (final e in exercises) {
      validExerciseIds.add(e.id);
    }
    final weById = <String, WorkoutExercise>{};
    for (final we in workoutExercises) {
      weById[we.id] = we;
    }
    final wById = <String, Workout>{};
    for (final w in workouts) {
      wById[w.id] = w;
    }
    final byExercise = <String, ExerciseClassification>{};
    for (final e in classify(exercises)) {
      byExercise[e.exerciseId] = e;
    }

    double sideAVolume = 0;
    double sideBVolume = 0;
    int sideASets = 0;
    int sideBSets = 0;
    int sideAReps = 0;
    int sideBReps = 0;

    for (final s in sets) {
      if (!s.isCompleted || s.isWarmup) continue;
      final we = weById[s.workoutExerciseId];
      if (we == null) continue;
      if (!validExerciseIds.contains(we.exerciseId)) continue;
      final w = wById[we.workoutId];
      if (w == null || w.completedAt == null) continue;
      final instant = w.completedAt!;
      if (start != null && instant.isBefore(start)) continue;
      if (end != null && !instant.isBefore(end)) continue;
      final c = byExercise[we.exerciseId];
      if (c == null) continue;
      final kind = classifier(c);
      final volume = s.reps * s.weightKg;
      if (kind == sideAValue) {
        sideAVolume += volume;
        sideASets += 1;
        sideAReps += s.reps;
      } else if (kind == sideBValue) {
        sideBVolume += volume;
        sideBSets += 1;
        sideBReps += s.reps;
      }
    }

    final total = sideAVolume + sideBVolume;
    final sideAPercent = total == 0 ? 0.0 : _round2(sideAVolume / total * 100);
    final sideBPercent = total == 0 ? 0.0 : _round2(sideBVolume / total * 100);

    BalanceEmphasis emphasis;
    double? ratio;
    if (total == 0) {
      emphasis = BalanceEmphasis.balanced;
      ratio = null;
    } else if (sideAPercent >= kDominanceThresholdPercent) {
      emphasis = BalanceEmphasis.sideADominant;
      ratio = sideBVolume == 0 ? null : sideAVolume / sideBVolume;
    } else if (sideBPercent >= kDominanceThresholdPercent) {
      emphasis = BalanceEmphasis.sideBDominant;
      ratio = sideAVolume == 0 ? null : sideBVolume / sideAVolume;
    } else {
      emphasis = BalanceEmphasis.balanced;
      ratio = sideBVolume == 0 ? null : sideAVolume / sideBVolume;
    }

    return BalanceSplit(
      dimensionLabelKey: dimensionLabelKey,
      sideA: BalanceSide(
        labelKey: sideALabelKey,
        volumeKg: _round2(sideAVolume),
        percent: sideAPercent,
        totalSets: sideASets,
        totalReps: sideAReps,
      ),
      sideB: BalanceSide(
        labelKey: sideBLabelKey,
        volumeKg: _round2(sideBVolume),
        percent: sideBPercent,
        totalSets: sideBSets,
        totalReps: sideBReps,
      ),
      ratio: ratio,
      emphasis: emphasis,
    );
  }

  double _round2(double value) {
    if (!value.isFinite) return 0.0;
    return (value * 100).round() / 100;
  }
}
