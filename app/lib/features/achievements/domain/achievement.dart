/// Achievement domain model for the P5 achievement system.
///
/// Achievements are earned server-side via `complete_workout` and reported
/// through `get_player_progression()`. The client only previews them — it never
/// writes `user_achievements`.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// A single achievement with its earned/locked state.
@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required String achievementId,
    required String title,
    required String description,
    DateTime? unlockedAt,
    required bool isEarned,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Static catalogue of achievement titles/descriptions.
///
/// Mirrors the `user_achievements.achievement_id` CHECK constraint seeded by
/// migration `20261106000300_p5_game_integration.sql`. Every ID is derivable
/// server-side from validated completion data, so the client only needs the
/// display text.
class AchievementCatalog {
  AchievementCatalog._();

  static const Map<String, AchievementEntry> _entries = {
    'first_workout': AchievementEntry(
      titleVi: 'Buổi tập đầu tiên',
      titleEn: 'First Workout',
      descVi: 'Hoàn thành một buổi tập để bắt đầu hành trình RPG của bạn.',
      descEn: 'Complete your first workout to begin your RPG journey.',
    ),
    'five_workouts': AchievementEntry(
      titleVi: '5 Buổi tập',
      titleEn: '5 Workouts',
      descVi: 'Hoàn thành 5 buổi tập để xây dựng thói quen tập luyện.',
      descEn: 'Complete 5 workouts to build a training habit.',
    ),
    'ten_workouts': AchievementEntry(
      titleVi: '10 Buổi tập',
      titleEn: '10 Workouts',
      descVi: 'Hoàn thành 10 buổi tập để chứng minh sự kiên trì.',
      descEn: 'Complete 10 workouts to prove your consistency.',
    ),
    'streak_3': AchievementEntry(
      titleVi: 'Chuỗi 3 ngày',
      titleEn: '3-Day Streak',
      descVi: 'Tập luyện trên 3 ngày riêng biệt liên tiếp.',
      descEn: 'Train on 3 separate days in a row.',
    ),
    'streak_7': AchievementEntry(
      titleVi: 'Chuỗi 7 ngày',
      titleEn: '7-Day Streak',
      descVi: 'Tập luyện trên 7 ngày riêng biệt liên tiếp.',
      descEn: 'Train on 7 separate days in a row.',
    ),
    'level_10': AchievementEntry(
      titleVi: 'Cấp độ 10',
      titleEn: 'Level 10',
      descVi: 'Đạt cấp độ 10 trong hệ phái của bạn.',
      descEn: 'Reach Level 10 in your class.',
    ),
    'level_20': AchievementEntry(
      titleVi: 'Cấp độ 20',
      titleEn: 'Level 20',
      descVi: 'Đạt cấp độ 20 (độ hoàn thành tối đa).',
      descEn: 'Reach Level 20 (graduation).',
    ),
  };

  /// All catalogue IDs in display order.
  static List<String> get ids => _entries.keys.toList();

  /// Lookup display text for an [achievementId], respecting the locale mode.
  static AchievementEntry entry(String achievementId) =>
      _entries[achievementId] ??
      AchievementEntry(
        titleVi: achievementId,
        titleEn: achievementId,
        descVi: '',
        descEn: '',
      );

  /// Display title (VI) for an [achievementId], fallback to the raw id.
  static String titleOf(String achievementId) => entry(achievementId).titleVi;

  /// Display description (VI) for an [achievementId].
  static String descOf(String achievementId) => entry(achievementId).descVi;
}

/// Catalogue entry with bilingual display text.
class AchievementEntry {
  final String titleVi;
  final String titleEn;
  final String descVi;
  final String descEn;

  const AchievementEntry({
    required this.titleVi,
    required this.titleEn,
    required this.descVi,
    required this.descEn,
  });
}
