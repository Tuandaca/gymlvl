import 'workout.dart';
import 'workout_exercise.dart';
import 'workout_set.dart';
import 'workout_mode_contract.dart';

/// A full desired layout. The server applies every group in one transaction.
class SupersetGroupLayout {
  final String groupId;
  final List<String> workoutExerciseIds;

  SupersetGroupLayout(this.groupId, List<String> workoutExerciseIds)
    : workoutExerciseIds = List.unmodifiable(workoutExerciseIds);

  Map<String, Object> toJson() => {
    'group_id': groupId,
    'exercise_ids': workoutExerciseIds,
  };
}

/// Optional capabilities keep older repository test doubles source compatible.
abstract interface class SupersetLayoutRepository {
  Future<void> setSupersetLayout(
    String workoutId,
    List<SupersetGroupLayout> groups,
  );
}

class SupersetLayoutLocked implements Exception {
  const SupersetLayoutLocked();
}

abstract interface class ModeAwareWorkoutRepository {
  Future<WorkoutExercise> addExerciseToWorkoutWithMode(
    String workoutId,
    String exerciseId,
    int orderIndex,
    WorkoutMode mode,
  );
}

/// Multi-row workout edits must be acknowledged by one server transaction.
/// The request ID and payload are reused after an uncertain response.
abstract interface class AtomicWorkoutMutationRepository {
  Future<Workout> addExerciseWithDefaultSets({
    required String operationId,
    required String workoutId,
    required String exerciseId,
    required WorkoutMode? mode,
    required List<Map<String, Object>> sets,
  });

  Future<Workout> reorderWorkoutExercisesAtomically({
    required String operationId,
    required String workoutId,
    required List<String> exerciseIds,
  });
}

/// A server-acknowledged historical import. It never awards workout rewards.
class HistoricalWorkoutImportReceipt {
  final String workoutId;
  final bool alreadyImported;
  final List<String> createdCustomExerciseIds;

  const HistoricalWorkoutImportReceipt({
    required this.workoutId,
    required this.alreadyImported,
    this.createdCustomExerciseIds = const [],
  });
}

/// Optional capability so interactive workout operations cannot be used as an
/// accidental fallback for historical imports.
abstract interface class HistoricalWorkoutImportRepository {
  Future<HistoricalWorkoutImportReceipt> importHistoricalWorkout({
    required String importKey,
    required Map<String, dynamic> payload,
  });
}

class HistoricalMeasurementImportReceipt {
  final String measurementId;
  final bool alreadyImported;

  const HistoricalMeasurementImportReceipt({
    required this.measurementId,
    required this.alreadyImported,
  });
}

abstract interface class HistoricalMeasurementImportRepository {
  Future<HistoricalMeasurementImportReceipt> importHistoricalMeasurement({
    required String importKey,
    required Map<String, dynamic> payload,
  });
}

/// Authenticated owner observed by the repository adapter, independently of
/// any owner ID supplied by an imported file or the caller.
abstract interface class HistoricalImportIdentity {
  String get authenticatedUserId;
}

class HistoricalCustomExerciseImportReceipt {
  final String exerciseId;
  final bool alreadyImported;
  final bool created;

  const HistoricalCustomExerciseImportReceipt({
    required this.exerciseId,
    required this.alreadyImported,
    required this.created,
  });
}

abstract interface class HistoricalCustomExerciseImportRepository {
  Future<HistoricalCustomExerciseImportReceipt> importCustomExercise({
    required String importKey,
    required Map<String, dynamic> payload,
  });
}

abstract class WorkoutRepository {
  /// Tạo workout mới (status: active)
  Future<Workout> startWorkout();

  /// Lấy workout đang active (nếu có) — dùng cho auto-resume
  Future<Workout?> getActiveWorkout();

  Future<Workout> beginWorkout(String workoutId);

  Future<Workout> setWorkoutPaused(String workoutId, bool paused);

  /// Completion and rewards commit in one database transaction. Safe to retry.
  Future<WorkoutCompletion> finishWorkout(String workoutId, {String? notes});

  /// Load detail for an acknowledged receipt without another award RPC.
  Future<WorkoutCompletion> reconcileCompletion(WorkoutReceipt receipt);

  /// Hoàn thành workout
  Future<Workout> completeWorkout(String workoutId, {String? notes});

  /// Hủy workout
  Future<void> cancelWorkout(String workoutId);

  /// Cập nhật ghi chú của workout đang active.
  Future<Workout> updateWorkoutNotes(String workoutId, String notes);

  /// Thêm bài tập vào workout
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  );

  /// Xóa bài tập khỏi workout (cascade xóa sets)
  Future<void> removeExerciseFromWorkout(String workoutExerciseId);

  /// Thay thế bài tập trong workout đang active, giữ nguyên vị trí (orderIndex),
  /// nhóm superset và các thiết lập đã có. Không xóa tập đã hoàn thành.
  Future<WorkoutExercise> replaceExercise(
    String workoutExerciseId,
    String newExerciseId,
  );

  /// Sắp xếp lại thứ tự bài tập
  Future<void> reorderExercises(
    String workoutId,
    List<String> workoutExerciseIds,
  );

  /// Thêm set vào exercise
  Future<WorkoutSet> addSet(
    String workoutExerciseId,
    int setNumber,
    int reps,
    double weightKg, {
    double baselineWeightKg = 0,
    int durationSeconds = 0,
  });

  /// Cập nhật set
  Future<WorkoutSet> updateSet(
    String setId, {
    int? reps,
    double? weightKg,
    WorkoutSetType? setType,
    bool? isCompleted,
    int? restSeconds,
    int? durationSeconds,
  });

  /// Xóa set
  Future<void> deleteSet(String setId);

  /// Lấy mức tạ của set tập gần nhất cho bài tập này (Historical tracking)
  Future<WorkoutSet?> getLastSetForExercise(String exerciseId);

  /// Lấy chi tiết workout (bao gồm exercises + sets)
  Future<Workout?> getWorkoutDetail(String workoutId);

  /// Lấy lịch sử workout (phân trang)
  Future<List<Workout>> getWorkoutHistory({int limit = 20, int offset = 0});

  /// Đếm tổng số workout đã hoàn thành
  Future<int> getCompletedWorkoutCount();

  /// Tính toán XP và Level cho Workout đã hoàn thành qua Edge Function
  Future<Map<String, dynamic>> calculateXP(String workoutId);

  /// Đánh dấu một workout nhập từ lịch sử là hoàn thành KHÔNG tặng XP.
  ///
  /// Legacy compatibility path. Historical imports use
  /// [HistoricalWorkoutImportRepository] instead; `complete_workout` remains
  /// the only reward path.
  Future<Workout> markWorkoutCompleted(
    String workoutId, {
    DateTime? completedAt,
    int? durationSeconds,
    String? notes,
  });
}

class WorkoutCompletion {
  final Workout workout;
  final Map<String, dynamic> rewards;

  const WorkoutCompletion(this.workout, this.rewards);
}

/// Rewards are authoritative; request identity is captured, not returned by the RPC.
/// No completed workout is inferred from this rewards-only acknowledgement.
class WorkoutReceipt {
  final String workoutId;
  final String userId;
  final Map<String, dynamic> rewards;

  WorkoutReceipt(this.workoutId, this.userId, Map<String, dynamic> rewards)
    : rewards = Map.unmodifiable(rewards);
}

class WorkoutReconciliationRequired implements Exception {
  final WorkoutReceipt receipt;
  const WorkoutReconciliationRequired(this.receipt);
}

class WorkoutCompletionUncertain implements Exception {
  const WorkoutCompletionUncertain();
}

class WorkoutCompletionRejected implements Exception {
  const WorkoutCompletionRejected();
}
