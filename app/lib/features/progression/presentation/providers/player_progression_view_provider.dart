import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/player_progression.dart';
import '../../domain/rpg_bridge.dart';
import 'player_progression_provider.dart';

/// Parsed player-progression state, derived from `playerProgressionControllerProvider`.
final playerProgressionViewProvider = FutureProvider<PlayerProgression?>((
  ref,
) async {
  final data = await ref.watch(playerProgressionControllerProvider.future);
  if (data == null) return null;
  return _parsePlayerProgression(data);
});

PlayerProgression _parsePlayerProgression(Map<String, dynamic> data) {
  final level = (data['level'] as num?)?.toInt() ?? 1;
  final totalXP = (data['totalXP'] as num?)?.toInt() ?? 0;
  final currentTitle = data['currentTitle'] as String?;
  DateTime? lastWorkoutDate;
  final rawLast = data['lastWorkoutDate'];
  if (rawLast != null) {
    lastWorkoutDate = DateTime.tryParse(rawLast.toString());
  }

  StreakInfo? streak;
  final rawStreak = data['streak'];
  if (rawStreak is Map) {
    streak = StreakInfo(
      currentStreak: (rawStreak['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (rawStreak['longest_streak'] as num?)?.toInt() ?? 0,
      lastActivityDate: rawStreak['last_activity_date'] != null
          ? DateTime.tryParse(rawStreak['last_activity_date'].toString())
          : null,
    );
  }

  final achievements = (data['achievements'] as List? ?? [])
      .map(
        (e) => AchievementSummary.fromJson(Map<String, dynamic>.from(e as Map)),
      )
      .toList();

  final classes = (data['classes'] as List? ?? [])
      .map((e) => ClassProgress.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  final activeQuest = data['activeQuest'] is Map
      ? Map<String, dynamic>.from(data['activeQuest'] as Map)
      : null;
  final nextUnlock = data['nextUnlock'] is Map
      ? Map<String, dynamic>.from(data['nextUnlock'] as Map)
      : null;

  int xpToNextLevel = 0;
  final primary = classes.isNotEmpty
      ? classes.firstWhere(
          (c) => c.slot == 'primary',
          orElse: () => classes.first,
        )
      : null;
  if (primary != null && primary.xpBase != null && primary.xpSlope != null) {
    final nextLevelXP = RPGBridge.classXPForLevel(
      primary.level + 1,
      primary.xpBase!,
      primary.xpSlope!,
    );
    xpToNextLevel = math.max(0, nextLevelXP - totalXP);
  }

  return PlayerProgression(
    userId: data['userId']?.toString() ?? '',
    level: level,
    totalXP: totalXP,
    currentTitle: currentTitle,
    lastWorkoutDate: lastWorkoutDate,
    streak: streak,
    achievements: achievements,
    classes: classes,
    activeQuest: activeQuest,
    nextUnlock: nextUnlock,
    xpToNextLevel: xpToNextLevel,
  );
}
