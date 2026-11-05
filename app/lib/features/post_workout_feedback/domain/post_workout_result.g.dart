// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_workout_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostWorkoutResult _$PostWorkoutResultFromJson(Map<String, dynamic> json) =>
    _PostWorkoutResult(
      message: json['message'] as String,
      earnedXP: (json['earnedXP'] as num).toInt(),
      totalXP: (json['totalXP'] as num).toInt(),
      newLevel: (json['newLevel'] as num).toInt(),
      leveledUp: json['leveledUp'] as bool,
      isQuest: json['isQuest'] as bool,
      newTitle: json['newTitle'] as String?,
      nextLevelXp: (json['nextLevelXp'] as num).toInt(),
      isSuspicious: json['isSuspicious'] as bool,
      classResults:
          (json['classResults'] as List<dynamic>?)
              ?.map((e) => ClassResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      streak: (json['streak'] as num).toInt(),
    );

Map<String, dynamic> _$PostWorkoutResultToJson(_PostWorkoutResult instance) =>
    <String, dynamic>{
      'message': instance.message,
      'earnedXP': instance.earnedXP,
      'totalXP': instance.totalXP,
      'newLevel': instance.newLevel,
      'leveledUp': instance.leveledUp,
      'isQuest': instance.isQuest,
      'newTitle': instance.newTitle,
      'nextLevelXp': instance.nextLevelXp,
      'isSuspicious': instance.isSuspicious,
      'classResults': instance.classResults,
      'achievements': instance.achievements,
      'streak': instance.streak,
    };

_ClassResult _$ClassResultFromJson(Map<String, dynamic> json) => _ClassResult(
  classId: json['classId'] as String,
  className: json['className'] as String,
  slot: json['slot'] as String,
  xpEarned: (json['xpEarned'] as num).toInt(),
  newTotalXP: (json['newTotalXP'] as num).toInt(),
  newLevel: (json['newLevel'] as num).toInt(),
  leveledUp: json['leveledUp'] as bool,
  isGraduation: json['isGraduation'] as bool,
);

Map<String, dynamic> _$ClassResultToJson(_ClassResult instance) =>
    <String, dynamic>{
      'classId': instance.classId,
      'className': instance.className,
      'slot': instance.slot,
      'xpEarned': instance.xpEarned,
      'newTotalXP': instance.newTotalXP,
      'newLevel': instance.newLevel,
      'leveledUp': instance.leveledUp,
      'isGraduation': instance.isGraduation,
    };
