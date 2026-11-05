import 'routine_models.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';

/// Pure Dart engine for routine operations.
/// No I/O, no randomness, no clock. Deterministic and testable.
class RoutineEngine {
  const RoutineEngine();

  /// Creates a new routine with the given name and exercises.
  Routine create({
    required String userId,
    required String name,
    String? emoji,
    List<RoutineExerciseConfig> exercises = const [],
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Routine name cannot be empty');
    }
    final createdExercises = <RoutineExercise>[];
    for (var i = 0; i < exercises.length; i++) {
      final config = exercises[i];
      createdExercises.add(
        RoutineExercise(
          id: _generateId(),
          routineId: '', // Will be set after routine creation
          exerciseId: config.exerciseId,
          orderIndex: config.orderIndex >= 0 ? config.orderIndex : i,
          sets: config.sets,
          reps: config.reps,
          repsMin: config.repsMin,
          weightKg: config.weightKg,
          durationSeconds: config.durationSeconds,
          restSeconds: config.restSeconds,
          rpeTarget: config.rpeTarget,
          rirTarget: config.rirTarget,
          warmupSets: config.warmupSets,
          mode: config.mode,
          notes: config.notes,
          supersetGroupId: config.supersetGroupId,
          supersetPosition: config.supersetPosition,
          isWarmup: config.isWarmup,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    return Routine(
      id: _generateId(),
      userId: userId,
      name: name.trim(),
      emoji: emoji,
      exercises: createdExercises,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a deep copy of a routine for duplication.
  Routine duplicate(Routine source, {String? newName, String? newEmoji}) {
    if (newName?.trim().isEmpty ?? false) {
      throw ArgumentError('New routine name cannot be empty');
    }

    final groupIdMap = <String, String>{
      for (final groupId in source.supersetGroupIds) groupId: _generateId(),
    };

    return Routine(
      id: _generateId(),
      userId: source.userId,
      name: newName?.trim() ?? '${source.name} (Copy)',
      emoji: newEmoji ?? source.emoji,
      isArchived: false,
      version: 1,
      exercises: source.exercises
          .map(
            (e) => e.copyWith(
              id: _generateId(),
              routineId: '', // Will be set after routine creation
              supersetGroupId: e.supersetGroupId == null
                  ? null
                  : groupIdMap[e.supersetGroupId],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList(),
      supersetGroupIds: source.supersetGroupIds
          .map((groupId) => groupIdMap[groupId]!)
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Adds an exercise to a routine at the specified position.
  Routine addExercise({
    required Routine routine,
    required RoutineExerciseConfig config,
  }) {
    if (config.orderIndex < 0 || config.orderIndex > routine.exercises.length) {
      throw ArgumentError('Invalid position: ${config.orderIndex}');
    }
    final exercises = List<RoutineExercise>.from(routine.exercises);
    exercises.insert(
      config.orderIndex,
      RoutineExercise(
        id: _generateId(),
        routineId: routine.id,
        exerciseId: config.exerciseId,
        orderIndex: config.orderIndex,
        sets: config.sets,
        reps: config.reps,
        repsMin: config.repsMin,
        weightKg: config.weightKg,
        durationSeconds: config.durationSeconds,
        restSeconds: config.restSeconds,
        rpeTarget: config.rpeTarget,
        rirTarget: config.rirTarget,
        warmupSets: config.warmupSets,
        mode: config.mode,
        notes: config.notes,
        supersetGroupId: config.supersetGroupId,
        supersetPosition: config.supersetPosition,
        isWarmup: config.isWarmup,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    // Re-index subsequent exercises
    for (var i = config.orderIndex + 1; i < exercises.length; i++) {
      exercises[i] = exercises[i].copyWith(
        orderIndex: i,
        updatedAt: DateTime.now(),
      );
    }
    return routine.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Removes an exercise from a routine.
  Routine removeExercise({
    required Routine routine,
    required String routineExerciseId,
  }) {
    final index = routine.exercises.indexWhere(
      (e) => e.id == routineExerciseId,
    );
    if (index == -1) {
      throw ArgumentError('Exercise not found in routine: $routineExerciseId');
    }
    final exercises = List<RoutineExercise>.from(routine.exercises);
    exercises.removeAt(index);
    // Re-index subsequent exercises
    for (var i = index; i < exercises.length; i++) {
      exercises[i] = exercises[i].copyWith(
        orderIndex: i,
        updatedAt: DateTime.now(),
      );
    }
    return routine.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Reorders exercises in a routine.
  Routine reorderExercises({
    required Routine routine,
    required int fromIndex,
    required int toIndex,
  }) {
    if (fromIndex < 0 || fromIndex >= routine.exercises.length) {
      throw ArgumentError('Invalid fromIndex: $fromIndex');
    }
    if (toIndex < 0 || toIndex > routine.exercises.length) {
      throw ArgumentError('Invalid toIndex: $toIndex');
    }
    if (fromIndex == toIndex) return routine;

    final exercises = List<RoutineExercise>.from(routine.exercises);
    final item = exercises.removeAt(fromIndex);
    exercises.insert(toIndex, item);

    // Re-index all exercises
    for (var i = 0; i < exercises.length; i++) {
      exercises[i] = exercises[i].copyWith(
        orderIndex: i,
        updatedAt: DateTime.now(),
      );
    }

    return routine.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Replaces an exercise in a routine.
  ///
  /// When [baseConfig] is supplied, its mode determines the target mode and its
  /// non-null values override the preserved configuration. When the target mode
  /// is incompatible with a field, that field is reset. A replacement with no
  /// [baseConfig] keeps the existing configuration and mode.
  Routine replaceExercise({
    required Routine routine,
    required String routineExerciseId,
    required String newExerciseId,
    RoutineExerciseConfig? baseConfig,
  }) {
    final index = routine.exercises.indexWhere(
      (e) => e.id == routineExerciseId,
    );
    if (index == -1) {
      throw ArgumentError('Exercise not found in routine: $routineExerciseId');
    }

    final oldExercise = routine.exercises[index];
    final targetMode = baseConfig?.mode ?? oldExercise.mode;
    final modeChanged = targetMode != oldExercise.mode;

    final targetReps = baseConfig?.reps ?? oldExercise.reps;
    final targetRepsMin = baseConfig?.repsMin ?? oldExercise.repsMin;
    final targetWeight = baseConfig?.weightKg ?? oldExercise.weightKg;
    final targetDuration =
        baseConfig?.durationSeconds ?? oldExercise.durationSeconds;

    final newExercise = oldExercise.copyWith(
      id: oldExercise.id, // Preserve slot identity
      exerciseId: newExerciseId,
      mode: targetMode,
      sets: baseConfig?.sets ?? oldExercise.sets,
      reps: modeChanged
          ? _resetRepsForModeChange(targetMode, targetReps)
          : targetReps,
      repsMin: modeChanged
          ? _resetRepsMinForModeChange(targetMode, targetRepsMin)
          : targetRepsMin,
      weightKg: modeChanged
          ? _resetWeightForModeChange(targetMode, targetWeight)
          : targetWeight,
      durationSeconds: modeChanged
          ? _resetDurationForModeChange(targetMode, targetDuration)
          : targetDuration,
      restSeconds: baseConfig?.restSeconds ?? oldExercise.restSeconds,
      rpeTarget: baseConfig?.rpeTarget ?? oldExercise.rpeTarget,
      rirTarget: baseConfig?.rirTarget ?? oldExercise.rirTarget,
      warmupSets: baseConfig?.warmupSets ?? oldExercise.warmupSets,
      notes: baseConfig?.notes ?? oldExercise.notes,
      supersetGroupId:
          baseConfig?.supersetGroupId ?? oldExercise.supersetGroupId,
      supersetPosition:
          baseConfig?.supersetPosition ?? oldExercise.supersetPosition,
      updatedAt: DateTime.now(),
    );

    final exercises = List<RoutineExercise>.from(routine.exercises);
    exercises[index] = newExercise;

    return routine.copyWith(exercises: exercises, updatedAt: DateTime.now());
  }

  /// Creates a superset group from a list of exercise positions.
  Routine createSupersetGroup({
    required Routine routine,
    required List<int> positions,
  }) {
    if (positions.length < 2) {
      throw ArgumentError('Superset group requires at least 2 exercises');
    }
    positions.sort();
    final exercises = List<RoutineExercise>.from(routine.exercises);

    // Check if any position already has a superset group
    for (final pos in positions) {
      if (pos < 0 || pos >= exercises.length) {
        throw ArgumentError('Invalid position: $pos');
      }
      if (exercises[pos].supersetGroupId != null) {
        throw ArgumentError(
          'Exercise at position $pos already in a superset group',
        );
      }
    }

    // Assign one consistent group id to every member and to the routine index.
    final groupId = _generateId();
    for (var i = 0; i < positions.length; i++) {
      exercises[positions[i]] = exercises[positions[i]].copyWith(
        supersetGroupId: groupId,
        supersetPosition: i,
        updatedAt: DateTime.now(),
      );
    }

    final supersetGroupIds = List<String>.from(routine.supersetGroupIds);
    supersetGroupIds.add(groupId);

    return routine.copyWith(
      exercises: exercises,
      supersetGroupIds: supersetGroupIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a superset group from a routine.
  Routine ungroupSuperset({
    required Routine routine,
    required String supersetGroupId,
  }) {
    final exercises = routine.exercises
        .where((e) => e.supersetGroupId != supersetGroupId)
        .map(
          (e) => e.copyWith(
            supersetGroupId: null,
            supersetPosition: null,
            updatedAt: DateTime.now(),
          ),
        )
        .toList();

    final supersetGroupIds = routine.supersetGroupIds
        .where((id) => id != supersetGroupId)
        .toList();

    return routine.copyWith(
      exercises: exercises,
      supersetGroupIds: supersetGroupIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a routine from a completed workout session.
  Routine fromWorkoutSession({
    required String userId,
    required String name,
    required List<WorkoutExerciseSnapshot> workoutExercises,
    String? emoji,
  }) {
    final exercises = <RoutineExercise>[];
    for (var i = 0; i < workoutExercises.length; i++) {
      final ex = workoutExercises[i];
      exercises.add(
        RoutineExercise(
          id: _generateId(),
          routineId: '', // Will be set after routine creation
          exerciseId: ex.exerciseId,
          orderIndex: i,
          sets: ex.sets,
          reps: ex.reps,
          repsMin: ex.repsMin,
          weightKg: ex.weightKg,
          durationSeconds: ex.durationSeconds,
          restSeconds: ex.restSeconds,
          rpeTarget: ex.rpeTarget,
          rirTarget: ex.rirTarget,
          warmupSets: ex.warmupSets,
          mode: ex.mode,
          notes: ex.notes,
          supersetGroupId: ex.supersetGroupId,
          supersetPosition: ex.supersetPosition,
          isWarmup: ex.isWarmup,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    return Routine(
      id: _generateId(),
      userId: userId,
      name: name,
      emoji: emoji,
      exercises: exercises,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static int _idSequence = 0;

  String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}';

  // Reset incompatible fields when the target mode cannot store them.
  double _resetWeightForModeChange(WorkoutMode newMode, double? weightKg) {
    if (newMode == WorkoutMode.bodyweight ||
        newMode == WorkoutMode.timed ||
        newMode == WorkoutMode.cardio) {
      return 0;
    }
    return weightKg ?? 0;
  }

  int? _resetDurationForModeChange(WorkoutMode newMode, int? durationSeconds) {
    if (newMode == WorkoutMode.repsWeight ||
        newMode == WorkoutMode.bodyweight) {
      return null;
    }
    return durationSeconds;
  }

  int _resetRepsForModeChange(WorkoutMode newMode, int reps) {
    if (newMode == WorkoutMode.timed || newMode == WorkoutMode.cardio) {
      return 0;
    }
    return reps;
  }

  int? _resetRepsMinForModeChange(WorkoutMode newMode, int? repsMin) {
    if (newMode == WorkoutMode.timed || newMode == WorkoutMode.cardio) {
      return null;
    }
    return repsMin;
  }

  // Removed unused _inferModeFromExercise method
}

/// Snapshot of a workout exercise for routine creation
class WorkoutExerciseSnapshot {
  final String exerciseId;
  final int sets;
  final int reps;
  final int? repsMin;
  final double weightKg;
  final int? durationSeconds;
  final int? restSeconds;
  final int? rpeTarget;
  final int? rirTarget;
  final int? warmupSets;
  final WorkoutMode mode;
  final String? notes;
  final String? supersetGroupId;
  final int? supersetPosition;
  final bool isWarmup;

  const WorkoutExerciseSnapshot({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.repsMin,
    required this.weightKg,
    this.durationSeconds,
    this.restSeconds,
    this.rpeTarget,
    this.rirTarget,
    this.warmupSets,
    required this.mode,
    this.notes,
    this.supersetGroupId,
    this.supersetPosition,
    this.isWarmup = false,
  });
}
