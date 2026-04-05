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
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'exercises': instance.exercise,
      'workout_sets': instance.sets,
    };
