// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) =>
    _WorkoutExercise(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      exerciseId: json['exercise_id'] as String,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      supersetGroupId: json['superset_group_id'] as String?,
      supersetPosition: (json['superset_position'] as num?)?.toInt(),
      supersetLocked: json['superset_locked'] as bool?,
      mode: workoutModeFromJson(json['mode'] as String?),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      exercise: json['exercises'] == null
          ? null
          : Exercise.fromJson(json['exercises'] as Map<String, dynamic>),
      sets:
          (json['workout_sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkoutExerciseToJson(_WorkoutExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_id': instance.workoutId,
      'exercise_id': instance.exerciseId,
      'order_index': instance.orderIndex,
      'superset_group_id': instance.supersetGroupId,
      'superset_position': instance.supersetPosition,
      'superset_locked': instance.supersetLocked,
      'mode': workoutModeToJson(instance.mode),
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'exercises': instance.exercise,
      'workout_sets': instance.sets,
    };
