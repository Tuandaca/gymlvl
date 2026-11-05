/// Parsed result of `complete_workout`, aggregated for post-workout feedback.
///
/// All values come from the server-authoritative `complete_workout` RPC
/// payload. The client never submits XP/level/quest/achievement/unlock/streak
/// values — it only displays what the server returned.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_workout_result.freezed.dart';
part 'post_workout_result.g.dart';

/// Consolidated post-workout result aggregated from the `complete_workout`
/// response payload.
@freezed
abstract class PostWorkoutResult with _$PostWorkoutResult {
  const factory PostWorkoutResult({
    required String message,
    required int earnedXP,
    required int totalXP,
    required int newLevel,
    required bool leveledUp,
    required bool isQuest,
    String? newTitle,
    required int nextLevelXp,
    required bool isSuspicious,
    @Default([]) List<ClassResult> classResults,
    @Default([]) List<String> achievements,
    required int streak,
  }) = _PostWorkoutResult;

  factory PostWorkoutResult.fromJson(Map<String, dynamic> json) =>
      _$PostWorkoutResultFromJson(json);
}

/// Per-class progression result within a workout completion.
@freezed
abstract class ClassResult with _$ClassResult {
  const factory ClassResult({
    required String classId,
    required String className,
    required String slot,
    required int xpEarned,
    required int newTotalXP,
    required int newLevel,
    required bool leveledUp,
    required bool isGraduation,
  }) = _ClassResult;

  factory ClassResult.fromJson(Map<String, dynamic> json) =>
      _$ClassResultFromJson(json);
}
