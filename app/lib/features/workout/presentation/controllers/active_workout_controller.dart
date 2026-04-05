import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/exercise.dart';
import '../../domain/workout.dart';
import '../../domain/workout_exercise.dart';
import '../../domain/workout_set.dart';
import '../../domain/workout_repository.dart';
import '../providers/exercise_providers.dart';

part 'active_workout_controller.freezed.dart';

// ─── Active Workout State ───

@freezed
abstract class ActiveWorkoutState with _$ActiveWorkoutState {
  const factory ActiveWorkoutState({
    Workout? workout,
    @Default([]) List<WorkoutExercise> exercises,
    @Default(0) int elapsedSeconds,
    @Default(false) bool isResting,
    @Default(0) int restSecondsRemaining,
    @Default(0) int restSecondsTotal,
    @Default(false) bool isLoading,
    @Default(false) bool isCompleting,
    String? errorMessage,
  }) = _ActiveWorkoutState;

  const ActiveWorkoutState._();

  bool get hasActiveWorkout =>
      workout != null && workout!.status == WorkoutStatus.active;

  String get formattedElapsed {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedRest {
    final minutes = (restSecondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (restSecondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get restProgress {
    if (restSecondsTotal == 0) return 0;
    return 1.0 - (restSecondsRemaining / restSecondsTotal);
  }

  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);
  int get completedSets =>
      exercises.fold(
          0, (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length);
}

// ─── Controller (Riverpod 3.x Notifier) ───

class ActiveWorkoutController extends Notifier<ActiveWorkoutState> {
  Timer? _workoutTimer;
  Timer? _restTimer;

  WorkoutRepository get _repository => ref.read(workoutRepositoryProvider);

  @override
  ActiveWorkoutState build() {
    ref.onDispose(() {
      _workoutTimer?.cancel();
      _restTimer?.cancel();
    });
    return const ActiveWorkoutState();
  }

  /// Kiểm tra xem có workout đang dở dang không (auto-resume)
  Future<void> checkForActiveWorkout() async {
    state = state.copyWith(isLoading: true);
    try {
      final activeWorkout = await _repository.getActiveWorkout();
      if (activeWorkout != null) {
        final elapsed = activeWorkout.startedAt != null
            ? DateTime.now()
                .toUtc()
                .difference(activeWorkout.startedAt!)
                .inSeconds
            : 0;

        state = state.copyWith(
          workout: activeWorkout,
          exercises: activeWorkout.exercises,
          elapsedSeconds: elapsed,
          isLoading: false,
        );
        _startWorkoutTimer();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Bắt đầu buổi tập mới
  Future<void> startWorkout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final workout = await _repository.startWorkout();
      state = state.copyWith(
        workout: workout,
        exercises: [],
        elapsedSeconds: 0,
        isLoading: false,
      );
      _startWorkoutTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Thêm bài tập vào workout
  Future<void> addExercise(Exercise exercise) async {
    if (state.workout == null) return;
    try {
      final workoutExercise = await _repository.addExerciseToWorkout(
        state.workout!.id,
        exercise.id,
        state.exercises.length,
      );
      state = state.copyWith(
        exercises: [...state.exercises, workoutExercise],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Thêm nhiều bài tập cùng lúc
  Future<void> addExercises(List<Exercise> exercises) async {
    for (final exercise in exercises) {
      await addExercise(exercise);
    }
  }

  /// Xóa bài tập khỏi workout
  Future<void> removeExercise(String workoutExerciseId) async {
    try {
      await _repository.removeExerciseFromWorkout(workoutExerciseId);
      state = state.copyWith(
        exercises:
            state.exercises.where((e) => e.id != workoutExerciseId).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Thêm set vào exercise
  Future<void> addSet(String workoutExerciseId,
      {int reps = 0, double weightKg = 0}) async {
    try {
      final exercise =
          state.exercises.firstWhere((e) => e.id == workoutExerciseId);
      final setNumber = exercise.sets.length + 1;

      final newSet = await _repository.addSet(
        workoutExerciseId,
        setNumber,
        reps,
        weightKg,
      );

      state = state.copyWith(
        exercises: state.exercises.map((e) {
          if (e.id == workoutExerciseId) {
            return e.copyWith(sets: [...e.sets, newSet]);
          }
          return e;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Cập nhật set
  Future<void> updateSet(String workoutExerciseId, String setId,
      {int? reps, double? weightKg, bool? isCompleted}) async {
    try {
      final updatedSet = await _repository.updateSet(
        setId,
        reps: reps,
        weightKg: weightKg,
        isCompleted: isCompleted,
      );

      state = state.copyWith(
        exercises: state.exercises.map((e) {
          if (e.id == workoutExerciseId) {
            return e.copyWith(
              sets: e.sets.map((s) {
                if (s.id == setId) return updatedSet;
                return s;
              }).toList(),
            );
          }
          return e;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Xóa set
  Future<void> deleteSet(String workoutExerciseId, String setId) async {
    try {
      await _repository.deleteSet(setId);

      state = state.copyWith(
        exercises: state.exercises.map((e) {
          if (e.id == workoutExerciseId) {
            final updatedSets =
                e.sets.where((s) => s.id != setId).toList();
            final renumbered = updatedSets.asMap().entries.map((entry) {
              return entry.value.copyWith(setNumber: entry.key + 1);
            }).toList();
            return e.copyWith(sets: renumbered);
          }
          return e;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // ─── Rest Timer ───

  void startRest(int seconds) {
    _restTimer?.cancel();
    state = state.copyWith(
      isResting: true,
      restSecondsRemaining: seconds,
      restSecondsTotal: seconds,
    );

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.restSecondsRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        state = state.copyWith(
          isResting: false,
          restSecondsRemaining: 0,
        );
      } else {
        state = state.copyWith(restSecondsRemaining: remaining);
      }
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    state = state.copyWith(
      isResting: false,
      restSecondsRemaining: 0,
    );
  }

  // ─── Complete / Cancel ───

  Future<Workout?> completeWorkout({String? notes}) async {
    if (state.workout == null) return null;
    state = state.copyWith(isCompleting: true);
    try {
      final completedWorkout = await _repository.completeWorkout(
        state.workout!.id,
        notes: notes,
      );
      _cleanup();
      state = const ActiveWorkoutState();
      return completedWorkout;
    } catch (e) {
      state = state.copyWith(
        isCompleting: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<void> cancelWorkout() async {
    if (state.workout == null) return;
    try {
      await _repository.cancelWorkout(state.workout!.id);
      _cleanup();
      state = const ActiveWorkoutState();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // ─── Internal ───

  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _cleanup() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _workoutTimer = null;
    _restTimer = null;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
