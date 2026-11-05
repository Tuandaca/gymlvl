import 'package:supabase_flutter/supabase_flutter.dart';
import 'routine_models.dart';
import 'routine_repository.dart';

class SupabaseRoutineRepository implements RoutineRepository {
  final SupabaseClient _supabase;

  SupabaseRoutineRepository(this._supabase);

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('session_required');
    return id;
  }

  static const _routineDetail =
      '*, routine_exercises(*, exercises(*)), routine_superset_groups(*), routine_schedules(*)';

  static Routine decodeRoutine(Map<String, dynamic> json) {
    final routine = Routine.fromJson({
      ...json,
      'exercises':
          (json['routine_exercises'] as List? ?? [])
              .map((e) => RoutineExercise.fromJson(e))
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
      'superset_group_ids': (json['routine_superset_groups'] as List? ?? [])
          .map((e) => e['id'] as String)
          .toList(),
    });
    return routine;
  }

  @override
  Future<List<Routine>> getRoutines() async {
    final response = await _supabase
        .from('routines')
        .select(_routineDetail)
        .eq('user_id', _userId)
        .eq('is_archived', false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => decodeRoutine(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Routine?> getRoutine(String routineId) async {
    final response = await _supabase
        .from('routines')
        .select(_routineDetail)
        .eq('id', routineId)
        .eq('user_id', _userId)
        .maybeSingle();

    return response == null ? null : decodeRoutine(response);
  }

  /// Internal method that throws if routine not found
  Future<Routine> _getRoutineOrThrow(String routineId) async {
    final routine = await getRoutine(routineId);
    if (routine == null) {
      throw StateError('Routine not found: $routineId');
    }
    return routine;
  }

  @override
  Future<Routine> createRoutine(Routine routine) async {
    if (routine.userId != _userId) {
      throw StateError('Cannot create routine for another user');
    }

    // Use RPC for atomic creation
    final response = await _supabase.rpc(
      'create_routine',
      params: {
        'p_user_id': _userId,
        'p_name': routine.name,
        'p_emoji': routine.emoji,
        'p_exercises': routine.exercises
            .map(
              (e) => {
                'exercise_id': e.exerciseId,
                'order_index': e.orderIndex,
                'sets': e.sets,
                'reps': e.reps,
                'reps_min': e.repsMin,
                'weight_kg': e.weightKg,
                'duration_seconds': e.durationSeconds,
                'rest_seconds': e.restSeconds,
                'rpe_target': e.rpeTarget,
                'rir_target': e.rirTarget,
                'warmup_sets': e.warmupSets,
                'mode': e.mode.wireValue,
                'notes': e.notes,
                'superset_group_id': e.supersetGroupId,
                'superset_position': e.supersetPosition,
                'is_warmup': e.isWarmup,
              },
            )
            .toList(),
      },
    );

    final createdId = response as String;
    return _getRoutineOrThrow(createdId);
  }

  @override
  Future<Routine> updateRoutine(Routine routine) async {
    if (routine.userId != _userId) {
      throw StateError('Cannot update routine for another user');
    }

    await _supabase
        .from('routines')
        .update({
          'name': routine.name,
          'emoji': routine.emoji,
          'is_archived': routine.isArchived,
          'version': routine.version + 1,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', routine.id)
        .eq('user_id', _userId);

    return routine.copyWith(
      version: routine.version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> archiveRoutine(String routineId) async {
    await _supabase
        .from('routines')
        .update({
          'is_archived': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', routineId)
        .eq('user_id', _userId);
  }

  @override
  Future<void> restoreRoutine(String routineId) async {
    await _supabase
        .from('routines')
        .update({
          'is_archived': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', routineId)
        .eq('user_id', _userId);
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    await _supabase
        .from('routines')
        .delete()
        .eq('id', routineId)
        .eq('user_id', _userId);
  }

  @override
  Future<Routine> duplicateRoutine({
    required String routineId,
    required String newName,
    String? emoji,
  }) async {
    final response = await _supabase.rpc(
      'duplicate_routine',
      params: {
        'p_routine_id': routineId,
        'p_new_name': newName,
        'p_emoji': emoji,
      },
    );

    final createdId = response as String;
    return _getRoutineOrThrow(createdId);
  }

  // Routine Exercises
  @override
  Future<Routine> addExerciseToRoutine({
    required String routineId,
    required RoutineExerciseConfig config,
  }) async {
    if (config.orderIndex < 0) {
      throw ArgumentError('orderIndex must be >= 0');
    }

    final response = await _supabase.rpc(
      'add_routine_exercise',
      params: {
        'p_routine_id': routineId,
        'p_exercise_id': config.exerciseId,
        'p_position': config.orderIndex,
        'p_config': {
          'sets': config.sets,
          'reps': config.reps,
          'reps_min': config.repsMin,
          'weight_kg': config.weightKg,
          'duration_seconds': config.durationSeconds,
          'rest_seconds': config.restSeconds,
          'rpe_target': config.rpeTarget,
          'rir_target': config.rirTarget,
          'warmup_sets': config.warmupSets,
          'mode': config.mode.wireValue,
          'notes': config.notes,
          'superset_group_id': config.supersetGroupId,
          'superset_position': config.supersetPosition,
          'is_warmup': config.isWarmup,
        },
      },
    );

    return _getRoutineOrThrow(response as String);
  }

  @override
  Future<Routine> updateRoutineExercise({
    required String routineId,
    required RoutineExerciseConfig config,
  }) async {
    if (config.routineExerciseId == null) {
      throw ArgumentError('routineExerciseId is required for update');
    }

    final response = await _supabase.rpc(
      'update_routine_exercise',
      params: {
        'p_routine_id': routineId,
        'p_exercise_id': config.exerciseId,
        'p_position': config.orderIndex,
        'p_config': {
          'sets': config.sets,
          'reps': config.reps,
          'reps_min': config.repsMin,
          'weight_kg': config.weightKg,
          'duration_seconds': config.durationSeconds,
          'rest_seconds': config.restSeconds,
          'rpe_target': config.rpeTarget,
          'rir_target': config.rirTarget,
          'warmup_sets': config.warmupSets,
          'mode': config.mode.wireValue,
          'notes': config.notes,
          'superset_group_id': config.supersetGroupId,
          'superset_position': config.supersetPosition,
          'is_warmup': config.isWarmup,
        },
      },
    );

    return _getRoutineOrThrow(response as String);
  }

  @override
  Future<Routine> removeExerciseFromRoutine({
    required String routineId,
    required String routineExerciseId,
  }) async {
    final response = await _supabase.rpc(
      'remove_routine_exercise',
      params: {'p_routine_id': routineId, 'p_exercise_id': routineExerciseId},
    );

    return _getRoutineOrThrow(response as String);
  }

  @override
  Future<Routine> reorderExercises({
    required String routineId,
    required List<String> exerciseIds,
  }) async {
    final response = await _supabase.rpc(
      'reorder_routine_exercises',
      params: {'p_routine_id': routineId, 'p_exercise_ids': exerciseIds},
    );

    return _getRoutineOrThrow(response as String);
  }

  @override
  Future<Routine> replaceExerciseInRoutine({
    required String routineId,
    required String routineExerciseId,
    required String newExerciseId,
    RoutineExerciseConfig? baseConfig,
  }) async {
    final response = await _supabase.rpc(
      'replace_routine_exercise',
      params: {
        'p_routine_id': routineId,
        'p_exercise_id': routineExerciseId,
        'p_new_exercise_id': newExerciseId,
        'p_config': baseConfig != null
            ? {
                'sets': baseConfig.sets,
                'reps': baseConfig.reps,
                'reps_min': baseConfig.repsMin,
                'weight_kg': baseConfig.weightKg,
                'duration_seconds': baseConfig.durationSeconds,
                'rest_seconds': baseConfig.restSeconds,
                'rpe_target': baseConfig.rpeTarget,
                'rir_target': baseConfig.rirTarget,
                'warmup_sets': baseConfig.warmupSets,
                'mode': baseConfig.mode.wireValue,
                'notes': baseConfig.notes,
                'superset_group_id': baseConfig.supersetGroupId,
                'superset_position': baseConfig.supersetPosition,
                'is_warmup': baseConfig.isWarmup,
              }
            : {},
      },
    );

    return _getRoutineOrThrow(response as String);
  }

  @override
  Future<Routine> createSupersetGroup({
    required String routineId,
    required List<String> routineExerciseIds,
  }) async {
    final response = await _supabase.rpc(
      'create_superset_group',
      params: {'p_routine_id': routineId, 'p_exercise_ids': routineExerciseIds},
    );

    return _getRoutineOrThrow(response as String);
  }

  @override
  Future<Routine> ungroupSuperset({
    required String routineId,
    required String supersetGroupId,
  }) async {
    final response = await _supabase.rpc(
      'ungroup_superset',
      params: {'p_routine_id': routineId, 'p_group_id': supersetGroupId},
    );

    return _getRoutineOrThrow(response as String);
  }

  @override
  Future<List<RoutineSchedule>> getSchedules(String routineId) async {
    final response = await _supabase
        .from('routine_schedules')
        .select()
        .eq('routine_id', routineId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => RoutineSchedule.fromJson(json))
        .toList();
  }

  @override
  Future<RoutineSchedule> scheduleRoutine({
    required String routineId,
    required ScheduleRoutineConfig config,
  }) async {
    if (config.isFixedWeek) {
      final response = await _supabase.rpc(
        'schedule_routine',
        params: {
          'p_routine_id': config.routineId,
          'p_schedule_mode': 'fixed_week',
          'p_weekday': config.weekday,
        },
      );
      final schedules = await getSchedules(config.routineId);
      return schedules.firstWhere((s) => s.id == response);
    } else {
      final response = await _supabase.rpc(
        'schedule_routine',
        params: {
          'p_routine_id': config.routineId,
          'p_schedule_mode': 'rotation',
          'p_rotation_position': config.position,
          'p_superset_group_id': config.supersetGroupId,
        },
      );
      final schedules = await getSchedules(config.routineId);
      return schedules.firstWhere((s) => s.id == response);
    }
  }

  @override
  Future<void> removeSchedule(String scheduleId) async {
    await _supabase.from('routine_schedules').delete().eq('id', scheduleId);
  }

  @override
  Future<void> reschedule({
    required String scheduleId,
    required DateTime newDate,
  }) async {
    await _supabase
        .from('planned_workouts')
        .update({
          'scheduled_date': newDate.toIso8601String().split('T')[0],
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', scheduleId);
  }

  @override
  Future<List<PlannedWorkout>> getPlannedWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _supabase
        .from('planned_workouts')
        .select()
        .eq('user_id', _userId)
        .gte('scheduled_date', startDate.toIso8601String().split('T')[0])
        .lte('scheduled_date', endDate.toIso8601String().split('T')[0])
        .order('scheduled_date', ascending: true)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => PlannedWorkout.fromJson(json))
        .toList();
  }

  @override
  Future<PlannedWorkout?> getNextPlannedWorkout() async {
    final response = await _supabase
        .from('planned_workouts')
        .select()
        .eq('user_id', _userId)
        .eq('status', 'planned')
        .gte('scheduled_date', DateTime.now().toIso8601String().split('T')[0])
        .order('scheduled_date', ascending: true)
        .order('created_at', ascending: true)
        .limit(1)
        .maybeSingle();

    return response == null ? null : PlannedWorkout.fromJson(response);
  }

  @override
  Future<PlannedWorkout> createPlannedWorkout({
    required String routineId,
    required DateTime scheduledDate,
  }) async {
    final response = await _supabase.rpc(
      'create_planned_workout',
      params: {
        'p_routine_id': routineId,
        'p_scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      },
    );

    // Get the created planned workout
    final planned = await _supabase
        .from('planned_workouts')
        .select()
        .eq('id', response)
        .single();

    return PlannedWorkout.fromJson(planned);
  }

  @override
  Future<PlannedWorkout> startPlannedWorkout(String plannedWorkoutId) async {
    final response = await _supabase.rpc(
      'start_planned_workout',
      params: {'p_planned_workout_id': plannedWorkoutId},
    );

    final workoutId = response as String;
    return PlannedWorkout(
      id: plannedWorkoutId,
      userId: _userId,
      routineId: '',
      routineName: '',
      routineSnapshot: {},
      scheduledDate: DateTime.now(),
      status: PlannedWorkoutStatus.started,
      workoutId: workoutId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> completePlannedWorkout({
    required String plannedWorkoutId,
    required String workoutId,
  }) async {
    await _supabase.rpc(
      'complete_planned_workout',
      params: {
        'p_planned_workout_id': plannedWorkoutId,
        'p_workout_id': workoutId,
      },
    );
  }

  @override
  Future<PlannedWorkout> repeatWorkout(String completedWorkoutId) async {
    final response = await _supabase.rpc(
      'repeat_workout',
      params: {'p_completed_workout_id': completedWorkoutId},
    );

    final planned = await _supabase
        .from('planned_workouts')
        .select()
        .eq('id', response)
        .single();

    return PlannedWorkout.fromJson(planned);
  }

  @override
  Future<void> cancelPlannedWorkout(String plannedWorkoutId) async {
    await _supabase
        .from('planned_workouts')
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', plannedWorkoutId)
        .eq('user_id', _userId);
  }
}
