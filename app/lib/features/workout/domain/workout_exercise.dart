import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise.dart';
import 'workout_set.dart';

part 'workout_exercise.freezed.dart';
part 'workout_exercise.g.dart';

@freezed
abstract class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    required String id,
    @JsonKey(name: 'workout_id') required String workoutId,
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,

    /// Nested exercise detail (from join query)
    @JsonKey(name: 'exercises') Exercise? exercise,

    /// Nested sets (from join query)
    @JsonKey(name: 'workout_sets') @Default([]) List<WorkoutSet> sets,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);
}
