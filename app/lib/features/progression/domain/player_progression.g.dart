// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerProgression _$PlayerProgressionFromJson(Map<String, dynamic> json) =>
    _PlayerProgression(
      userId: json['userId'] as String,
      level: (json['level'] as num).toInt(),
      totalXP: (json['totalXP'] as num).toInt(),
      currentTitle: json['currentTitle'] as String?,
      lastWorkoutDate: json['lastWorkoutDate'] == null
          ? null
          : DateTime.parse(json['lastWorkoutDate'] as String),
      streak: json['streak'] == null
          ? null
          : StreakInfo.fromJson(json['streak'] as Map<String, dynamic>),
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map(
                (e) => AchievementSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      classes:
          (json['classes'] as List<dynamic>?)
              ?.map((e) => ClassProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activeQuest: json['activeQuest'] as Map<String, dynamic>?,
      nextUnlock: json['nextUnlock'] as Map<String, dynamic>?,
      xpToNextLevel: (json['xpToNextLevel'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PlayerProgressionToJson(_PlayerProgression instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'level': instance.level,
      'totalXP': instance.totalXP,
      'currentTitle': instance.currentTitle,
      'lastWorkoutDate': instance.lastWorkoutDate?.toIso8601String(),
      'streak': instance.streak,
      'achievements': instance.achievements,
      'classes': instance.classes,
      'activeQuest': instance.activeQuest,
      'nextUnlock': instance.nextUnlock,
      'xpToNextLevel': instance.xpToNextLevel,
    };

_StreakInfo _$StreakInfoFromJson(Map<String, dynamic> json) => _StreakInfo(
  currentStreak: (json['currentStreak'] as num).toInt(),
  longestStreak: (json['longestStreak'] as num).toInt(),
  lastActivityDate: json['lastActivityDate'] == null
      ? null
      : DateTime.parse(json['lastActivityDate'] as String),
);

Map<String, dynamic> _$StreakInfoToJson(_StreakInfo instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastActivityDate': instance.lastActivityDate?.toIso8601String(),
    };

_ClassProgress _$ClassProgressFromJson(Map<String, dynamic> json) =>
    _ClassProgress(
      classId: json['classId'] as String,
      className: json['className'] as String,
      slot: json['slot'] as String,
      currentXP: (json['currentXP'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      isGraduated: json['isGraduated'] as bool,
      xpBase: (json['xpBase'] as num?)?.toInt(),
      xpSlope: (json['xpSlope'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ClassProgressToJson(_ClassProgress instance) =>
    <String, dynamic>{
      'classId': instance.classId,
      'className': instance.className,
      'slot': instance.slot,
      'currentXP': instance.currentXP,
      'level': instance.level,
      'isGraduated': instance.isGraduated,
      'xpBase': instance.xpBase,
      'xpSlope': instance.xpSlope,
    };

_AchievementSummary _$AchievementSummaryFromJson(Map<String, dynamic> json) =>
    _AchievementSummary(
      achievementId: json['achievementId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$AchievementSummaryToJson(_AchievementSummary instance) =>
    <String, dynamic>{
      'achievementId': instance.achievementId,
      'unlockedAt': instance.unlockedAt.toIso8601String(),
    };
