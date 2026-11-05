import 'routine_models.dart';

/// Abstract repository interface for routine operations.
abstract class RoutineRepository {
  /// Get all routines for the current user.
  Future<List<Routine>> getRoutines();

  /// Get a specific routine by ID.
  Future<Routine?> getRoutine(String routineId);

  /// Create a new routine.
  Future<Routine> createRoutine(Routine routine);

  /// Update an existing routine.
  Future<Routine> updateRoutine(Routine routine);

  /// Archive (soft delete) a routine.
  Future<void> archiveRoutine(String routineId);

  /// Restore an archived routine.
  Future<void> restoreRoutine(String routineId);

  /// Permanently delete a routine (only if no history references it).
  Future<void> deleteRoutine(String routineId);

  /// Duplicate a routine.
  Future<Routine> duplicateRoutine({
    required String routineId,
    required String newName,
    String? emoji,
  });

  /// Routine Exercises
  Future<Routine> addExerciseToRoutine({
    required String routineId,
    required RoutineExerciseConfig config,
  });

  Future<Routine> updateRoutineExercise({
    required String routineId,
    required RoutineExerciseConfig config,
  });

  Future<Routine> removeExerciseFromRoutine({
    required String routineId,
    required String routineExerciseId,
  });

  Future<Routine> reorderExercises({
    required String routineId,
    required List<String> exerciseIds,
  });

  Future<Routine> replaceExerciseInRoutine({
    required String routineId,
    required String routineExerciseId,
    required String newExerciseId,
    RoutineExerciseConfig? baseConfig,
  });

  Future<Routine> createSupersetGroup({
    required String routineId,
    required List<String> routineExerciseIds,
  });

  Future<Routine> ungroupSuperset({
    required String routineId,
    required String supersetGroupId,
  });

  /// Schedules
  Future<List<RoutineSchedule>> getSchedules(String routineId);
  Future<RoutineSchedule> scheduleRoutine({
    required String routineId,
    required ScheduleRoutineConfig config,
  });
  Future<void> removeSchedule(String scheduleId);
  Future<void> reschedule({
    required String scheduleId,
    required DateTime newDate,
  });

  /// Planned Workouts
  Future<List<PlannedWorkout>> getPlannedWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<PlannedWorkout?> getNextPlannedWorkout();
  Future<PlannedWorkout> createPlannedWorkout({
    required String routineId,
    required DateTime scheduledDate,
  });
  Future<PlannedWorkout> startPlannedWorkout(String plannedWorkoutId);
  Future<void> completePlannedWorkout({
    required String plannedWorkoutId,
    required String workoutId,
  });
  Future<PlannedWorkout> repeatWorkout(String completedWorkoutId);
  Future<void> cancelPlannedWorkout(String plannedWorkoutId);
}
