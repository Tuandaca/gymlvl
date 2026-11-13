/// Bodyweight trend computation from a history of [BodyweightMeasurement]s.
///
/// The client never writes body mass; it only previews the trend computed from
/// measurements sourced from [profiles.weight_kg] (baseline) and manual/scale
/// weigh-ins. workout_sets.weight_kg is never used as body mass here.
library;

import 'bodyweight_measurement.dart';

/// A single point in the bodyweight trend series.
class BodyweightTrendPoint {
  /// Local date (midnight) of the measurement.
  final DateTime date;

  /// Body mass in kg at [date].
  final double weightKg;

  const BodyweightTrendPoint({required this.date, required this.weightKg});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyweightTrendPoint &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          weightKg == other.weightKg;

  @override
  int get hashCode => Object.hash(date, weightKg);

  @override
  String toString() => 'BodyweightTrendPoint(date: $date, weightKg: $weightKg)';
}

/// Direction of the computed trend.
enum TrendDirection { up, down, stable }

/// Threshold (kg) below which a net change is treated as stable.
const double kTrendStableThresholdKg = 0.5;

/// Computes bodyweight trend from a history of measurements.
///
/// Measurements are sorted by [measuredAt] (ascending) for presentation and
/// computation. The list is never mutated.
class BodyweightTrend {
  final List<BodyweightMeasurement> measurements;

  BodyweightTrend(this.measurements);

  /// Measurements sorted by [measuredAt] ascending (a copy, never mutated).
  List<BodyweightMeasurement> get sorted =>
      List.of(measurements)
        ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

  /// Trend points (date, weightKg) sorted ascending.
  List<BodyweightTrendPoint> get points => sorted
      .map(
        (m) => BodyweightTrendPoint(date: m.measuredAt, weightKg: m.weightKg),
      )
      .toList(growable: false);

  /// The earliest measurement, or null when there is no history.
  BodyweightMeasurement? get first => sorted.isEmpty ? null : sorted.first;

  /// The latest measurement, or null when there is no history.
  BodyweightMeasurement? get last => sorted.isEmpty ? null : sorted.last;

  /// Net change from first to last measurement (kg), or null when fewer than
  /// two measurements exist.
  double? get totalChangeKg {
    if (sorted.length < 2) return null;
    return last!.weightKg - first!.weightKg;
  }

  /// Average body mass across all measurements (kg), or null when empty.
  double? get averageWeightKg {
    if (sorted.isEmpty) return null;
    return sorted.map((m) => m.weightKg).reduce((a, b) => a + b) /
        sorted.length;
  }

  /// Minimum body mass across all measurements (kg), or null when empty.
  double? get minWeightKg {
    if (sorted.isEmpty) return null;
    return sorted.map((m) => m.weightKg).reduce((a, b) => a < b ? a : b);
  }

  /// Maximum body mass across all measurements (kg), or null when empty.
  double? get maxWeightKg {
    if (sorted.isEmpty) return null;
    return sorted.map((m) => m.weightKg).reduce((a, b) => a > b ? a : b);
  }

  /// Net change within the last [days] days relative to [reference], or null
  /// when there are no measurements in the window.
  double? changeInLastDays(int days, {DateTime? reference}) {
    final ref = reference ?? DateTime.utc(2026, 11, 5);
    final windowStart = ref.subtract(Duration(days: days));
    final inWindow = sorted
        .where((m) => m.measuredAt.isAfter(windowStart))
        .toList();
    if (inWindow.length < 2) return null;
    return inWindow.last.weightKg - inWindow.first.weightKg;
  }

  /// Overall direction of the trend based on [totalChangeKg]. [stable] when
  /// the magnitude is within [kTrendStableThresholdKg] or when there are fewer
  /// than two measurements.
  TrendDirection get direction {
    final change = totalChangeKg;
    if (change == null) return TrendDirection.stable;
    if (change > kTrendStableThresholdKg) return TrendDirection.up;
    if (change < -kTrendStableThresholdKg) return TrendDirection.down;
    return TrendDirection.stable;
  }

  /// Alias for [points], intended for chart consumption (e.g. fl_chart).
  List<BodyweightTrendPoint> toChartPoints() => points;
}
