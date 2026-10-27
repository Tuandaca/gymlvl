import 'dart:math' as math;
import '../../workout/domain/workout_set.dart';

/// Display-only estimate. The database owns all awards, streaks and quest bonuses.
class ProgressionEngine {
  static int calculateXP({
    required int durationSeconds,
    required List<WorkoutSet> completedSets,
    required int uniqueCategories,
    double userStreak = 0,
    bool isSuspicious = false,
  }) {
    final valid = completedSets
        .where((set) => set.isCompleted && set.reps > 0)
        .toList();
    if (valid.isEmpty) return 0;
    if (isSuspicious) return 10;
    var volume = 0.0;
    for (final set in valid) {
      if (!set.weightKg.isFinite || set.weightKg < 0) continue;
      final ratio = set.baselineWeightKg > 0
          ? (set.weightKg / set.baselineWeightKg).clamp(.2, 3.0)
          : 1.0;
      volume += 5 * ratio;
    }
    if (volume <= 0) return 0;
    final variety = math.max(0, uniqueCategories - 1) * 8;
    final multiplier = (1 + math.max(0, userStreak) * .05).clamp(1.0, 1.5);
    return ((volume + variety) * multiplier).floor().clamp(0, 1000);
  }

  /// Cumulative XP required to advance from this global level.
  static int xpRequiredForLevel(int level) =>
      (100 * math.pow(math.max(1, level), 1.5)).floor();

  static bool checkSuspiciousPace(int sets, int durationSeconds) =>
      sets > 3 && durationSeconds > 0 && sets / (durationSeconds / 60) > 4;
}
