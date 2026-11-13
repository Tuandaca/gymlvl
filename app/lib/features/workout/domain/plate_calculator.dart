/// Pure Dart plate calculator for weight-loaded exercises.
///
/// Deterministic, dependency-free, and side-effect free. It never calls any
/// service and never mutates workout state. It only answers: given a target
/// total weight, a bar weight, and available plate denominations, how many
/// plates go on each side, and what exact weight is achieved.
///
/// Validation rules:
/// - targetWeight must be > 0 and finite.
/// - barWeight must be finite and >= 0.
/// - denominations must be non-empty, finite, and > 0.
///
/// Greedy largest-first strategy: each denomination is taken as many times as
/// fits within the remaining per-side allowance without exceeding the target.
/// The achieved weight never exceeds the target when the bar is not already
/// heavier than the target.
class PlateCalculator {
  const PlateCalculator();

  /// Calculate plates per side for [targetWeight] using [barWeight] and
  /// [denominations] (kg).
  ///
  /// Throws [ArgumentError] for invalid input.
  PlateCalculationResult calculate({
    required double targetWeight,
    required double barWeight,
    required Iterable<double> denominations,
  }) {
    if (!targetWeight.isFinite || targetWeight <= 0) {
      throw ArgumentError.value(
        targetWeight,
        'targetWeight',
        'must be a finite positive weight',
      );
    }
    if (!barWeight.isFinite || barWeight < 0) {
      throw ArgumentError.value(
        barWeight,
        'barWeight',
        'must be a finite non-negative weight',
      );
    }
    final sorted =
        denominations
            .whereType<double>()
            .where((d) => d.isFinite && d > 0)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    if (sorted.isEmpty) {
      throw ArgumentError.value(
        denominations,
        'denominations',
        'must contain at least one finite positive denomination',
      );
    }

    // Weight that plates must supply on both sides combined.
    final platesTotalNeeded = targetWeight - barWeight;
    // Allowance per side (never negative).
    var perSideRemaining = platesTotalNeeded / 2.0;
    if (perSideRemaining < 0) perSideRemaining = 0;

    final Map<double, int> platesPerSide = {};
    for (final denom in sorted) {
      if (perSideRemaining <= 0) break;
      final count = (perSideRemaining / denom).floor();
      if (count > 0) {
        platesPerSide[denom] = count;
        perSideRemaining -= count * denom;
      }
    }

    final platesWeight = platesPerSide.entries.fold<double>(
      0,
      (sum, entry) => sum + entry.key * entry.value,
    );
    final achievedWeight = barWeight + 2 * platesWeight;
    final remainder = targetWeight - achievedWeight;

    return PlateCalculationResult(
      targetWeight: targetWeight,
      barWeight: barWeight,
      platesPerSide: Map.unmodifiable(platesPerSide),
      achievedWeight: achievedWeight,
      remainder: remainder,
    );
  }
}

/// Result of a plate calculation.
class PlateCalculationResult {
  /// The requested total weight (bar + plates on both sides).
  final double targetWeight;

  /// The bar weight, counted once.
  final double barWeight;

  /// Plate count per side, keyed by denomination. Always non-empty only when
  /// at least one plate fits; otherwise `{}`.
  final Map<double, int> platesPerSide;

  /// `barWeight + 2 * sum(denomination * count)` — never exceeds [targetWeight]
  /// unless the bar alone is already heavier than the target.
  final double achievedWeight;

  /// `targetWeight - achievedWeight`. Zero when the target is exact;
  /// negative when the bar alone exceeds the target; positive when the
  /// closest achievable weight is below the target.
  final double remainder;

  const PlateCalculationResult({
    required this.targetWeight,
    required this.barWeight,
    required this.platesPerSide,
    required this.achievedWeight,
    required this.remainder,
  });

  /// True when [achievedWeight] equals [targetWeight].
  bool get isExact => remainder == 0;

  /// True when no plates are needed (target equals bar weight exactly).
  bool get isBarOnly => platesPerSide.isEmpty && remainder == 0;

  @override
  String toString() {
    final plates = platesPerSide.isEmpty
        ? 'none'
        : platesPerSide.entries.map((e) => '${e.value}x ${e.key}kg').join(', ');
    return 'PlateCalculationResult(target=$targetWeight, bar=$barWeight, '
        'perSide=$plates, achieved=$achievedWeight, remainder=$remainder)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlateCalculationResult &&
          runtimeType == other.runtimeType &&
          targetWeight == other.targetWeight &&
          barWeight == other.barWeight &&
          _mapEquals(platesPerSide, other.platesPerSide) &&
          achievedWeight == other.achievedWeight &&
          remainder == other.remainder;

  @override
  int get hashCode {
    final entries = platesPerSide.entries.toList()
      ..sort((a, b) {
        final c = a.key.compareTo(b.key);
        return c != 0 ? c : a.value.compareTo(b.value);
      });
    return Object.hash(
      targetWeight,
      barWeight,
      Object.hashAll(entries.map((e) => Object.hash(e.key, e.value))),
      achievedWeight,
      remainder,
    );
  }

  static bool _mapEquals(Map<double, int> a, Map<double, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null || other != entry.value) return false;
    }
    return true;
  }
}
