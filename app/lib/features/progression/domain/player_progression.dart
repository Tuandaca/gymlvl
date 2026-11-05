/// Unified player-progression model parsed from the server-authoritative
/// `get_player_progression()` RPC.
///
/// All values are display-only previews owned by PostgreSQL. The client never
/// submits XP, level, streak, achievement or unlock values.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_progression.freezed.dart';
part 'player_progression.g.dart';

/// Canonical player-progression state aggregated from the server.
///
/// Fields mirror `public.get_player_progression()`:
/// [userId], [level], [totalXP], [currentTitle], [lastWorkoutDate],
/// [streak], [achievements], [classes], [activeQuest], [nextUnlock].
/// [xpToNextLevel] is a client-side estimate derived from [RPGBridge] using
/// the active class's `xpBase`/`xpSlope` — never a server claim.
@freezed
abstract class PlayerProgression with _$PlayerProgression {
  const factory PlayerProgression({
    required String userId,
    required int level,
    required int totalXP,
    String? currentTitle,
    DateTime? lastWorkoutDate,
    StreakInfo? streak,
    @Default([]) List<AchievementSummary> achievements,
    @Default([]) List<ClassProgress> classes,
    Map<String, dynamic>? activeQuest,
    Map<String, dynamic>? nextUnlock,
    @Default(0) int xpToNextLevel,
  }) = _PlayerProgression;

  factory PlayerProgression.fromJson(Map<String, dynamic> json) =>
      _$PlayerProgressionFromJson(json);
}

/// Streak state from `public.streaks`, timezone-aware on the server.
@freezed
abstract class StreakInfo with _$StreakInfo {
  const factory StreakInfo({
    required int currentStreak,
    required int longestStreak,
    DateTime? lastActivityDate,
  }) = _StreakInfo;

  factory StreakInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakInfoFromJson(json);
}

/// A user class row with current XP / level, used for class-linked progression.
@freezed
abstract class ClassProgress with _$ClassProgress {
  const factory ClassProgress({
    required String classId,
    required String className,
    required String slot,
    required int currentXP,
    required int level,
    required bool isGraduated,
    int? xpBase,
    double? xpSlope,
  }) = _ClassProgress;

  factory ClassProgress.fromJson(Map<String, dynamic> json) =>
      _$ClassProgressFromJson(json);
}

/// A single earned achievement row returned by the RPC.
@freezed
abstract class AchievementSummary with _$AchievementSummary {
  const factory AchievementSummary({
    required String achievementId,
    required DateTime unlockedAt,
  }) = _AchievementSummary;

  factory AchievementSummary.fromJson(Map<String, dynamic> json) =>
      _$AchievementSummaryFromJson(json);
}
