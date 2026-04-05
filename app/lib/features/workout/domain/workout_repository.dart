import 'workout.dart';
import 'workout_exercise.dart';
import 'workout_set.dart';

abstract class WorkoutRepository {
  /// Tạo workout mới (status: active)
  Future<Workout> startWorkout();

  /// Lấy workout đang active (nếu có) — dùng cho auto-resume
  Future<Workout?> getActiveWorkout();

  /// Hoàn thành workout
  Future<Workout> completeWorkout(String workoutId, {String? notes});

  /// Hủy workout
  Future<void> cancelWorkout(String workoutId);

  /// Thêm bài tập vào workout
  Future<WorkoutExercise> addExerciseToWorkout(
      String workoutId, String exerciseId, int orderIndex);

  /// Xóa bài tập khỏi workout (cascade xóa sets)
  Future<void> removeExerciseFromWorkout(String workoutExerciseId);

  /// Sắp xếp lại thứ tự bài tập
  Future<void> reorderExercises(
      String workoutId, List<String> workoutExerciseIds);

  /// Thêm set vào exercise
  Future<WorkoutSet> addSet(
      String workoutExerciseId, int setNumber, int reps, double weightKg);

  /// Cập nhật set
  Future<WorkoutSet> updateSet(String setId,
      {int? reps, double? weightKg, bool? isCompleted, int? restSeconds});

  /// Xóa set
  Future<void> deleteSet(String setId);

  /// Lấy chi tiết workout (bao gồm exercises + sets)
  Future<Workout?> getWorkoutDetail(String workoutId);

  /// Lấy lịch sử workout (phân trang)
  Future<List<Workout>> getWorkoutHistory({int limit = 20, int offset = 0});

  /// Đếm tổng số workout đã hoàn thành
  Future<int> getCompletedWorkoutCount();
}
