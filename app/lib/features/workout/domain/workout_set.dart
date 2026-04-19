import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_set.freezed.dart';
part 'workout_set.g.dart';

@freezed
abstract class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    required String id,
    @JsonKey(name: 'workout_exercise_id') required String workoutExerciseId,
    @JsonKey(name: 'set_number') @Default(1) int setNumber,
    @Default(0) int reps,
    @JsonKey(name: 'weight_kg') @Default(0) double weightKg,
    @JsonKey(name: 'baseline_weight_kg') @Default(0) double baselineWeightKg,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'rest_seconds') @Default(0) int restSeconds,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _WorkoutSet;

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);
}
