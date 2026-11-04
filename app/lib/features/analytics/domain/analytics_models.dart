/// Immutable value types for the M5 analytics domain.
///
/// All values are client-side estimates derived from existing workout /
/// progression data. PostgreSQL remains authoritative; Flutter never writes
/// rewards or progression from these values.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_models.freezed.dart';

/// A single day on the workout frequency heatmap.
@freezed
abstract class HeatmapPoint with _$HeatmapPoint {
  const factory HeatmapPoint({
    /// Local date (midnight, user timezone) the workout was completed on.
    required DateTime date,
    /// Number of distinct completed workouts on that day.
    required int workoutCount,
  }) = _HeatmapPoint;
}

/// A single day in the weight-trend (volume over time) series.
@freezed
abstract class WeightTrendPoint with _$WeightTrendPoint {
  const factory WeightTrendPoint({
    /// Local date (midnight, user timezone).
    required DateTime date,
    /// Sum of reps * weight_kg for completed sets on that day, rounded to 2 dp.
    required double volumeKg,
    /// Total completed reps on that day.
    required int totalReps,
    /// Total completed sets on that day.
    required int totalSets,
  }) = _WeightTrendPoint;
}

/// A single personal-record point from the authoritative `exercise_prs` table.
@freezed
abstract class PRChartPoint with _$PRChartPoint {
  const factory PRChartPoint({
    required String exerciseId,
    required String exerciseName,
    /// Server-authoritative max weight (kg).
    required double maxWeightKg,
    /// Server-authoritative max reps.
    required int maxReps,
    /// Server-side Epley 1RM estimate (kg), already rounded to 2 dp.
    required double estimated1rm,
    /// When the PR row was last updated (UTC).
    required DateTime updatedAt,
  }) = _PRChartPoint;
}

/// Volume by exercise category within an aggregation window.
@freezed
abstract class MuscleBalancePoint with _$MuscleBalancePoint {
  const factory MuscleBalancePoint({
    required String category,
    /// Sum of reps * weight_kg for completed sets in this category, rounded to 2 dp.
    required double volumeKg,
    /// Total completed reps in this category.
    required int totalReps,
    /// Total completed sets in this category.
    required int totalSets,
    /// Share of total window volume (0-100), rounded to 2 dp.
    required double percent,
  }) = _MuscleBalancePoint;
}

/// Aggregated analytics result. Every list is empty when no data exists.
@freezed
abstract class AnalyticsResult with _$AnalyticsResult {
  const factory AnalyticsResult({
    required List<HeatmapPoint> heatmap,
    required List<WeightTrendPoint> weightTrend,
    required List<PRChartPoint> prChart,
    required List<MuscleBalancePoint> muscleBalance,
  }) = _AnalyticsResult;
}

/// One row from the authoritative `exercise_prs` table (M4 progression).
///
/// Flutter receives these from the server; this class never writes to the
/// table and never recalculates the PR.
class PrRecord {
  /// Catalog exercise ID (validated against the exercise catalog).
  final String exerciseId;
  /// Server-authoritative max weight (kg).
  final double maxWeightKg;
  /// Server-authoritative max reps.
  final int maxReps;
  /// Server-side Epley 1RM estimate (kg), already rounded to 2 dp.
  final double estimated1rm;
  /// When the PR row was last updated (UTC).
  final DateTime updatedAt;

  const PrRecord({
    required this.exerciseId,
    required this.maxWeightKg,
    required this.maxReps,
    required this.estimated1rm,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrRecord &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId &&
          maxWeightKg == other.maxWeightKg &&
          maxReps == other.maxReps &&
          estimated1rm == other.estimated1rm &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      Object.hash(exerciseId, maxWeightKg, maxReps, estimated1rm, updatedAt);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'exerciseId': exerciseId,
    'maxWeightKg': maxWeightKg,
    'maxReps': maxReps,
    'estimated1rm': estimated1rm,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PrRecord.fromJson(Map<String, dynamic> json) => PrRecord(
        exerciseId: json['exerciseId'] as String,
        maxWeightKg: (json['maxWeightKg'] as num).toDouble(),
        maxReps: json['maxReps'] as int,
        estimated1rm: (json['estimated1rm'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  String toString() =>
      'PrRecord(exerciseId: $exerciseId, maxWeightKg: $maxWeightKg, '
      'maxReps: $maxReps, estimated1rm: $estimated1rm, updatedAt: $updatedAt)';
}
