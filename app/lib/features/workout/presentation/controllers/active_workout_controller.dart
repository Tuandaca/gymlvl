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
import '../../domain/workout_mode_contract.dart';
import '../../domain/workout_repository.dart';
import '../../domain/superset_rounds.dart';
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

/// Provides a clock for deadline-based rest calculations and deterministic tests.
final restClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

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
  Future<void> _backupWrites = Future.value();
  Future<Map<String, dynamic>?>? _completion;
  int _generation = 0;
  bool _mutationFailed = false;
  WorkoutReceipt? _pendingReceipt;
  bool _completionUncertain = false;

  bool get completionNeedsRecovery =>
      _pendingReceipt != null || _completionUncertain;

  WorkoutRepository get _repository => ref.read(workoutRepositoryProvider);
  DateTime get _restNow => ref.read(restClockProvider)().toUtc();

  static int _secondsUntil(DateTime target, DateTime now) {
    final milliseconds = target.difference(now).inMilliseconds;
    return milliseconds <= 0 ? 0 : (milliseconds + 999) ~/ 1000;
  }

  int _currentRestRemaining() {
    final target = state.restTargetEndTime;
    return target == null
        ? state.restSecondsRemaining
        : _secondsUntil(target, _restNow);
  }

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
    _pendingReceipt = null;
    _completionUncertain = false;
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

  void _adopt(
    Workout workout,
    int generation, {
    Map<String, dynamic>? localBackup,
  }) {
    if (!_isCurrent(generation)) return;
    if (state.workout?.id != workout.id ||
        workout.status != WorkoutStatus.active ||
        localBackup != null) {
      _clearRestTimer();
    }
    state = state.copyWith(
      workout: workout,
      exercises: workout.exercises,
      isSetupPhase: workout.trainingStartedAt == null,
      isTimerPaused: workout.pausedAt != null,
      elapsedSeconds: elapsedFor(workout, DateTime.now().toUtc()),
      errorMessage: null,
    );
    if (localBackup != null && workout.status == WorkoutStatus.active) {
      _restoreRestTimer(localBackup, workout.id);
    }
    _updatePreviewXP();
    _startWorkoutTimer();
    _saveLocalBackup();
  }

  // All writes retain user order, including a final completion after pending set edits.
  Future<void> _enqueue(Future<void> Function(int generation) action) {
    if (state.isCompleting || completionNeedsRecovery) return Future.value();
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

  String? get _backupOwner =>
      ref.read(authStateStreamProvider).value?.session?.user.id;

  static String _ownerBackupKey(String owner) =>
      '$backupKey:${Uri.encodeComponent(owner)}';

  bool _isContextCurrent(int generation, String? owner) =>
      _isCurrent(generation) && owner == _backupOwner;

  bool _isBackupContextCurrent(int generation, String? owner) =>
      owner != null && _isContextCurrent(generation, owner);

  static Map<String, dynamic>? _ownedBackup(String? raw, String owner) {
    if (raw == null) return null;
    try {
      final backup = jsonDecode(raw) as Map<String, dynamic>;
      final workout = backup['workout'];
      // Check ownership before interpreting any workout or recovery metadata.
      if (workout is! Map<String, dynamic> || workout['user_id'] != owner) {
        return null;
      }
      final updatedAt = backup['local_updated_at'];
      final elapsed = backup['elapsed_seconds'];
      if (updatedAt is! String ||
          DateTime.tryParse(updatedAt) == null ||
          elapsed is! int ||
          elapsed < 0) {
        return null;
      }
      final parsed = Workout.fromJson(workout);
      return parsed.status == WorkoutStatus.active ? backup : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _restSnapshot(String workoutId) {
    if (!state.isResting || state.restSecondsRemaining <= 0) return null;
    return {
      'workout_id': workoutId,
      'remaining_seconds': state.restSecondsRemaining,
      'total_seconds': state.restSecondsTotal,
      'paused': state.isRestPaused,
      'target_end_at': state.isRestPaused
          ? null
          : state.restTargetEndTime?.toUtc().toIso8601String(),
    };
  }

  void _clearRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    state = state.copyWith(
      isResting: false,
      isRestPaused: false,
      restSecondsRemaining: 0,
      restSecondsTotal: 0,
      restTargetEndTime: null,
    );
  }

  void _restoreRestTimer(Map<String, dynamic> backup, String workoutId) {
    final rest = backup['rest_timer'];
    if (rest is! Map<String, dynamic> || rest['workout_id'] != workoutId) {
      return;
    }
    final remaining = rest['remaining_seconds'];
    final total = rest['total_seconds'];
    final paused = rest['paused'];
    if (remaining is! int ||
        total is! int ||
        paused is! bool ||
        remaining <= 0 ||
        total <= 0 ||
        total > 7200 ||
        remaining > total) {
      return;
    }
    if (paused) {
      state = state.copyWith(
        isResting: true,
        isRestPaused: true,
        restSecondsRemaining: remaining,
        restSecondsTotal: total,
        restTargetEndTime: null,
      );
      return;
    }
    final rawEnd = rest['target_end_at'];
    final end = rawEnd is String ? DateTime.tryParse(rawEnd)?.toUtc() : null;
    if (end == null) return;
    final now = _restNow;
    final maximumEnd = now.add(Duration(seconds: total));
    final restoredEnd = end.isAfter(maximumEnd) ? maximumEnd : end;
    final restoredRemaining = _secondsUntil(restoredEnd, now);
    if (restoredRemaining <= 0) return;
    state = state.copyWith(
      isResting: true,
      isRestPaused: false,
      restSecondsRemaining: restoredRemaining,
      restSecondsTotal: total,
      restTargetEndTime: restoredEnd,
    );
    _startRestTicker();
  }

  Future<void> _saveLocalBackup() async {
    final workout = state.workout;
    final owner = _backupOwner;
    final generation = _generation;
    if (owner == null ||
        workout == null ||
        workout.userId != owner ||
        !state.hasActiveWorkout) {
      return;
    }
    final snapshot = <String, dynamic>{
      'workout': workout.copyWith(exercises: state.exercises).toJson(),
      'local_updated_at': DateTime.now().toUtc().toIso8601String(),
      'elapsed_seconds': state.elapsedSeconds,
      'rest_timer': _restSnapshot(workout.id),
    };
    final write = _backupWrites.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (!_isBackupContextCurrent(generation, owner) ||
            !state.hasActiveWorkout ||
            state.workout?.id != workout.id) {
          return;
        }
        final key = _ownerBackupKey(owner);
        final existing = prefs.getString(key);
        // Preserve unknown/corrupt data even if it occupies an owner-scoped key.
        if (existing != null && _ownedBackup(existing, owner) == null) return;
        // Never overwrite the shared legacy key: it may belong to another account.
        await prefs.setString(key, jsonEncode(snapshot));
      } catch (_) {
        // Local backup failure should not crash interactive workout.
      }
    });
    _backupWrites = write;
    await write;
  }

  Future<void> _clearLocalBackup() async {
    final owner = _backupOwner;
    final generation = _generation;
    if (owner == null) return;
    try {
      await _backupWrites;
      final prefs = await SharedPreferences.getInstance();
      if (!_isBackupContextCurrent(generation, owner)) return;
      for (final key in [_ownerBackupKey(owner), backupKey]) {
        if (!_isBackupContextCurrent(generation, owner)) return;
        if (_ownedBackup(prefs.getString(key), owner) != null) {
          await prefs.remove(key);
        }
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> checkLocalBackup() async {
    final owner = _backupOwner;
    final generation = _generation;
    if (owner == null) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_isBackupContextCurrent(generation, owner)) return null;
      final raw =
          prefs.getString(_ownerBackupKey(owner)) ?? prefs.getString(backupKey);
      return _ownedBackup(raw, owner);
    } catch (_) {
      return null;
    }
  }

  Future<void> restoreFromLocalBackup() => _enqueue((generation) async {
    final owner = _backupOwner;
    if (owner == null) return;
    try {
      final backup = await checkLocalBackup();
      if (!_isBackupContextCurrent(generation, owner) || backup == null) return;
      final workoutMap = backup['workout'] as Map<String, dynamic>?;
      if (workoutMap == null) return;
      final workout = Workout.fromJson(workoutMap);
      _mutationFailed = false;
      _adopt(workout, generation, localBackup: backup);

      // Verify and synchronize with remote active workout if available
      try {
        final remote = await _repository.getWorkoutDetail(workout.id);
        if (remote != null &&
            _isBackupContextCurrent(generation, owner) &&
            remote.userId == owner) {
          if (remote.status == WorkoutStatus.active) {
            // Keep the timer only when the server confirms the same workout.
            _adopt(remote, generation);
          } else {
            _clearRestTimer();
            await _clearLocalBackup();
            if (_isBackupContextCurrent(generation, owner)) {
              _cleanup();
              state = const ActiveWorkoutState();
            }
          }
        } else if (_isBackupContextCurrent(generation, owner)) {
          _clearRestTimer();
          _saveLocalBackup();
        }
      } catch (_) {}
      await _backupWrites;
    } catch (_) {
      if (_isCurrent(generation)) {
        state = state.copyWith(errorMessage: 'restore_failed');
      }
    }
  });

  Future<void> discardLocalBackup() => _enqueue((generation) async {
    final owner = _backupOwner;
    if (state.hasActiveWorkout) {
      // Already inside the write queue: do not enqueue and await ourselves.
      await _cancelWorkout(generation);
    } else {
      await _clearLocalBackup();
      if (!_isContextCurrent(generation, owner)) return;
      _cleanup();
      state = const ActiveWorkoutState();
    }
  });

  Future<void> checkForActiveWorkout() => completionNeedsRecovery
      ? completeWorkout().then((_) {})
      : _enqueue((generation) async {
          final owner = _backupOwner;
          // 1. Check local backup first for instant offline resume
          final backup = await checkLocalBackup();
          if (!_isCurrent(generation) || owner != _backupOwner) return;
          if (backup != null && !state.hasActiveWorkout) {
            final workoutMap = backup['workout'] as Map<String, dynamic>?;
            if (workoutMap != null) {
              try {
                final localWorkout = Workout.fromJson(workoutMap);
                _mutationFailed = false;
                _adopt(localWorkout, generation, localBackup: backup);
              } catch (_) {}
            }
          }

          // 2. Fetch server active workout
          try {
            final workout = await _repository.getActiveWorkout();
            if (!_isCurrent(generation)) return;
            _mutationFailed = false;
            if (workout != null && (owner == null || workout.userId == owner)) {
              if (workout.status == WorkoutStatus.active) {
                _adopt(workout, generation);
              } else {
                _clearRestTimer();
                await _clearLocalBackup();
                if (_isContextCurrent(generation, owner)) {
                  _cleanup();
                  state = const ActiveWorkoutState();
                }
              }
            } else if (backup != null) {
              _clearRestTimer();
              _saveLocalBackup();
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
          await _backupWrites;
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
    WorkoutMode? mode,
  }) async {
    final generation = _generation;
    if (!state.hasActiveWorkout ||
        state.exercises.any((e) => e.exerciseId == exercise.id)) {
      return;
    }
    if (mode != null && !productionWorkoutModesEnabled) {
      state = state.copyWith(errorMessage: 'mode_unavailable');
      return;
    }
    final order =
        state.exercises.fold<int>(-1, (v, e) => math.max(v, e.orderIndex)) + 1;
    final isTimedCatalog =
        exercise.forceType?.toLowerCase() == 'static' ||
        exercise.movementPattern == 'carry' ||
        (exercise.slug?.contains('plank') ?? false);
    final selectedMode =
        mode ??
        (exercise.category.toLowerCase() == 'cardio'
            ? WorkoutMode.cardio
            : isTimedCatalog
            ? WorkoutMode.timed
            : exercise.equipment.toLowerCase().contains('body')
            ? WorkoutMode.bodyweight
            : WorkoutMode.repsWeight);
    final item =
        productionWorkoutModesEnabled &&
            _repository is ModeAwareWorkoutRepository
        ? await (_repository as ModeAwareWorkoutRepository)
              .addExerciseToWorkoutWithMode(
                state.workout!.id,
                exercise.id,
                order,
                selectedMode,
              )
        : await _repository.addExerciseToWorkout(
            state.workout!.id,
            exercise.id,
            order,
          );
    if (!_isCurrent(generation)) return;
    try {
      // Existing logged loads are suggestions only. No load is invented for a new exercise.
      final previous = await _repository.getLastSetForExercise(exercise.id);
      if (!_isCurrent(generation)) return;
      final weight =
          selectedMode == WorkoutMode.bodyweight ||
              selectedMode == WorkoutMode.timed ||
              selectedMode == WorkoutMode.cardio
          ? 0.0
          : (prescription?.weightKg ?? previous?.weightKg ?? 0.0).clamp(
              0.0,
              1000.0,
            );
      final isTimed =
          selectedMode == WorkoutMode.timed ||
          selectedMode == WorkoutMode.cardio;
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

  Future<void> addExercise(Exercise exercise, {WorkoutMode? mode}) =>
      _enqueue((_) => _addExercise(exercise, mode: mode));

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
    if (state.exercises.any((e) => e.id == id && e.supersetGroupId != null)) {
      state = state.copyWith(errorMessage: 'superset_ungroup_before_remove');
      return;
    }
    await _repository.removeExerciseFromWorkout(id);
    if (!_isCurrent(generation)) return;
    state = state.copyWith(
      exercises: state.exercises.where((e) => e.id != id).toList(),
    );
    _updatePreviewXP();
    _saveLocalBackup();
  });

  Future<void> setSupersetLayout(List<SupersetGroupLayout> groups) =>
      _enqueue((generation) async {
        if (!state.hasActiveWorkout) return;
        if (!productionSupersetEnabled) {
          state = state.copyWith(errorMessage: 'superset_unavailable');
          return;
        }
        if (_repository is! SupersetLayoutRepository) {
          throw StateError('superset_unavailable');
        }
        try {
          await (_repository as SupersetLayoutRepository).setSupersetLayout(
            state.workout!.id,
            groups,
          );
        } on SupersetLayoutLocked {
          if (_isCurrent(generation)) {
            state = state.copyWith(errorMessage: 'superset_locked');
          }
          return;
        }
        if (!_isCurrent(generation)) return;
        await _reload();
        _saveLocalBackup();
      });

  Future<void> addSet(
    String id, {
    int? reps,
    double? weightKg,
    int? durationSeconds,
  }) => _enqueue((generation) async {
    final exercise = state.exercises.firstWhere((e) => e.id == id);
    final timed =
        exercise.mode == WorkoutMode.timed ||
        exercise.mode == WorkoutMode.cardio;
    final effectiveReps = reps ?? (timed ? 0 : 10);
    final effectiveWeight = weightKg ?? 0;
    final effectiveDuration = durationSeconds ?? (timed ? 30 : 0);
    validateWorkoutSetForMode(
      mode: exercise.mode,
      reps: effectiveReps,
      weightKg: effectiveWeight,
      durationSeconds: effectiveDuration,
      isCompleted: false,
    );
    final number =
        exercise.sets.fold<int>(0, (v, s) => math.max(v, s.setNumber)) + 1;
    final set = await _repository.addSet(
      id,
      number,
      effectiveReps,
      effectiveWeight,
      durationSeconds: effectiveDuration,
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
    final newWeight = weightKg ?? current.weightKg;
    final newDuration = durationSeconds ?? current.durationSeconds;
    final newIsCompleted = isCompleted ?? current.isCompleted;

    try {
      validateWorkoutSetForMode(
        mode: currentExercise.mode,
        reps: newReps,
        weightKg: newWeight,
        durationSeconds: newDuration,
        isCompleted: newIsCompleted,
      );
    } on ArgumentError {
      state = state.copyWith(errorMessage: 'mode_measurements_invalid');
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
    if (isCompleted == true &&
        !current.isCompleted &&
        shouldStartRestAfterSetCompletion(
          state.exercises,
          exerciseId,
          updated.setNumber,
        )) {
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
    if (state.isCompleting || completionNeedsRecovery) return;
    if (seconds <= 0 || seconds > 7200) return;
    _restTimer?.cancel();
    final targetEndTime = _restNow.add(Duration(seconds: seconds));
    state = state.copyWith(
      isResting: true,
      isRestPaused: false,
      restSecondsRemaining: seconds,
      restSecondsTotal: seconds,
      restTargetEndTime: targetEndTime,
    );

    _startRestTicker();
    _saveLocalBackup();
  }

  void _startRestTicker() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRestPaused) return;

      final remaining = _currentRestRemaining();

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
        _saveLocalBackup();
      } else {
        state = state.copyWith(restSecondsRemaining: remaining);
      }
    });
  }

  void pauseRest() {
    if (state.isCompleting || completionNeedsRecovery) return;
    if (!state.isResting || state.isRestPaused) return;
    final remaining = _currentRestRemaining();
    if (remaining <= 0) {
      _clearRestTimer();
      _saveLocalBackup();
      return;
    }
    _restTimer?.cancel();
    _restTimer = null;
    state = state.copyWith(
      isRestPaused: true,
      restSecondsRemaining: remaining,
      restTargetEndTime: null,
    );
    _saveLocalBackup();
  }

  void resumeRest() {
    if (state.isCompleting || completionNeedsRecovery) return;
    if (!state.isResting || !state.isRestPaused) return;
    final newTarget = _restNow.add(
      Duration(seconds: state.restSecondsRemaining),
    );
    state = state.copyWith(isRestPaused: false, restTargetEndTime: newTarget);
    _startRestTicker();
    _saveLocalBackup();
  }

  void resetRest() {
    if (state.isCompleting || completionNeedsRecovery) return;
    if (!state.isResting) return;
    final total = state.restSecondsTotal > 0 ? state.restSecondsTotal : 60;
    startRest(total);
  }

  void adjustRest(int deltaSeconds) {
    if (state.isCompleting || completionNeedsRecovery) return;
    if (!state.isResting) return;
    final current = state.isRestPaused
        ? state.restSecondsRemaining
        : _currentRestRemaining();
    if (current <= 0) {
      _clearRestTimer();
      _saveLocalBackup();
      return;
    }
    final updated = math.min(7200, math.max(1, current + deltaSeconds));
    final newTarget = state.isRestPaused
        ? null
        : _restNow.add(Duration(seconds: updated));
    final newTotal = math.max(state.restSecondsTotal, updated);
    state = state.copyWith(
      restSecondsRemaining: updated,
      restSecondsTotal: newTotal,
      restTargetEndTime: newTarget,
    );
    _saveLocalBackup();
  }

  void addRest30() => adjustRest(30);

  void subtractRest15() => adjustRest(-15);

  void skipRest() {
    if (state.isCompleting || completionNeedsRecovery) return;
    _clearRestTimer();
    _saveLocalBackup();
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
    final owner = _backupOwner;
    try {
      await pending;
      if (!_isContextCurrent(generation, owner) || !state.hasActiveWorkout) {
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
      final requested = state.workout!;
      final receipt = _pendingReceipt;
      final result = receipt == null
          ? await _repository.finishWorkout(requested.id, notes: notes)
          : await _repository.reconcileCompletion(receipt);
      if (!_isContextCurrent(generation, owner)) return null;
      if (result.workout.id != requested.id ||
          result.workout.userId != requested.userId ||
          result.workout.status != WorkoutStatus.completed ||
          result.workout.completedAt == null) {
        throw const WorkoutCompletionUncertain();
      }

      // Clean up local interruption backup upon genuine completion
      _restTimer?.cancel();
      await _clearLocalBackup();
      if (!_isContextCurrent(generation, owner)) return null;
      _cleanup();
      final exercises = result.workout.exercises.isNotEmpty
          ? result.workout.exercises
          : state.exercises;
      _pendingReceipt = null;
      _completionUncertain = false;
      state = const ActiveWorkoutState();
      _invalidateProgress();
      return {
        'workout': result.workout,
        'xpResult': result.rewards,
        'exercises': exercises,
        'durationSeconds': result.workout.durationSeconds,
      };
    } on WorkoutReconciliationRequired catch (error) {
      if (_isContextCurrent(generation, owner) &&
          error.receipt.workoutId == state.workout?.id &&
          error.receipt.userId == state.workout?.userId) {
        _pendingReceipt = error.receipt;
        _completionUncertain = false;
        _cleanup();
        state = state.copyWith(errorMessage: 'completion_pending');
      }
      return null;
    } on WorkoutCompletionUncertain {
      if (_isContextCurrent(generation, owner)) {
        _completionUncertain = true;
        _cleanup();
        state = state.copyWith(errorMessage: 'completion_uncertain');
      }
      return null;
    } on WorkoutCompletionRejected {
      if (_isContextCurrent(generation, owner)) {
        _completionUncertain = false;
        state = state.copyWith(errorMessage: 'completion_rejected');
      }
      return null;
    } catch (_) {
      if (_isContextCurrent(generation, owner)) {
        state = state.copyWith(errorMessage: 'completion_failed');
      }
      return null;
    } finally {
      if (_isContextCurrent(generation, owner)) {
        state = state.copyWith(isCompleting: false);
        _completion = null;
      }
    }
  }

  Future<void> cancelWorkout() => _enqueue(_cancelWorkout);

  Future<void> _cancelWorkout(int generation) async {
    final owner = _backupOwner;
    if (!state.hasActiveWorkout) return;
    await _repository.cancelWorkout(state.workout!.id);
    if (!_isContextCurrent(generation, owner)) return;
    _mutationFailed = false;
    _restTimer?.cancel();
    await _clearLocalBackup();
    if (!_isContextCurrent(generation, owner)) return;
    _cleanup();
    state = const ActiveWorkoutState();
    _invalidateProgress();
  }

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

  void clearError() {
    if (completionNeedsRecovery) return;
    state = state.copyWith(errorMessage: null);
  }
}
