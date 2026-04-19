// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileDraft _$UserProfileDraftFromJson(Map<String, dynamic> json) =>
    _UserProfileDraft(
      environment: json['environment'] as String?,
      goals:
          (json['goals'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      primaryClassId: json['primaryClassId'] as String?,
      secondaryClassId: json['secondaryClassId'] as String?,
      className: json['className'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      weeklyGymDays: (json['weeklyGymDays'] as num?)?.toInt() ?? 3,
      weeklyHomeDays: (json['weeklyHomeDays'] as num?)?.toInt() ?? 0,
      preferredDays:
          (json['preferredDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserProfileDraftToJson(_UserProfileDraft instance) =>
    <String, dynamic>{
      'environment': instance.environment,
      'goals': instance.goals,
      'primaryClassId': instance.primaryClassId,
      'secondaryClassId': instance.secondaryClassId,
      'className': instance.className,
      'experienceLevel': instance.experienceLevel,
      'age': instance.age,
      'gender': instance.gender,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'weeklyGymDays': instance.weeklyGymDays,
      'weeklyHomeDays': instance.weeklyHomeDays,
      'preferredDays': instance.preferredDays,
    };
