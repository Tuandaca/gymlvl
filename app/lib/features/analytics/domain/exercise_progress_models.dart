/// Value types for the P4 exercise-level progress / history domain.
///
/// All values are client-side estimates derived from completed workout
/// history. PostgreSQL remains authoritative; this module never writes XP,
/// levels, streaks, PRs, or completed workouts. `complete_workout` remains
/// the sole reward path. Identical input always yields identical output
/// (no clock, locale, or random dependence).
library;

/// One completed session for a single exercise, ordered chronologically.
///
/// Warm-up sets are excluded from working-set progression. Only completed
/// workouts are considered.
class ExerciseSessionEntry {
  /// Workout that produced this session.
  final String workoutId;

  /// Catalog exercise ID (validated against the exercise catalogue).
  final String exerciseId;

  /// Human-readable exercise name.
  final String exerciseName;

  /// Local date (midnight, user timezone) the workout was completed on.
  final DateTime completedAt;

  /// Number of completed non-warm-up (working) sets in this session.
  final int workingSetCount;

  /// Total completed reps across working sets in this session.
  final int totalReps;

  /// Sum of reps * weight_kg across working sets, rounded to 2 dp.
  final double totalVolumeKg;

  /// Heaviest completed working-set weight in this session (kg).
  final double bestWeightKg;

  /// Reps performed at [bestWeightKg].
  final int bestReps;

  /// Epley one-rep max estimate for the best working set, rounded to 2 dp.
  /// Null when the set inputs are invalid.
  final double? estimated1rm;

  /// True when this session's best weight exceeds every previous session.
  final bool isWeightPr;

  /// True when this session's reps at its best weight exceed every previous
  /// session at the same best weight.
  final bool isRepsPr;

  /// PR kind: ``'none'`` | ``'weight'`` | ``'reps'`` | ``'both'``.
  final String prKind;

  const ExerciseSessionEntry({
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.completedAt,
    required this.workingSetCount,
    required this.totalReps,
    required this.totalVolumeKg,
    required this.bestWeightKg,
    required this.bestReps,
    this.estimated1rm,
    required this.isWeightPr,
    required this.isRepsPr,
    required this.prKind,
  });

  bool get hasPr => prKind != 'none';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'workoutId': workoutId,
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'completedAt': completedAt.toUtc().toIso8601String(),
    'workingSetCount': workingSetCount,
    'totalReps': totalReps,
    'totalVolumeKg': totalVolumeKg,
    'bestWeightKg': bestWeightKg,
    'bestReps': bestReps,
    'estimated1rm': estimated1rm,
    'isWeightPr': isWeightPr,
    'isRepsPr': isRepsPr,
    'prKind': prKind,
  };

  factory ExerciseSessionEntry.fromJson(Map<String, dynamic> json) =>
      ExerciseSessionEntry(
        workoutId: json['workoutId'] as String,
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
        workingSetCount: json['workingSetCount'] as int,
        totalReps: json['totalReps'] as int,
        totalVolumeKg: (json['totalVolumeKg'] as num).toDouble(),
        bestWeightKg: (json['bestWeightKg'] as num).toDouble(),
        bestReps: json['bestReps'] as int,
        estimated1rm: (json['estimated1rm'] as num?)?.toDouble(),
        isWeightPr: json['isWeightPr'] as bool,
        isRepsPr: json['isRepsPr'] as bool,
        prKind: json['prKind'] as String,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSessionEntry &&
          runtimeType == other.runtimeType &&
          workoutId == other.workoutId &&
          exerciseId == other.exerciseId &&
          completedAt == other.completedAt;

  @override
  int get hashCode => Object.hash(workoutId, exerciseId, completedAt);

  @override
  String toString() =>
      'ExerciseSessionEntry(exerciseId: $exerciseId, completedAt: $completedAt, '
      'bestWeightKg: $bestWeightKg, bestReps: $bestReps, prKind: $prKind)';
}

/// Result of computing progress for a single exercise.
class ExerciseProgressResult {
  /// The exercise whose progress was computed.
  final String exerciseId;

  /// The exercise's human-readable name.
  final String exerciseName;

  /// Sessions in chronological order (oldest first).
  final List<ExerciseSessionEntry> sessions;

  /// Number of completed sessions that include this exercise.
  final int sessionCount;

  /// Heaviest completed working-set weight across all sessions (kg).
  final double maxWeightKg;

  /// Best Epley 1RM across all sessions (kg), null when no valid set.
  final double? maxEstimated1rm;

  const ExerciseProgressResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.sessions,
    required this.sessionCount,
    required this.maxWeightKg,
    this.maxEstimated1rm,
  });

  /// True when there is no recorded history for this exercise.
  bool get isEmpty => sessions.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'sessionCount': sessionCount,
    'maxWeightKg': maxWeightKg,
    'maxEstimated1rm': maxEstimated1rm,
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  @override
  String toString() =>
      'ExerciseProgressResult(exerciseId: $exerciseId, sessions: $sessionCount, '
      'maxWeightKg: $maxWeightKg)';
}
