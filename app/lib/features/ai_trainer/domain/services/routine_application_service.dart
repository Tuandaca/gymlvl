/// Service for applying AI workout/routine recommendations through existing
/// GymLvl repositories.
///
/// AI is advisory: the client proposes, the user approves, and existing
/// repository RPCs apply the change. This service never mutates workout data
/// directly — it delegates to `public.workout_exercises`/`public.workouts`
/// via `WorkoutRepository`.
library;

import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import '../../domain/models/pt_recommendation.dart';

/// Result of applying a recommendation through existing repository APIs.
class RoutineApplicationResult {
  const RoutineApplicationResult({
    required this.applied,
    required this.message,
    this.workoutId,
    this.workoutExerciseId,
  });

  final bool applied;
  final String message;
  final String? workoutId;
  final String? workoutExerciseId;

  bool get isRejected => !applied;
}

/// Service that applies AI recommendations through existing repository APIs.
///
/// All mutations go through `public.workout_exercises`/`public.workouts`
/// via the `WorkoutRepository` interface — this service never mutates workout
/// data directly — it delegates to existing repository APIs.
class RoutineApplicationService {
  RoutineApplicationService(
    this.repository, {
    this.knownExerciseIds = const {},
  });

  final WorkoutRepository repository;
  final Set<String> knownExerciseIds;

  /// Apply an AI recommendation to the given workout.
  ///
  /// Returns a [RoutineApplicationResult]. On rejection, [applied] is false and
  /// [message] explains why. No mutation happens unless [isValidated] is true.
  Future<RoutineApplicationResult> applyRecommendation(
    String workoutId,
    PtRecommendationItem item,
  ) async {
    // 1. Validate the recommendation target.
    if (!item.isValidated) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Recommendation failed validation and cannot be applied.',
      );
    }

    // 2. Validate exercise ID is known (non-empty UUID format).
    final exerciseId = item.exerciseId;
    if (exerciseId == null || exerciseId.trim().isEmpty) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Recommendation targets an unknown exercise ID.',
      );
    }
    if (knownExerciseIds.isNotEmpty && !knownExerciseIds.contains(exerciseId)) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Recommendation targets an unknown exercise ID.',
      );
    }

    // 3. Dispatch based on recommendation type.
    switch (item.type) {
      case PtRecommendationType.exerciseAddition:
        return await _applyExerciseAddition(workoutId, item);
      case PtRecommendationType.exerciseRemoval:
        return await _applyExerciseRemoval(workoutId, item);
      case PtRecommendationType.exerciseReplacement:
        return await _applyExerciseReplacement(workoutId, item);
      case PtRecommendationType.exerciseAdjustment:
        // Exercise adjustment maps to weight/reps/rest adjustments; treat as advisory.
        return _unsupported(
          'Exercise adjustment is handled by specific adjustment types.',
        );
      case PtRecommendationType.setRepsAdjustment:
        return await _applySetRepsAdjustment(workoutId, item);
      case PtRecommendationType.weightAdjustment:
        return await _applyWeightAdjustment(workoutId, item);
      case PtRecommendationType.restAdjustment:
        return await _applyRestAdjustment(workoutId, item);
      case PtRecommendationType.frequencyAdjustment:
        return _unsupported('Frequency adjustment is not supported.');
      case PtRecommendationType.progressionStrategy:
        return _unsupported('Progression strategy is advisory only.');
      case PtRecommendationType.recoveryAdjustment:
        return _unsupported('Recovery adjustment is advisory only.');
      case PtRecommendationType.general:
        return _unsupported('General advice cannot be applied automatically.');
    }
  }

  Future<RoutineApplicationResult> _applyExerciseAddition(
    String workoutId,
    PtRecommendationItem item,
  ) async {
    final exerciseId = item.exerciseId!;
    final target = item.target;

    final orderIndex = (target['orderIndex'] as int?) ?? 0;

    try {
      final exercise = await repository.addExerciseToWorkout(
        workoutId,
        exerciseId,
        orderIndex,
      );
      return RoutineApplicationResult(
        applied: true,
        message: 'Exercise added to workout.',
        workoutId: workoutId,
        workoutExerciseId: exercise.id,
      );
    } catch (e) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Failed to add exercise to workout: ${e.toString()}',
      );
    }
  }

  Future<RoutineApplicationResult> _applyExerciseRemoval(
    String workoutId,
    PtRecommendationItem item,
  ) async {
    final workoutExerciseId = item.exerciseId;
    if (workoutExerciseId == null || workoutExerciseId.isEmpty) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot remove exercise: no workout exercise ID provided.',
      );
    }

    try {
      await repository.removeExerciseFromWorkout(workoutExerciseId);
      return RoutineApplicationResult(
        applied: true,
        message: 'Exercise removed from workout.',
        workoutId: workoutId,
        workoutExerciseId: workoutExerciseId,
      );
    } catch (e) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Failed to remove exercise from workout: ${e.toString()}',
      );
    }
  }

  Future<RoutineApplicationResult> _applyExerciseReplacement(
    String workoutId,
    PtRecommendationItem item,
  ) async {
    final workoutExerciseId = item.exerciseId;
    final newExerciseId = item.exerciseName;
    if (workoutExerciseId == null || workoutExerciseId.isEmpty) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot replace exercise: no workout exercise ID provided.',
      );
    }
    if (newExerciseId == null || newExerciseId.isEmpty) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot replace exercise: no target exercise ID provided.',
      );
    }

    try {
      final exercise = await repository.replaceExercise(
        workoutExerciseId,
        newExerciseId,
      );
      return RoutineApplicationResult(
        applied: true,
        message: 'Exercise replaced in workout.',
        workoutId: workoutId,
        workoutExerciseId: exercise.id,
      );
    } catch (e) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Failed to replace exercise in workout: ${e.toString()}',
      );
    }
  }

  Future<RoutineApplicationResult> _applySetRepsAdjustment(
    String workoutId,
    PtRecommendationItem item,
  ) async {
    final workoutExerciseId = item.exerciseId;
    if (workoutExerciseId == null || workoutExerciseId.isEmpty) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot adjust set: no workout exercise ID provided.',
      );
    }

    final target = item.target;
    final newReps = target['reps'] as int?;
    if (newReps == null || newReps < 1 || newReps > 1000) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot adjust set: invalid reps value.',
      );
    }

    try {
      final set = await repository.updateSet(workoutExerciseId, reps: newReps);
      return RoutineApplicationResult(
        applied: true,
        message: 'Set reps updated.',
        workoutId: workoutId,
        workoutExerciseId: workoutExerciseId,
      );
    } catch (e) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Failed to update set reps: ${e.toString()}',
      );
    }
  }

  Future<RoutineApplicationResult> _applyWeightAdjustment(
    String workoutId,
    PtRecommendationItem item,
  ) async {
    final workoutExerciseId = item.exerciseId;
    if (workoutExerciseId == null || workoutExerciseId.isEmpty) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot adjust weight: no workout exercise ID provided.',
      );
    }

    final target = item.target;
    final newWeight = target['weight_kg'] as double?;
    if (newWeight == null || newWeight < 0 || newWeight > 1000) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot adjust weight: invalid weight value.',
      );
    }

    try {
      final set = await repository.updateSet(
        workoutExerciseId,
        weightKg: newWeight,
      );
      return RoutineApplicationResult(
        applied: true,
        message: 'Set weight updated.',
        workoutId: workoutId,
        workoutExerciseId: workoutExerciseId,
      );
    } catch (e) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Failed to update set weight: ${e.toString()}',
      );
    }
  }

  Future<RoutineApplicationResult> _applyRestAdjustment(
    String workoutId,
    PtRecommendationItem item,
  ) async {
    final workoutExerciseId = item.exerciseId;
    if (workoutExerciseId == null || workoutExerciseId.isEmpty) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot adjust rest: no workout exercise ID provided.',
      );
    }

    final target = item.target;
    final newRest = target['rest_seconds'] as int?;
    if (newRest == null || newRest < 0 || newRest > 7200) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Cannot adjust rest: invalid rest value.',
      );
    }

    try {
      final set = await repository.updateSet(
        workoutExerciseId,
        restSeconds: newRest,
      );
      return RoutineApplicationResult(
        applied: true,
        message: 'Set rest time updated.',
        workoutId: workoutId,
        workoutExerciseId: workoutExerciseId,
      );
    } catch (e) {
      return RoutineApplicationResult(
        applied: false,
        message: 'Failed to update rest time: ${e.toString()}',
      );
    }
  }

  RoutineApplicationResult _unsupported(String message) {
    return RoutineApplicationResult(applied: false, message: message);
  }
}
