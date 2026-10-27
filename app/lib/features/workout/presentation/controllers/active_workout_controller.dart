import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/exercise.dart';
import '../../domain/workout.dart';
import '../../domain/workout_exercise.dart';
import '../../domain/workout_set.dart';
import '../../domain/workout_repository.dart';
import '../../domain/workout_templates.dart';
import '../providers/exercise_providers.dart';
import 'workout_history_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../progression/domain/progression_engine.dart';
import '../../../quests/domain/quest_instance.dart';
import '../../../quests/presentation/providers/quest_providers.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../dashboard/presentation/providers/class_providers.dart';

part 'active_workout_controller.freezed.dart';

@freezed
abstract class ActiveWorkoutState with _$ActiveWorkoutState {
  const factory ActiveWorkoutState({
    Workout? workout,
    @Default([]) List<WorkoutExercise> exercises,
    @Default(0) int elapsedSeconds,
    @Default(true) bool isSetupPhase,
    @Default(false) bool isResting,
    @Default(0) int restSecondsRemaining,
    @Default(0) int restSecondsTotal,
    @Default(false) bool isRestPaused,
    DateTime? restTargetEndTime,
    @Default(false) bool isLoading,
    @Default(false) bool isCompleting,
    @Default(false) bool isTimerPaused,
    @Default(0) int previewXP,
    String? errorMessage,
  }) = _ActiveWorkoutState;

  const ActiveWorkoutState._();

  bool get hasActiveWorkout => workout?.status == WorkoutStatus.active;
  String get formattedElapsed => formatDuration(elapsedSeconds);
  String get formattedRest => formatDuration(restSecondsRemaining);
  static String formatDuration(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  double get restProgress => restSecondsTotal <= 0
      ? 0
      : (1 - restSecondsRemaining / restSecondsTotal).clamp(0, 1);
  int get restRemaining => restSecondsRemaining;
  int get restTotal => restSecondsTotal;
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);
  int get completedSets => exercises.fold(
    0,
    (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length,
  );
  double get totalVolumeKg => exercises.fold(
    0.0,
    (sum, ex) =>
        sum +
        ex.sets
            .where((s) => s.isCompleted)
            .fold(0.0, (sSum, s) => sSum + (s.weightKg * s.reps)),
  );
}

class ActiveWorkoutController extends Notifier<ActiveWorkoutState> {
  static const String backupKey = 'gymlvl_active_workout_backup';

  Timer? _workoutTimer;
  Timer? _restTimer;
  Future<void> _pending = Future.value();
  Future<Map<String, dynamic>?>? _completion;
  int _generation = 0;
  bool _mutationFailed = false;

  WorkoutRepository get _repository => ref.read(workoutRepositoryProvider);

  @override
  ActiveWorkoutState build() {
    ref.watch(
      authStateStreamProvider.select((value) => value.value?.session?.user.id),
    );
    _generation++;
    _cleanup();
    _pending = Future.value();
    _completion = null;
    _mutationFailed = false;
    ref.onDispose(_cleanup);
    return const ActiveWorkoutState();
  }

  static int elapsedFor(Workout workout, DateTime now) {
    final start = workout.trainingStartedAt;
    if (start == null) return 0;
    final end = workout.completedAt ?? workout.pausedAt ?? now;
    return math.max(
      0,
      end.toUtc().difference(start.toUtc()).inSeconds - workout.pausedSeconds,
    );
  }

  bool _isCurrent(int generation) => ref.mounted && generation == _generation;

  void _adopt(Workout workout, int generation) {
    if (!_isCurrent(generation)) return;
    state = state.copyWith(
      workout: workout,
      exercises: workout.exercises,
      isSetupPhase: workout.trainingStartedAt == null,
      isTimerPaused: workout.pausedAt != null,
      elapsedSeconds: elapsedFor(workout, DateTime.now().toUtc()),
      errorMessage: null,
    );
    _updatePreviewXP();
    _startWorkoutTimer();
    _saveLocalBackup();
  }

  // All writes retain user order, including a final completion after pending set edits.
  Future<void> _enqueue(Future<void> Function(int generation) action) {
    if (state.isCompleting) return Future.value();
    final generation = _generation;
    final next = _pending.then((_) async {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(isLoading: true, errorMessage: null);
      try {
        await action(generation);
      } catch (_) {
        if (ref.mounted && generation == _generation) {
          _mutationFailed = true;
          state = state.copyWith(errorMessage: 'save_failed');
        }
      } finally {
        if (ref.mounted && generation == _generation) {
          state = state.copyWith(isLoading: false);
        }
      }
    });
    _pending = next;
    return next;
  }

  // --- LOCAL INTERRUPTION RECOVERY (shared_preferences) ---

  Future<void> _saveLocalBackup() async {
    final workout = state.workout;
    if (workout == null || !state.hasActiveWorkout) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshot = <String, dynamic>{
        'workout': workout.copyWith(exercises: state.exercises).toJson(),
        'local_updated_at': DateTime.now().toUtc().toIso8601String(),
        'elapsed_seconds': state.elapsedSeconds,
      };
      await prefs.setString(backupKey, jsonEncode(snapshot));
    } catch (_) {
      // Local backup failure should not crash interactive workout
    }
  }

  Future<void> _clearLocalBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(backupKey);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> checkLocalBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(backupKey);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> restoreFromLocalBackup() => _enqueue((generation) async {
    try {
      final backup = await checkLocalBackup();
      if (backup == null) return;
      final workoutMap = backup['workout'] as Map<String, dynamic>?;
      if (workoutMap == null) return;
      final workout = Workout.fromJson(workoutMap);
      _mutationFailed = false;
      _adopt(workout, generation);

      // Verify and synchronize with remote active workout if available
      try {
        final remote = await _repository.getWorkoutDetail(workout.id);
        if (remote != null && _isCurrent(generation)) {
          // If remote is newer, adopt remote; otherwise keep local edits and save
          _adopt(remote, generation);
        }
      } catch (_) {}
    } catch (_) {
      state = state.copyWith(errorMessage: 'restore_failed');
    }
  });

  Future<void> discardLocalBackup() => _enqueue((generation) async {
    await _clearLocalBackup();
    if (state.hasActiveWorkout) {
      await cancelWorkout();
    } else {
      _cleanup();
      state = const ActiveWorkoutState();
    }
  });

  Future<void> checkForActiveWorkout() => _enqueue((generation) async {
    // 1. Check local backup first for instant offline resume
    final backup = await checkLocalBackup();
    if (backup != null && !state.hasActiveWorkout) {
      final workoutMap = backup['workout'] as Map<String, dynamic>?;
      if (workoutMap != null) {
        try {
          final localWorkout = Workout.fromJson(workoutMap);
          _mutationFailed = false;
          _adopt(localWorkout, generation);
        } catch (_) {}
      }
    }

    // 2. Fetch server active workout
    try {
      final workout = await _repository.getActiveWorkout();
      if (!_isCurrent(generation)) return;
      _mutationFailed = false;
      if (workout != null) {
        _adopt(workout, generation);
      } else if (backup == null) {
        _cleanup();
        state = const ActiveWorkoutState();
      }
    } catch (_) {
      // If server unreachable but local backup exists, remain on local state
      if (backup == null && _isCurrent(generation)) {
        _cleanup();
        state = const ActiveWorkoutState();
      }
    }
  });

  Future<void> startWorkout() => _enqueue((generation) async {
    if (state.hasActiveWorkout) return;
    final workout = await _repository.startWorkout();
    if (!_isCurrent(generation)) return;
    _mutationFailed = false;
    _adopt(workout, generation);
  });

  Future<void> beginTraining() => _enqueue((generation) async {
    if (!state.hasActiveWorkout || state.exercises.isEmpty) return;
    _adopt(await _repository.beginWorkout(state.workout!.id), generation);
  });

  Future<void> _reload() async {
    final generation = _generation;
    final workout = await _repository.getWorkoutDetail(state.workout!.id);
    if (workout != null) _adopt(workout, generation);
  }

  Future<void> _addExercise(
    Exercise exercise, {
    PrescribedExercise? prescription,
  }) async {
    final generation = _generation;
    if (!state.hasActiveWorkout ||
        state.exercises.any((e) => e.exerciseId == exercise.id)) {
      return;
    }
    final order =
        state.exercises.fold<int>(-1, (v, e) => math.max(v, e.orderIndex)) + 1;
    final item = await _repository.addExerciseToWorkout(
      state.workout!.id,
      exercise.id,
      order,
    );
    if (!_isCurrent(generation)) return;
    try {
      // Existing logged loads are suggestions only. No load is invented for a new exercise.
      final previous = await _repository.getLastSetForExercise(exercise.id);
      if (!_isCurrent(generation)) return;
      final bodyweight = exercise.equipment.toLowerCase().contains('body');
      final weight = bodyweight
          ? 0.0
          : (prescription?.weightKg ?? previous?.weightKg ?? 0.0).clamp(
              0.0,
              1000.0,
            );
      final isTimed =
          exercise.forceType?.toLowerCase() == 'static' ||
          exercise.movementPattern == 'carry' ||
          exercise.category.toLowerCase() == 'cardio' ||
          (exercise.slug?.contains('plank') ?? false);
      final sets = <WorkoutSet>[];
      final count = prescription?.sets ?? 3;
      final defaultReps = isTimed
          ? 0
          : (prescription?.reps ?? previous?.reps ?? 10);
      final defaultDuration = isTimed ? 30 : 0;

      for (var i = 1; i <= count; i++) {
        sets.add(
          await _repository.addSet(
            item.id,
            i,
            defaultReps,
            weight,
            durationSeconds: defaultDuration,
          ),
        );
        if (!_isCurrent(generation)) return;
      }
      state = state.copyWith(
        exercises: [
          ...state.exercises,
          item.copyWith(exercise: exercise, sets: sets),
        ],
      );
      _updatePreviewXP();
      _saveLocalBackup();
    } catch (_) {
      if (!_isCurrent(generation)) return;
      // Do not leave a half-created exercise hidden from the screen.
      try {
        await _repository.removeExerciseFromWorkout(item.id);
      } catch (_) {}
      await _reload();
      rethrow;
    }
  }

  Future<void> addExercise(Exercise exercise) =>
      _enqueue((_) => _addExercise(exercise));

  Future<void> addExercises(List<Exercise> exercises) =>
      _enqueue((generation) async {
        for (final exercise in exercises) {
          await _addExercise(exercise);
          if (!_isCurrent(generation)) return;
        }
      });

  Future<bool> startQuest(QuestInstance quest) async {
    final generation = _generation;
    await startWorkout();
    if (!_isCurrent(generation)) return false;
    if (!state.hasActiveWorkout) return false;
    if (!state.isSetupPhase) {
      state = state.copyWith(errorMessage: 'active_session_exists');
      return false;
    }
    await _enqueue((generation) async {
      final catalog = await ref.read(exerciseRepositoryProvider).getExercises();
      if (!_isCurrent(generation)) return;
      for (final target in quest.config) {
        final matches = catalog.where(
          (exercise) => exercise.id == target.exerciseId,
        );
        if (matches.isEmpty) throw StateError('exercise_unavailable');
        await _addExercise(matches.first, prescription: target);
        if (!_isCurrent(generation)) return;
      }
    });
    return _isCurrent(generation) && state.errorMessage == null;
  }

  Future<void> loadPresetExercises(List<String> categories) => _enqueue((
    generation,
  ) async {
    if (!state.hasActiveWorkout || !state.isSetupPhase) return;
    final catalog = await ref.read(exerciseRepositoryProvider).getExercises();
    if (!_isCurrent(generation)) return;
    final names = WorkoutTemplates.getExercisesForCategories(categories);
    // Category selection adds presets. Removing a selection never deletes logged user work.
    for (final name in names) {
      final matches = catalog.where((exercise) => exercise.name == name);
      if (matches.isEmpty) continue;
      await _addExercise(matches.first);
      if (!_isCurrent(generation)) return;
    }
    if (names.isNotEmpty &&
        !catalog.any((exercise) => names.contains(exercise.name))) {
      state = state.copyWith(errorMessage: 'exercise_unavailable');
    }
  });

  // --- REORDER EXERCISES ---

  Future<void> reorderExercises(int oldIndex, int newIndex) =>
      _enqueue((generation) async {
        if (!state.hasActiveWorkout || state.exercises.isEmpty) return;
        if (oldIndex < 0 || oldIndex >= state.exercises.length) return;
        if (newIndex < 0 || newIndex > state.exercises.length) return;

        var targetIndex = newIndex;
        if (oldIndex < targetIndex) {
          targetIndex -= 1;
        }
        if (oldIndex == targetIndex) return;

        final updated = List<WorkoutExercise>.from(state.exercises);
        final moved = updated.removeAt(oldIndex);
        updated.insert(targetIndex, moved);

        final reordered = <WorkoutExercise>[];
        for (var i = 0; i < updated.length; i++) {
          reordered.add(updated[i].copyWith(orderIndex: i));
        }

        state = state.copyWith(exercises: reordered);
        _saveLocalBackup();

        final ids = reordered.map((e) => e.id).toList();
        await _repository.reorderExercises(state.workout!.id, ids);
      });

  Future<void> removeExercise(String id) => _enqueue((generation) async {
    await _repository.removeExerciseFromWorkout(id);
    if (!_isCurrent(generation)) return;
    state = state.copyWith(
      exercises: state.exercises.where((e) => e.id != id).toList(),
    );
    _updatePreviewXP();
    _saveLocalBackup();
  });

  Future<void> addSet(
    String id, {
    int reps = 10,
    double weightKg = 0,
    int durationSeconds = 0,
  }) => _enqueue((generation) async {
    final exercise = state.exercises.firstWhere((e) => e.id == id);
    final number =
        exercise.sets.fold<int>(0, (v, s) => math.max(v, s.setNumber)) + 1;
    final set = await _repository.addSet(
      id,
      number,
      reps,
      weightKg,
      durationSeconds: durationSeconds,
    );
    if (!_isCurrent(generation)) return;
    state = state.copyWith(
      exercises: state.exercises
          .map((e) => e.id == id ? e.copyWith(sets: [...e.sets, set]) : e)
          .toList(),
    );
    _saveLocalBackup();
  });

  Future<void> updateSet(
    String exerciseId,
    String setId, {
    int? reps,
    double? weightKg,
    int? durationSeconds,
    bool? isCompleted,
  }) => _enqueue((generation) async {
    final currentExercise = state.exercises.firstWhere(
      (e) => e.id == exerciseId,
    );
    final current = currentExercise.sets.firstWhere((s) => s.id == setId);

    final newReps = reps ?? current.reps;
    final newDuration = durationSeconds ?? current.durationSeconds;
    final newIsCompleted = isCompleted ?? current.isCompleted;

    if (newIsCompleted && newReps <= 0 && newDuration <= 0) {
      state = state.copyWith(errorMessage: 'reps_required');
      return;
    }

    final updated = await _repository.updateSet(
      setId,
      reps: reps,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
      isCompleted: isCompleted,
    );
    if (!_isCurrent(generation)) return;

    state = state.copyWith(
      exercises: state.exercises
          .map(
            (e) => e.id == exerciseId
                ? e.copyWith(
                    sets: e.sets
                        .map((s) => s.id == setId ? updated : s)
                        .toList(),
                  )
                : e,
          )
          .toList(),
    );
    _updatePreviewXP();
    _saveLocalBackup();

    // Auto-start rest timer on completing a set
    if (isCompleted == true && !current.isCompleted) {
      final restSec = current.restSeconds > 0 ? current.restSeconds : 60;
      startRest(restSec);
    }
  });

  Future<void> deleteSet(String exerciseId, String setId) => _enqueue((
    generation,
  ) async {
    await _repository.deleteSet(setId);
    if (!_isCurrent(generation)) return;
    state = state.copyWith(
      exercises: state.exercises
          .map(
            (e) => e.id == exerciseId
                ? e.copyWith(sets: e.sets.where((s) => s.id != setId).toList())
                : e,
          )
          .toList(),
    );
    _updatePreviewXP();
    _saveLocalBackup();
  });

  // --- RE-ARCHITECTED REST TIMER (1-second interval, pause/resume, +30s/-15s, background accurate) ---

  void startRest(int seconds) {
    if (seconds <= 0 || seconds > 7200) return;
    _restTimer?.cancel();
    final targetEndTime = DateTime.now().add(Duration(seconds: seconds));
    state = state.copyWith(
      isResting: true,
      isRestPaused: false,
      restSecondsRemaining: seconds,
      restSecondsTotal: seconds,
      restTargetEndTime: targetEndTime,
    );

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRestPaused) return;

      final now = DateTime.now();
      final target = state.restTargetEndTime;
      final remaining = target != null
          ? math.max(0, target.difference(now).inSeconds)
          : math.max(0, state.restSecondsRemaining - 1);

      if (remaining <= 0) {
        timer.cancel();
        _restTimer = null;
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        state = state.copyWith(
          isResting: false,
          isRestPaused: false,
          restSecondsRemaining: 0,
          restTargetEndTime: null,
        );
      } else {
        state = state.copyWith(restSecondsRemaining: remaining);
      }
    });
  }

  void pauseRest() {
    if (!state.isResting || state.isRestPaused) return;
    state = state.copyWith(isRestPaused: true);
  }

  void resumeRest() {
    if (!state.isResting || !state.isRestPaused) return;
    final newTarget = DateTime.now().add(
      Duration(seconds: state.restSecondsRemaining),
    );
    state = state.copyWith(isRestPaused: false, restTargetEndTime: newTarget);
  }

  void resetRest() {
    if (!state.isResting) return;
    final total = state.restSecondsTotal > 0 ? state.restSecondsTotal : 60;
    startRest(total);
  }

  void adjustRest(int deltaSeconds) {
    if (!state.isResting) return;
    final current = state.restSecondsRemaining;
    final updated = math.max(1, current + deltaSeconds);
    final newTarget = DateTime.now().add(Duration(seconds: updated));
    final newTotal = math.max(state.restSecondsTotal, updated);
    state = state.copyWith(
      restSecondsRemaining: updated,
      restSecondsTotal: newTotal,
      restTargetEndTime: newTarget,
    );
  }

  void addRest30() => adjustRest(30);

  void subtractRest15() => adjustRest(-15);

  void skipRest() {
    _restTimer?.cancel();
    _restTimer = null;
    state = state.copyWith(
      isResting: false,
      isRestPaused: false,
      restSecondsRemaining: 0,
      restTargetEndTime: null,
    );
  }

  // --- WORKOUT COMPLETION & RECOVERY CLEANUP ---

  Future<Map<String, dynamic>?> completeWorkout({String? notes}) {
    if (_completion != null) return _completion!;
    if (_mutationFailed) {
      state = state.copyWith(errorMessage: 'reload_required');
      return Future.value(null);
    }
    final pending = _pending;
    state = state.copyWith(isCompleting: true, errorMessage: null);
    _completion = _finish(pending, notes);
    return _completion!;
  }

  Future<Map<String, dynamic>?> _finish(
    Future<void> pending,
    String? notes,
  ) async {
    final generation = _generation;
    try {
      await pending;
      if (!ref.mounted ||
          generation != _generation ||
          !state.hasActiveWorkout) {
        return null;
      }
      if (_mutationFailed) {
        state = state.copyWith(errorMessage: 'reload_required');
        return null;
      }
      if (state.errorMessage != null) return null;
      if (state.completedSets == 0 || state.isSetupPhase) {
        state = state.copyWith(errorMessage: 'completed_set_required');
        return null;
      }
      final result = await _repository.finishWorkout(
        state.workout!.id,
        notes: notes,
      );
      if (!ref.mounted || generation != _generation) return null;

      // Clean up local interruption backup upon genuine completion
      await _clearLocalBackup();
      _cleanup();
      final finishedWorkout = state.workout!.copyWith(
        exercises: state.exercises,
        durationSeconds: state.elapsedSeconds,
        completedAt: DateTime.now().toUtc(),
        status: WorkoutStatus.completed,
      );
      state = const ActiveWorkoutState();
      _invalidateProgress();
      return {
        'workout': result.workout,
        'xpResult': result.rewards,
        'exercises': finishedWorkout.exercises,
        'durationSeconds': finishedWorkout.durationSeconds,
      };
    } catch (_) {
      if (ref.mounted && generation == _generation) {
        state = state.copyWith(errorMessage: 'completion_failed');
      }
      return null;
    } finally {
      if (ref.mounted && generation == _generation) {
        state = state.copyWith(isCompleting: false);
        _completion = null;
      }
    }
  }

  Future<void> cancelWorkout() => _enqueue((generation) async {
    if (!state.hasActiveWorkout) return;
    await _repository.cancelWorkout(state.workout!.id);
    if (!_isCurrent(generation)) return;
    _mutationFailed = false;
    await _clearLocalBackup();
    _cleanup();
    state = const ActiveWorkoutState();
    _invalidateProgress();
  });

  Future<void> pauseTimer() => _setPaused(true);
  Future<void> resumeTimer() => _setPaused(false);
  Future<void> _setPaused(bool paused) => _enqueue((generation) async {
    if (!state.hasActiveWorkout || state.isSetupPhase) return;
    _adopt(
      await _repository.setWorkoutPaused(state.workout!.id, paused),
      generation,
    );
  });

  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    if (!state.hasActiveWorkout || state.isSetupPhase || state.isTimerPaused) {
      return;
    }
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsedSeconds: elapsedFor(state.workout!, DateTime.now().toUtc()),
      );
      _updatePreviewXP();
    });
  }

  void _updatePreviewXP() {
    final trained = state.exercises
        .where((e) => e.sets.any((s) => s.isCompleted))
        .toList();
    final sets = trained
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .toList();
    state = state.copyWith(
      previewXP: ProgressionEngine.calculateXP(
        durationSeconds: state.elapsedSeconds,
        completedSets: sets,
        uniqueCategories: trained
            .map((e) => e.exercise?.category.toLowerCase())
            .whereType<String>()
            .toSet()
            .length,
        isSuspicious: ProgressionEngine.checkSuspiciousPace(
          sets.length,
          state.elapsedSeconds,
        ),
      ),
    );
  }

  void _invalidateProgress() {
    ref.invalidate(currentUserProvider);
    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(workoutHistoryProvider);
    ref.invalidate(recentWorkoutsProvider);
    ref.invalidate(completedWorkoutCountProvider);
    ref.invalidate(dashboardStatsControllerProvider);
    ref.invalidate(activeQuestControllerProvider);
    ref.invalidate(userClassesProvider);
  }

  void _cleanup() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _workoutTimer = null;
    _restTimer = null;
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}
