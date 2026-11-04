// Freezed forwards factory parameter JsonKey annotations to generated fields.
// See https://pub.dev/packages/freezed#disabling-invalid_annotation_target-warning-and-warning-in-generates-files
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_set.freezed.dart';
part 'workout_set.g.dart';

@freezed
abstract class WorkoutSet with _$WorkoutSet {
  const WorkoutSet._();

  const factory WorkoutSet({
    required String id,
    @JsonKey(name: 'workout_exercise_id') required String workoutExerciseId,
    @JsonKey(name: 'set_number') @Default(1) int setNumber,
    @Default(0) int reps,
    @JsonKey(name: 'weight_kg') @Default(0) double weightKg,
    @JsonKey(name: 'baseline_weight_kg') @Default(0) double baselineWeightKg,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'rest_seconds') @Default(0) int restSeconds,
    @JsonKey(name: 'duration_seconds') @Default(0) int durationSeconds,

    /// RPE (1-10): NULLABLE, no default — backward compatible with legacy rows.
    @JsonKey(name: 'rpe') int? rpe,

    /// RIR (0-10): NULLABLE, no default — backward compatible with legacy rows.
    @JsonKey(name: 'rir') int? rir,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _WorkoutSet;

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);

  /// RPE (1-10) and RIR (0-10) are optional set-level fields; nullable and
  /// backward compatible — legacy records keep null.
  bool get isRpeValid {
    final value = rpe;
    return value == null || (value >= 1 && value <= 10);
  }

  bool get isRirValid {
    final value = rir;
    return value == null || (value >= 0 && value <= 10);
  }

  bool get isValid => isCompleted ? (reps > 0 || durationSeconds > 0) : true;
}
