// Freezed forwards factory parameter JsonKey annotations to generated fields.
// See https://pub.dev/packages/freezed#disabling-invalid_annotation_target-warning-and-warning-in-generates-files
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_exercise.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

enum WorkoutStatus {
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
abstract class Workout with _$Workout {
  const factory Workout({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @Default(WorkoutStatus.active) WorkoutStatus status,
    @JsonKey(name: 'duration_seconds') @Default(0) int durationSeconds,
    String? notes,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'training_started_at') DateTime? trainingStartedAt,
    @JsonKey(name: 'paused_at') DateTime? pausedAt,
    @JsonKey(name: 'paused_seconds') @Default(0) int pausedSeconds,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    /// Nested workout exercises (from join query)
    @JsonKey(name: 'workout_exercises')
    @Default([])
    List<WorkoutExercise> exercises,
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);
}
