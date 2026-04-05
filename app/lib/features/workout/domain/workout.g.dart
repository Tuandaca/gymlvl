// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Workout _$WorkoutFromJson(Map<String, dynamic> json) => _Workout(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  status:
      $enumDecodeNullable(_$WorkoutStatusEnumMap, json['status']) ??
      WorkoutStatus.active,
  durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
  notes: json['notes'] as String?,
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  exercises:
      (json['workout_exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$WorkoutToJson(_Workout instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'status': _$WorkoutStatusEnumMap[instance.status]!,
  'duration_seconds': instance.durationSeconds,
  'notes': instance.notes,
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'workout_exercises': instance.exercises,
};

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.active: 'active',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.cancelled: 'cancelled',
};
