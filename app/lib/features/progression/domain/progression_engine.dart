import 'dart:math' as math;
import 'progression_models.dart';
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
        .where((set) => set.isCompleted && set.reps > 0 && !set.isWarmup)
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

  /// Epley one-rep max estimate: ``weightKg * (1 + reps / 30)``.
  ///
  /// Matches the server-side `complete_workout` estimated_1rm (D-043).
  /// Returns ``null`` for invalid input and never produces NaN/Infinity.
  /// Rounded to 2 decimal places.
  static double? calculateOneRepMax({
    required double weightKg,
    required int reps,
  }) {
    if (!weightKg.isFinite || weightKg <= 0 || weightKg > 1000) return null;
    if (reps < 1 || reps > 1000) return null;
    final estimate = weightKg * (1 + reps / 30);
    if (!estimate.isFinite) return null;
    return (estimate * 100).round() / 100;
  }

  /// Detect a personal record relative to previous max weight/reps.
  ///
  /// PR when ``newWeight > existingMaxWeight`` OR
  /// (``newWeight == existingMaxWeight`` AND ``newReps > existingMaxReps``).
  /// No existing max (null) ⇒ any completed set is a weight PR.
  static PersonalRecordResult detectPersonalRecord({
    required double? existingMaxWeight,
    required int? existingMaxReps,
    required double newWeight,
    required int newReps,
  }) {
    final bool isWeightPR;
    final bool isRepsPR;
    final bool isPR;

    if (existingMaxWeight == null) {
      // No existing PR: any completed set is a weight PR.
      isWeightPR = true;
      isRepsPR = false;
      isPR = true;
    } else {
      final prevReps = existingMaxReps ?? 0;
      isWeightPR = newWeight > existingMaxWeight;
      isRepsPR = newReps > prevReps;
      isPR =
          newWeight > existingMaxWeight ||
          (newWeight == existingMaxWeight && newReps > prevReps);
    }

    String kind;
    if (!isPR) {
      kind = 'none';
    } else if (isWeightPR && isRepsPR) {
      kind = 'both';
    } else if (isWeightPR) {
      kind = 'weight';
    } else {
      kind = 'reps';
    }

    return PersonalRecordResult(
      kind: kind,
      isWeightPR: isWeightPR,
      isRepsPR: isRepsPR,
      previousMaxWeight: existingMaxWeight,
      previousMaxReps: existingMaxReps,
    );
  }

  /// Deterministic progression snapshot: XP, level, 1RM and PR status.
  ///
  /// Intended for golden-table testing; identical input always yields identical
  /// output (no clock, locale, or random dependence).
  static ProgressionResult progressionSnapshot({
    required int currentXP,
    required int currentLevel,
    required int durationSeconds,
    required List<WorkoutSet> completedSets,
    required int uniqueCategories,
    double userStreak = 0,
    bool isSuspicious = false,
    double? existingMaxWeight,
    int? existingMaxReps,
    double? newWeight,
    int? newReps,
  }) {
    final earnedXP = calculateXP(
      durationSeconds: durationSeconds,
      completedSets: completedSets,
      uniqueCategories: uniqueCategories,
      userStreak: userStreak,
      isSuspicious: isSuspicious,
    );
    final totalXP = currentXP + earnedXP;
    final newLevel = _levelForXP(totalXP);
    final leveledUp = newLevel > currentLevel;

    OneRepMaxResult? oneRepMax;
    if (newWeight != null && newReps != null) {
      final estimated1rm = calculateOneRepMax(
        weightKg: newWeight,
        reps: newReps,
      );
      if (estimated1rm != null) {
        oneRepMax = OneRepMaxResult(
          estimated1rm: estimated1rm,
          reps: newReps,
          weightKg: newWeight,
        );
      }
    }

    PersonalRecordResult? personalRecord;
    if (newWeight != null && newReps != null) {
      personalRecord = detectPersonalRecord(
        existingMaxWeight: existingMaxWeight,
        existingMaxReps: existingMaxReps,
        newWeight: newWeight,
        newReps: newReps,
      );
    }

    return ProgressionResult(
      earnedXP: earnedXP,
      totalXP: totalXP,
      newLevel: newLevel,
      leveledUp: leveledUp,
      oneRepMax: oneRepMax,
      personalRecord: personalRecord,
    );
  }

  static int _levelForXP(int totalXP) {
    var level = 1;
    while (totalXP >= xpRequiredForLevel(level)) {
      level += 1;
    }
    return level;
  }
}
