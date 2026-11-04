/// Immutable value types for the M4 progression domain.
///
/// All progression values are client-side previews only. The server owns every
/// award, streak, level and PR; this package never writes progression.
library;

/// Epley one-rep max estimate: ``weightKg * (1 + reps / 30)`` rounded to 2 decimals.
class OneRepMaxResult {
  /// Estimated 1RM in kilograms (finite, rounded to 2 decimals).
  final double estimated1rm;

  /// Repetitions used for the estimate.
  final int reps;

  /// Weight lifted in kilograms.
  final double weightKg;

  const OneRepMaxResult({
    required this.estimated1rm,
    required this.reps,
    required this.weightKg,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OneRepMaxResult &&
          runtimeType == other.runtimeType &&
          estimated1rm == other.estimated1rm &&
          reps == other.reps &&
          weightKg == other.weightKg;

  @override
  int get hashCode => Object.hash(estimated1rm, reps, weightKg);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'estimated1rm': estimated1rm,
    'reps': reps,
    'weightKg': weightKg,
  };

  factory OneRepMaxResult.fromJson(Map<String, dynamic> json) =>
      OneRepMaxResult(
        estimated1rm: (json['estimated1rm'] as num).toDouble(),
        reps: json['reps'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
      );

  @override
  String toString() =>
      'OneRepMaxResult(estimated1rm: $estimated1rm, reps: $reps, weightKg: $weightKg)';
}

/// Personal record detection result.
///
/// ``kind`` is one of ``'none'``, ``'weight'``, ``'reps'``, ``'both'``.
class PersonalRecordResult {
  /// PR kind: ``'none'`` | ``'weight'`` | ``'reps'`` | ``'both'``.
  final String kind;

  /// True when the new weight exceeds the previous max weight (or there is no previous max).
  final bool isWeightPR;

  /// True when the new reps exceed the previous max reps.
  final bool isRepsPR;

  /// Previous max weight, null when there is no history.
  final double? previousMaxWeight;

  /// Previous max reps, null when there is no history.
  final int? previousMaxReps;

  const PersonalRecordResult({
    required this.kind,
    required this.isWeightPR,
    required this.isRepsPR,
    this.previousMaxWeight,
    this.previousMaxReps,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordResult &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          isWeightPR == other.isWeightPR &&
          isRepsPR == other.isRepsPR &&
          previousMaxWeight == other.previousMaxWeight &&
          previousMaxReps == other.previousMaxReps;

  @override
  int get hashCode => Object.hash(
    kind,
    isWeightPR,
    isRepsPR,
    previousMaxWeight,
    previousMaxReps,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind,
    'isWeightPR': isWeightPR,
    'isRepsPR': isRepsPR,
    'previousMaxWeight': previousMaxWeight,
    'previousMaxReps': previousMaxReps,
  };

  factory PersonalRecordResult.fromJson(Map<String, dynamic> json) =>
      PersonalRecordResult(
        kind: json['kind'] as String,
        isWeightPR: json['isWeightPR'] as bool,
        isRepsPR: json['isRepsPR'] as bool,
        previousMaxWeight: (json['previousMaxWeight'] as num?)?.toDouble(),
        previousMaxReps: json['previousMaxReps'] as int?,
      );

  @override
  String toString() =>
      'PersonalRecordResult(kind: $kind, isWeightPR: $isWeightPR, isRepsPR: $isRepsPR)';
}

/// Deterministic progression snapshot combining XP, 1RM and PR status.
///
/// Intended for golden-table testing. ``newLevel`` is the highest level L such
/// that ``totalXP >= xpRequiredForLevel(L)``; ``leveledUp`` is ``newLevel > currentLevel``.
class ProgressionResult {
  /// XP earned by the evaluated workout (preview only).
  final int earnedXP;

  /// Cumulative XP after adding ``earnedXP`` to ``currentXP``.
  final int totalXP;

  /// Level reached at ``totalXP``.
  final int newLevel;

  /// True when ``newLevel > currentLevel``.
  final bool leveledUp;

  /// One-rep max estimate for the evaluated set, null when not applicable.
  final OneRepMaxResult? oneRepMax;

  /// Personal record status for the evaluated set, null when not applicable.
  final PersonalRecordResult? personalRecord;

  const ProgressionResult({
    required this.earnedXP,
    required this.totalXP,
    required this.newLevel,
    required this.leveledUp,
    this.oneRepMax,
    this.personalRecord,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionResult &&
          runtimeType == other.runtimeType &&
          earnedXP == other.earnedXP &&
          totalXP == other.totalXP &&
          newLevel == other.newLevel &&
          leveledUp == other.leveledUp &&
          oneRepMax == other.oneRepMax &&
          personalRecord == other.personalRecord;

  @override
  int get hashCode => Object.hash(
    earnedXP,
    totalXP,
    newLevel,
    leveledUp,
    oneRepMax,
    personalRecord,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'earnedXP': earnedXP,
    'totalXP': totalXP,
    'newLevel': newLevel,
    'leveledUp': leveledUp,
    'oneRepMax': oneRepMax?.toJson(),
    'personalRecord': personalRecord?.toJson(),
  };

  factory ProgressionResult.fromJson(Map<String, dynamic> json) =>
      ProgressionResult(
        earnedXP: json['earnedXP'] as int,
        totalXP: json['totalXP'] as int,
        newLevel: json['newLevel'] as int,
        leveledUp: json['leveledUp'] as bool,
        oneRepMax: json['oneRepMax'] != null
            ? OneRepMaxResult.fromJson(
                json['oneRepMax'] as Map<String, dynamic>,
              )
            : null,
        personalRecord: json['personalRecord'] != null
            ? PersonalRecordResult.fromJson(
                json['personalRecord'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  String toString() =>
      'ProgressionResult(earnedXP: $earnedXP, totalXP: $totalXP, newLevel: $newLevel, leveledUp: $leveledUp)';
}
