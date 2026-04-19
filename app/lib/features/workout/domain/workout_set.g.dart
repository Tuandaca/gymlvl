// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => _WorkoutSet(
  id: json['id'] as String,
  workoutExerciseId: json['workout_exercise_id'] as String,
  setNumber: (json['set_number'] as num?)?.toInt() ?? 1,
  reps: (json['reps'] as num?)?.toInt() ?? 0,
  weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
  baselineWeightKg: (json['baseline_weight_kg'] as num?)?.toDouble() ?? 0,
  isCompleted: json['is_completed'] as bool? ?? false,
  restSeconds: (json['rest_seconds'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$WorkoutSetToJson(_WorkoutSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_exercise_id': instance.workoutExerciseId,
      'set_number': instance.setNumber,
      'reps': instance.reps,
      'weight_kg': instance.weightKg,
      'baseline_weight_kg': instance.baselineWeightKg,
      'is_completed': instance.isCompleted,
      'rest_seconds': instance.restSeconds,
      'created_at': instance.createdAt?.toIso8601String(),
    };
