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
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../progression/domain/progression_engine.dart';

part 'active_workout_controller.freezed.dart';

// ─── Active Workout State ───

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
    @Default(false) bool isLoading,
    @Default(false) bool isCompleting,
    @Default(false) bool isTimerPaused,
    @Default(0) int previewXP,
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
          isSetupPhase: false, // Auto-resume always jumps to training phase
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
        isSetupPhase: true, // Start in setup phase
        isLoading: false,
      );
      // Timer is not started here anymore
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Thêm bài tập vào workout kèm 4 set (Dynamic Progressive Overload)
  Future<void> addExercise(Exercise exercise) async {
    if (state.workout == null) return;
    try {
      final workoutExercise = await _repository.addExerciseToWorkout(
        state.workout!.id,
        exercise.id,
        state.exercises.length,
      );

      // Thêm import thư viện trong não: ref.read(auth_providers)
      // Tìm xem user có tạ trong quá khứ không
      final lastSet = await _repository.getLastSetForExercise(exercise.id);
      double baseWeight = 0.0;

      if (lastSet != null && lastSet.weightKg > 0) {
        // Dùng tạ lịch sử của user (tính cho bài tập nặng nhất / set chính)
        baseWeight = lastSet.weightKg;
      } else {
        // Nếu không có lịch sử, tính Heuristic Baseline từ Profile
        // Lấy profile từ Riverpod FutureProvider, nhưng do đang trong process đồng bộ,
        // nếu provider chưa có sẽ mặc định trị số chuẩn.
        try {
          final profileLoader = ref.read(currentUserProfileProvider.future);
          final userLoader = ref.read(currentUserProvider.future);
          final profile = await profileLoader;
          final user = await userLoader;
          
          final weight = (profile?['weight_kg'] as num?)?.toDouble() ?? 60.0;
          final exp = profile?['experience_level'] as String? ?? 'beginner';
          final lvl = (user?['level'] as int?) ?? 1;

          double multiplier = 0.1;
          if (exp == 'intermediate') {
            multiplier = 0.2;
          } else if (exp == 'advanced') {
            multiplier = 0.35;
          }

          // Cân nặng * Hệ số kinh nghiệm + (Level * 0.5kg)
          baseWeight = weight * multiplier + (lvl * 0.5);

          // Làm tròn đến 2.5kg gần nhất (ví dụ bánh tạ chuẩn phòng gym)
          baseWeight = (baseWeight / 2.5).round() * 2.5;
          if (baseWeight < 5.0) baseWeight = 5.0; // Tối thiểu 5kg
        } catch (_) {
          baseWeight = 20.0; // Fallback an toàn nếu lỗi kết nối
        }
      }

      // Tự động tạo 4 set chuẩn gym với progressive payload 
      // Dựa trên mức baseWeight (tạ nặng nhất mà user hướng tới ở set 3)
      final w1 = ((baseWeight * 0.5) / 2.5).round() * 2.5; // Set 1: 50%
      final w2 = ((baseWeight * 0.7) / 2.5).round() * 2.5; // Set 2: 70%
      final w3 = baseWeight;                               // Set 3: 100%
      final w4 = baseWeight + 2.5;                         // Set 4: 100% + push

      final defaultSetsParams = [
        {'set': 1, 'reps': 12, 'weight': w1 < 5.0 ? 5.0 : w1},
        {'set': 2, 'reps': 12, 'weight': w2 < 5.0 ? 5.0 : w2},
        {'set': 3, 'reps': 10, 'weight': w3},
        {'set': 4, 'reps': 8, 'weight': w4},
      ];

      final createdSets = <WorkoutSet>[];
      for (final param in defaultSetsParams) {
        final newSet = await _repository.addSet(
          workoutExercise.id,
          param['set'] as int,
          param['reps'] as int,
          param['weight'] as double,
          baselineWeightKg: param['weight'] as double,
        );
        createdSets.add(newSet);
      }

      final populatedWorkoutExercise = workoutExercise.copyWith(sets: createdSets);

      state = state.copyWith(
        exercises: [...state.exercises, populatedWorkoutExercise],
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

  /// Chuyển từ Setup Phase sang Training Phase
  Future<void> beginTraining() async {
    if (state.workout == null || state.exercises.isEmpty) return;

    state = state.copyWith(
      isSetupPhase: false,
      elapsedSeconds: 0,
    );
    _startWorkoutTimer();
  }

  /// Tải các bài tập mặc định cho các nhóm cơ đã chọn (Có thêm và xóa tự động)
  Future<void> loadPresetExercises(List<String> categories) async {
    if (state.workout == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final allExercisesInDB = await ref.read(exerciseRepositoryProvider).getExercises();
      
      // 1. Xác định danh sách bài tập cần phải có dựa trên categories
      final Map<String, List<String>> presetDict = {
        'Chest': ['Bench Press (Barbell)', 'Incline Bench Press (Dumbbell)', 'Chest Fly (Machine)', 'Push-up'],
        'Back': ['Deadlift (Barbell)', 'Pull-up', 'Lat Pulldown (Cable)', 'Seated Cable Row'],
        'Legs': ['Squat (Barbell)', 'Leg Press', 'Leg Extension', 'Lying Leg Curl'],
        'Shoulders': ['Overhead Press (Barbell)', 'Lateral Raise (Dumbbell)', 'Face Pull (Cable)'],
        'Arms': ['Bicep Curl (Barbell)', 'Hammer Curl (Dumbbell)', 'Tricep Pushdown (Cable)', 'Skull Crusher (Barbell)'],
        'Core': ['Plank', 'Crunch', 'Leg Raise'],
      };

      final List<String> targetExerciseNames = [];
      for (final cat in categories) {
        if (presetDict.containsKey(cat)) {
          targetExerciseNames.addAll(presetDict[cat]!);
        }
      }

      // 2. Xóa các bài tập có category KHÔNG nằm trong danh sách categories được chọn
      // Chỉ tự động xóa nếu bài tập đó thuộc 1 trong các category chính (để tránh xóa nhầm bài custom lẻ)
      final List<WorkoutExercise> remainingExercises = [];
      final List<String> idsToRemove = [];

      for (final we in state.exercises) {
        final category = we.exercise?.category;
        // Nếu category bài tập hiện tại không còn trong danh sách chọn, và nó thuộc 6 nhóm cơ chính
        if (category != null && 
            presetDict.containsKey(category) && 
            !categories.contains(category)) {
          idsToRemove.add(we.id);
        } else {
          remainingExercises.add(we);
        }
      }

      // Thực thi xóa trên DB
      for (final id in idsToRemove) {
        await _repository.removeExerciseFromWorkout(id);
      }

      // 3. Thêm các bài tập thiếu
      final List<WorkoutExercise> updatedExercises = [...remainingExercises];
      
      for (final templateName in targetExerciseNames) {
        final exercise = allExercisesInDB.firstWhere(
          (e) => e.name == templateName,
          orElse: () => allExercisesInDB.first,
        );
        
        final exists = updatedExercises.any((we) => we.exercise?.id == exercise.id);
        if (!exists) {
          // Add to DB and Get populated exercise
          final workoutExercise = await _repository.addExerciseToWorkout(
            state.workout!.id,
            exercise.id,
            updatedExercises.length,
          );

          // Tự động tạo sets (Helper logic copy từ addExercise)
          final lastSet = await _repository.getLastSetForExercise(exercise.id);
          double baseWeight = 20.0; 
          if (lastSet != null && lastSet.weightKg > 0) baseWeight = lastSet.weightKg;

          final w1 = ((baseWeight * 0.5) / 2.5).round() * 2.5; 
          final w2 = ((baseWeight * 0.7) / 2.5).round() * 2.5;
          
          final defaultParams = [
            {'set': 1, 'reps': 12, 'weight': w1 < 5.0 ? 5.0 : w1},
            {'set': 2, 'reps': 12, 'weight': w2 < 5.0 ? 5.0 : w2},
            {'set': 3, 'reps': 10, 'weight': baseWeight},
            {'set': 4, 'reps': 8, 'weight': baseWeight + 2.5},
          ];

          final createdSets = <WorkoutSet>[];
          for (final param in defaultParams) {
            final newSet = await _repository.addSet(
              workoutExercise.id,
              param['set'] as int,
              param['reps'] as int,
              param['weight'] as double,
            );
            createdSets.add(newSet);
          }
          
          updatedExercises.add(workoutExercise.copyWith(sets: createdSets));
        }
      }
      
      state = state.copyWith(exercises: updatedExercises, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
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
      _updatePreviewXP();
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
      _updatePreviewXP();
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

  Future<Map<String, dynamic>?> completeWorkout({String? notes}) async {
    if (state.workout == null) return null;
    state = state.copyWith(isCompleting: true);
    try {
      final completedWorkout = await _repository.completeWorkout(
        state.workout!.id,
        notes: notes,
      );

      Map<String, dynamic>? xpResult;
      try {
        xpResult = await _repository.calculateXP(completedWorkout.id);
      } catch (e) {
        // Vẫn dọn dẹp và reset state dù lỗi tính XP xảy ra 
        // để user không bị kẹt ở màn hình Training
        _cleanup();
        state = const ActiveWorkoutState();
        
        // Refresh để Dashboard fetch lại dữ liệu mới nhất (dù XP có thể chưa cộng)
        await Future.delayed(const Duration(milliseconds: 500));
        ref.refresh(currentUserProvider);
        ref.refresh(currentUserProfileProvider);

        return {
          'workout': completedWorkout,
          'xpResult': null,
          'error': 'Lỗi tính XP: $e',
        };
      }

      _cleanup();
      state = const ActiveWorkoutState();
      
      // Delay nhỏ để đảm bảo DB commit trước khi fetch lại
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh Auth Providers để cập nhật level & total_xp
      // ignore: unused_result
      ref.refresh(currentUserProvider);
      // ignore: unused_result
      ref.refresh(currentUserProfileProvider);

      return {
        'workout': completedWorkout,
        'xpResult': xpResult,
      };
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
    
    // Lưu lại thời điểm bắt đầu/resume để tính toán chính xác dù bị OS throttle
    final lastStartedAt = DateTime.now();
    final initialElapsed = state.elapsedSeconds;

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Chỉ tính toán nếu không ở trạng thái pause
      if (!state.isTimerPaused) {
        final now = DateTime.now();
        final actualElapsed = initialElapsed + now.difference(lastStartedAt).inSeconds;
        
        state = state.copyWith(elapsedSeconds: actualElapsed);
        // XP preview không phụ thuộc vào thời gian nữa
        // Chỉ cập nhật khi user hoàn thành/sửa/xóa set (trong updateSet, deleteSet)
      }
    });
  }

  void pauseTimer() {
    state = state.copyWith(isTimerPaused: true);
  }

  void resumeTimer() {
    state = state.copyWith(isTimerPaused: false);
    // Nếu timer chưa chạy (ví dụ sau khi restore từ background) thì start lại
    if (_workoutTimer == null || !_workoutTimer!.isActive) {
      _startWorkoutTimer();
    }
  }

  void _updatePreviewXP() {
    final allCompletedSets = state.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .toList();

    final categories = state.exercises
        .map((e) => e.exercise?.category)
        .where((c) => c != null)
        .toSet();

    // Link với Phase 2.6 Streak System sau này
    const userStreak = 0.0;

    final isSuspicious = ProgressionEngine.checkSuspiciousPace(
      allCompletedSets.length,
      state.elapsedSeconds,
    );

    final xp = ProgressionEngine.calculateXP(
      durationSeconds: state.elapsedSeconds,
      completedSets: allCompletedSets,
      uniqueCategories: categories.length,
      userStreak: userStreak,
      isSuspicious: isSuspicious,
    );

    state = state.copyWith(previewXP: xp);
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
