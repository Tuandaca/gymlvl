import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/workout.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_set.dart';
import '../domain/workout_repository.dart';

class SupabaseWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _supabase;
  SupabaseWorkoutRepository(this._supabase);

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('session_required');
    return id;
  }

  static const _detail =
      '*, workout_exercises(*, exercises(*), workout_sets(*))';

  static Workout decodeWorkout(Map<String, dynamic> json) {
    final workout = Workout.fromJson(json);
    final exercises = workout.exercises.map((exercise) {
      final sets = [...exercise.sets]
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      return exercise.copyWith(sets: sets);
    }).toList()..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return workout.copyWith(exercises: exercises);
  }

  Future<Workout> _workoutRpc(
    String name, [
    Map<String, dynamic>? params,
  ]) async {
    final data = await _supabase.rpc(name, params: params);
    return decodeWorkout(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<Workout> startWorkout() => _workoutRpc('start_workout');

  @override
  Future<Workout> beginWorkout(String workoutId) =>
      _workoutRpc('begin_workout', {'p_workout_id': workoutId});

  @override
  Future<Workout> setWorkoutPaused(String workoutId, bool paused) =>
      _workoutRpc('set_workout_paused', {
        'p_workout_id': workoutId,
        'p_paused': paused,
      });

  @override
  Future<Workout?> getActiveWorkout() async {
    final response = await _supabase
        .from('workouts')
        .select(_detail)
        .eq('user_id', _userId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response == null ? null : decodeWorkout(response);
  }

  @override
  Future<WorkoutCompletion> finishWorkout(
    String workoutId, {
    String? notes,
  }) async {
    final owner = _userId;
    Object? result;
    try {
      result = await _supabase.rpc(
        'complete_workout',
        params: {'p_workout_id': workoutId, 'p_notes': notes},
      );
    } on PostgrestException catch (error) {
      // Only explicit PostgreSQL validation/permission rejections are definite.
      if (const ['22023', '42501', 'P0001', '23514'].contains(error.code)) {
        throw const WorkoutCompletionRejected();
      }
      throw const WorkoutCompletionUncertain();
    } catch (_) {
      throw const WorkoutCompletionUncertain();
    }
    if (_supabase.auth.currentUser?.id != owner ||
        result is! Map<String, dynamic> ||
        !validRewards(result)) {
      throw const WorkoutCompletionUncertain();
    }
    return reconcileCompletion(WorkoutReceipt(workoutId, owner, result));
  }

  static bool validRewards(Map<String, dynamic> rewards) {
    final earned = rewards['earnedXP'];
    if (earned is! int || earned < 0) return false;
    for (final key in ['totalXP', 'newLevel', 'nextLevelXp', 'streak']) {
      if (rewards.containsKey(key) &&
          (rewards[key] is! num ||
              !(rewards[key] as num).isFinite ||
              (rewards[key] as num) < 0)) {
        return false;
      }
    }
    for (final key in [
      'leveledUp',
      'alreadyAwarded',
      'isQuest',
      'isSuspicious',
    ]) {
      if (rewards.containsKey(key) && rewards[key] is! bool) return false;
    }
    if (rewards['newTitle'] != null && rewards['newTitle'] is! String) {
      return false;
    }
    return true;
  }

  @override
  Future<WorkoutCompletion> reconcileCompletion(WorkoutReceipt receipt) async {
    if (_supabase.auth.currentUser?.id != receipt.userId) {
      throw const WorkoutCompletionUncertain();
    }
    try {
      final workout = await getWorkoutDetail(receipt.workoutId);
      if (_supabase.auth.currentUser?.id != receipt.userId ||
          workout == null ||
          workout.id != receipt.workoutId ||
          workout.userId != receipt.userId ||
          workout.status != WorkoutStatus.completed ||
          workout.completedAt == null ||
          workout.durationSeconds < 0) {
        throw StateError('detail_requires_reconciliation');
      }
      return WorkoutCompletion(workout, receipt.rewards);
    } catch (_) {
      throw WorkoutReconciliationRequired(receipt);
    }
  }

  @override
  Future<Workout> completeWorkout(String workoutId, {String? notes}) async =>
      (await finishWorkout(workoutId, notes: notes)).workout;

  @override
  Future<Map<String, dynamic>> calculateXP(String workoutId) async =>
      Map<String, dynamic>.from(
        await _supabase.rpc(
              'complete_workout',
              params: {'p_workout_id': workoutId},
            )
            as Map,
      );

  @override
  Future<void> cancelWorkout(String workoutId) async {
    await _supabase.rpc('cancel_workout', params: {'p_workout_id': workoutId});
  }

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  ) async {
    final response = await _supabase
        .from('workout_exercises')
        .insert({
          'workout_id': workoutId,
          'exercise_id': exerciseId,
          'order_index': orderIndex,
        })
        .select('*, exercises(*), workout_sets(*)')
        .single();
    return WorkoutExercise.fromJson(response);
  }

  @override
  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {
    await _supabase
        .from('workout_exercises')
        .delete()
        .eq('id', workoutExerciseId);
  }

  @override
  Future<void> reorderExercises(String workoutId, List<String> ids) async {
    for (var i = 0; i < ids.length; i++) {
      await _supabase
          .from('workout_exercises')
          .update({'order_index': i})
          .eq('id', ids[i])
          .eq('workout_id', workoutId);
    }
  }

  @override
  Future<WorkoutSet> addSet(
    String workoutExerciseId,
    int setNumber,
    int reps,
    double weightKg, {
    double baselineWeightKg = 0,
    int durationSeconds = 0,
  }) async {
    validateSet(
      reps: reps,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
    );
    final payload = <String, dynamic>{
      'workout_exercise_id': workoutExerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight_kg': weightKg,
    };
    if (durationSeconds > 0) {
      payload['duration_seconds'] = durationSeconds;
    }
    final response = await _supabase
        .from('workout_sets')
        .insert(payload)
        .select()
        .single();
    return WorkoutSet.fromJson(response);
  }

  static void validateSet({
    int? reps,
    double? weightKg,
    int? restSeconds,
    int? durationSeconds,
  }) {
    if (reps != null && (reps < 0 || reps > 1000)) {
      throw ArgumentError('invalid_reps');
    }
    if (weightKg != null &&
        (!weightKg.isFinite || weightKg < 0 || weightKg > 1000)) {
      throw ArgumentError('invalid_weight');
    }
    if (restSeconds != null && (restSeconds < 0 || restSeconds > 7200)) {
      throw ArgumentError('invalid_rest');
    }
    if (durationSeconds != null &&
        (durationSeconds < 0 || durationSeconds > 7200)) {
      throw ArgumentError('invalid_duration');
    }
  }

  @override
  Future<WorkoutSet> updateSet(
    String setId, {
    int? reps,
    double? weightKg,
    bool? isCompleted,
    int? restSeconds,
    int? durationSeconds,
  }) async {
    validateSet(
      reps: reps,
      weightKg: weightKg,
      restSeconds: restSeconds,
      durationSeconds: durationSeconds,
    );
    final data = <String, dynamic>{};
    if (reps != null) data['reps'] = reps;
    if (weightKg != null) data['weight_kg'] = weightKg;
    if (isCompleted != null) data['is_completed'] = isCompleted;
    if (restSeconds != null) data['rest_seconds'] = restSeconds;
    if (durationSeconds != null) data['duration_seconds'] = durationSeconds;

    final response = await _supabase
        .from('workout_sets')
        .update(data)
        .eq('id', setId)
        .select()
        .single();
    return WorkoutSet.fromJson(response);
  }

  @override
  Future<void> deleteSet(String setId) async {
    await _supabase.from('workout_sets').delete().eq('id', setId);
  }

  @override
  Future<WorkoutSet?> getLastSetForExercise(String exerciseId) async {
    final response = await _supabase
        .from('workout_sets')
        .select(
          '*, workout_exercises!inner(exercise_id, workouts!inner(user_id, status, completed_at))',
        )
        .eq('workout_exercises.exercise_id', exerciseId)
        .eq('workout_exercises.workouts.user_id', _userId)
        .eq('workout_exercises.workouts.status', 'completed')
        .eq('is_completed', true)
        .gt('reps', 0)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response == null ? null : WorkoutSet.fromJson(response);
  }

  @override
  Future<Workout?> getWorkoutDetail(String workoutId) async {
    final response = await _supabase
        .from('workouts')
        .select(_detail)
        .eq('id', workoutId)
        .eq('user_id', _userId)
        .maybeSingle();
    return response == null ? null : decodeWorkout(response);
  }

  @override
  Future<List<Workout>> getWorkoutHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('workouts')
        .select(_detail)
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map(decodeWorkout).toList();
  }

  @override
  Future<int> getCompletedWorkoutCount() async => await _supabase
      .from('workouts')
      .count(CountOption.exact)
      .eq('user_id', _userId)
      .eq('status', 'completed');
}
