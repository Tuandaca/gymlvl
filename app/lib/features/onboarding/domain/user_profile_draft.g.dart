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
      className: json['className'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserProfileDraftToJson(_UserProfileDraft instance) =>
    <String, dynamic>{
      'environment': instance.environment,
      'goals': instance.goals,
      'className': instance.className,
      'experienceLevel': instance.experienceLevel,
      'age': instance.age,
      'gender': instance.gender,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
    };
