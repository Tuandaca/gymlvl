import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/workout.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_set.dart';
import '../domain/workout_repository.dart';

class SupabaseWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _supabase;

  SupabaseWorkoutRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  // ─── Nested select query for full workout detail ───
  static const String _workoutDetailSelect = '''
    *, 
    workout_exercises(
      *, 
      exercises(*), 
      workout_sets(*)
    )
  ''';

  @override
  Future<Workout> startWorkout() async {
    final response = await _supabase
        .from('workouts')
        .insert({
          'user_id': _userId,
          'status': 'active',
          'started_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select(_workoutDetailSelect)
        .single();

    return Workout.fromJson(response);
  }

  @override
  Future<Workout?> getActiveWorkout() async {
    final response = await _supabase
        .from('workouts')
        .select(_workoutDetailSelect)
        .eq('user_id', _userId)
        .eq('status', 'active')
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return Workout.fromJson(response);
  }

  @override
  Future<Workout> completeWorkout(String workoutId, {String? notes}) async {
    final now = DateTime.now().toUtc();

    // Lấy workout hiện tại để tính duration
    final currentWorkout = await _supabase
        .from('workouts')
        .select('started_at')
        .eq('id', workoutId)
        .single();

    final startedAt = DateTime.parse(currentWorkout['started_at']);
    final durationSeconds = now.difference(startedAt).inSeconds;

    final response = await _supabase
        .from('workouts')
        .update({
          'status': 'completed',
          'completed_at': now.toIso8601String(),
          'duration_seconds': durationSeconds,
          if (notes != null) 'notes': notes,
        })
        .eq('id', workoutId)
        .select(_workoutDetailSelect)
        .single();

    return Workout.fromJson(response);
  }

  @override
  Future<void> cancelWorkout(String workoutId) async {
    await _supabase
        .from('workouts')
        .update({'status': 'cancelled'})
        .eq('id', workoutId);
  }

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
      String workoutId, String exerciseId, int orderIndex) async {
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
  Future<void> reorderExercises(
      String workoutId, List<String> workoutExerciseIds) async {
    // Update thứ tự từng exercise
    for (int i = 0; i < workoutExerciseIds.length; i++) {
      await _supabase
          .from('workout_exercises')
          .update({'order_index': i})
          .eq('id', workoutExerciseIds[i]);
    }
  }

  @override
  Future<WorkoutSet> addSet(
      String workoutExerciseId, int setNumber, int reps, double weightKg, {double baselineWeightKg = 0}) async {
    final response = await _supabase
        .from('workout_sets')
        .insert({
          'workout_exercise_id': workoutExerciseId,
          'set_number': setNumber,
          'reps': reps,
          'weight_kg': weightKg,
          'baseline_weight_kg': baselineWeightKg,
        })
        .select()
        .single();

    return WorkoutSet.fromJson(response);
  }

  @override
  Future<WorkoutSet> updateSet(String setId,
      {int? reps, double? weightKg, bool? isCompleted, int? restSeconds}) async {
    final updateData = <String, dynamic>{};
    if (reps != null) updateData['reps'] = reps;
    if (weightKg != null) updateData['weight_kg'] = weightKg;
    if (isCompleted != null) updateData['is_completed'] = isCompleted;
    if (restSeconds != null) updateData['rest_seconds'] = restSeconds;

    final response = await _supabase
        .from('workout_sets')
        .update(updateData)
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
        .select('*, workout_exercises!inner(exercise_id, workout_id, workouts!inner(user_id))')
        .eq('workout_exercises.exercise_id', exerciseId)
        .eq('workout_exercises.workouts.user_id', _userId) // Only match the current user's history
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return WorkoutSet.fromJson(response);
  }

  @override
  Future<Workout?> getWorkoutDetail(String workoutId) async {
    final response = await _supabase
        .from('workouts')
        .select(_workoutDetailSelect)
        .eq('id', workoutId)
        .maybeSingle();

    if (response == null) return null;
    return Workout.fromJson(response);
  }

  @override
  Future<List<Workout>> getWorkoutHistory(
      {int limit = 20, int offset = 0}) async {
    final response = await _supabase
        .from('workouts')
        .select(_workoutDetailSelect)
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => Workout.fromJson(json)).toList();
  }

  @override
  Future<int> getCompletedWorkoutCount() async {
    final response = await _supabase
        .from('workouts')
        .select('id')
        .eq('user_id', _userId)
        .eq('status', 'completed');

    return (response as List).length;
  }

  @override
  Future<Map<String, dynamic>> calculateXP(String workoutId) async {
    final session = _supabase.auth.currentSession;
    final token = session?.accessToken;
    
    // ignore: avoid_print
    print('DEBUG: Calling calculate-xp. session exists: ${session != null}, token length: ${token?.length ?? 0}');

    final response = await _supabase.functions.invoke(
      'calculate-xp',
      body: {'workout_id': workoutId},
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    
    if (response.status == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to calculate XP: \${response.data}');
    }
  }
}
