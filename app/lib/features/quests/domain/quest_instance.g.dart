// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestInstance _$QuestInstanceFromJson(Map<String, dynamic> json) =>
    _QuestInstance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      questId: json['quest_id'] as String,
      config: (json['prescribed_config'] as List<dynamic>)
          .map((e) => PrescribedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      earnedXp: (json['earned_xp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$QuestInstanceToJson(_QuestInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'quest_id': instance.questId,
      'prescribed_config': instance.config,
      'status': instance.status,
      'expires_at': instance.expiresAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'earned_xp': instance.earnedXp,
    };

_PrescribedExercise _$PrescribedExerciseFromJson(Map<String, dynamic> json) =>
    _PrescribedExercise(
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      weightKg: (json['weight_kg'] as num).toDouble(),
    );

Map<String, dynamic> _$PrescribedExerciseToJson(_PrescribedExercise instance) =>
    <String, dynamic>{
      'exercise_id': instance.exerciseId,
      'exercise_name': instance.exerciseName,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight_kg': instance.weightKg,
    };
