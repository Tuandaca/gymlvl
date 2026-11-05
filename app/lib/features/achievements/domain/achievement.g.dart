// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Achievement _$AchievementFromJson(Map<String, dynamic> json) => _Achievement(
  achievementId: json['achievementId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
  isEarned: json['isEarned'] as bool,
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'achievementId': instance.achievementId,
      'title': instance.title,
      'description': instance.description,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'isEarned': instance.isEarned,
    };
