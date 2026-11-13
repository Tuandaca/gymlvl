import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/workout.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_set.dart';
import '../domain/workout_repository.dart';
import '../domain/workout_mode_contract.dart';

class SupabaseWorkoutRepository
    implements
        WorkoutRepository,
        HistoricalWorkoutImportRepository,
        HistoricalMeasurementImportRepository,
        HistoricalImportIdentity,
        HistoricalCustomExerciseImportRepository,
        ModeAwareWorkoutRepository,
        AtomicWorkoutMutationRepository,
        SupersetLayoutRepository {
  final SupabaseClient _supabase;
  SupabaseWorkoutRepository(this._supabase);

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('session_required');
    return id;
  }

  @override
  String get authenticatedUserId => _userId;

  static const _detail =
      '*, workout_exercises(*, exercises(*), workout_sets(*))';

  static String _newOperationId() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

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
  Future<HistoricalWorkoutImportReceipt> importHistoricalWorkout({
    required String importKey,
    required Map<String, dynamic> payload,
  }) async {
    // The owner is derived by the server from auth.uid(), never from the file.
    _userId;
    final response = await _supabase.rpc(
      'import_historical_workout_v1',
      params: {'p_import_key': importKey, 'p_payload': payload},
    );
    if (response is! Map ||
        response['workoutId'] is! String ||
        (response['workoutId'] as String).isEmpty ||
        response['alreadyImported'] is! bool) {
      throw StateError('invalid_historical_import_receipt');
    }
    final rawCustomIds = response['createdCustomExerciseIds'];
    final requestedCustom =
        (payload['exercises'] as List?)?.any(
          (exercise) =>
              exercise is Map && exercise.containsKey('custom_exercise'),
        ) ??
        false;
    if (rawCustomIds != null &&
        (rawCustomIds is! List ||
            rawCustomIds.any((id) => id is! String || id.isEmpty))) {
      throw StateError('invalid_historical_import_receipt');
    }
    if (requestedCustom && rawCustomIds == null) {
      throw StateError('invalid_historical_import_receipt');
    }
    return HistoricalWorkoutImportReceipt(
      workoutId: response['workoutId'] as String,
      alreadyImported: response['alreadyImported'] as bool,
      createdCustomExerciseIds: rawCustomIds == null
          ? const []
          : List<String>.from(rawCustomIds as List),
    );
  }

  @override
  Future<HistoricalMeasurementImportReceipt> importHistoricalMeasurement({
    required String importKey,
    required Map<String, dynamic> payload,
  }) async {
    _userId;
    final response = await _supabase.rpc(
      'import_historical_measurement_v1',
      params: {'p_import_key': importKey, 'p_payload': payload},
    );
    if (response is! Map ||
        response['measurementId'] is! String ||
        (response['measurementId'] as String).isEmpty ||
        response['alreadyImported'] is! bool) {
      throw StateError('invalid_historical_measurement_receipt');
    }
    return HistoricalMeasurementImportReceipt(
      measurementId: response['measurementId'] as String,
      alreadyImported: response['alreadyImported'] as bool,
    );
  }

  @override
  Future<HistoricalCustomExerciseImportReceipt> importCustomExercise({
    required String importKey,
    required Map<String, dynamic> payload,
  }) async {
    _userId;
    final response = await _supabase.rpc(
      'import_custom_exercise_v1',
      params: {'p_import_key': importKey, 'p_payload': payload},
    );
    if (response is! Map ||
        response['exerciseId'] is! String ||
        (response['exerciseId'] as String).isEmpty ||
        response['alreadyImported'] is! bool ||
        response['created'] is! bool) {
      throw StateError('invalid_custom_import_receipt');
    }
    return HistoricalCustomExerciseImportReceipt(
      exerciseId: response['exerciseId'] as String,
      alreadyImported: response['alreadyImported'] as bool,
      created: response['created'] as bool,
    );
  }

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
  Future<Workout> markWorkoutCompleted(
    String workoutId, {
    DateTime? completedAt,
    int? durationSeconds,
    String? notes,
  }) async {
    final response = await _supabase
        .from('workouts')
        .update({
          'status': 'completed',
          if (completedAt != null)
            'completed_at': completedAt.toUtc().toIso8601String(),
          'duration_seconds': ?durationSeconds,
          'notes': ?notes,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', workoutId)
        .eq('user_id', _userId)
        .select(_detail)
        .single();
    return decodeWorkout(response);
  }

  @override
  Future<void> cancelWorkout(String workoutId) async {
    await _supabase.rpc('cancel_workout', params: {'p_workout_id': workoutId});
  }

  @override
  Future<Workout> updateWorkoutNotes(String workoutId, String notes) async {
    if (notes.length > 4000) {
      throw ArgumentError('notes_too_long');
    }
    final response = await _supabase
        .from('workouts')
        .update({'notes': notes})
        .eq('id', workoutId)
        .select(_detail)
        .single();
    return decodeWorkout(response);
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
  Future<WorkoutExercise> addExerciseToWorkoutWithMode(
    String workoutId,
    String exerciseId,
    int orderIndex,
    WorkoutMode mode,
  ) async {
    if (!productionWorkoutModesEnabled) {
      throw StateError('workout_mode_schema_not_deployed');
    }
    final response = await _supabase
        .from('workout_exercises')
        .insert({
          'workout_id': workoutId,
          'exercise_id': exerciseId,
          'order_index': orderIndex,
          'mode': mode.wireValue,
        })
        .select('*, exercises(*), workout_sets(*)')
        .single();
    return WorkoutExercise.fromJson(response);
  }

  @override
  Future<void> setSupersetLayout(
    String workoutId,
    List<SupersetGroupLayout> groups,
  ) async {
    if (!productionSupersetEnabled) {
      throw StateError('superset_schema_not_deployed');
    }
    try {
      await _supabase.rpc(
        'set_superset_layout_v1',
        params: {
          'p_workout_id': workoutId,
          'p_groups': groups.map((group) => group.toJson()).toList(),
        },
      );
    } on PostgrestException catch (error) {
      if (error.code == '22023' &&
          error.message.contains('Completed superset membership')) {
        throw const SupersetLayoutLocked();
      }
      rethrow;
    }
  }

  @override
  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {
    await _supabase
        .from('workout_exercises')
        .delete()
        .eq('id', workoutExerciseId);
  }

  @override
  Future<WorkoutExercise> replaceExercise(
    String workoutExerciseId,
    String newExerciseId,
  ) async {
    final response = await _supabase
        .from('workout_exercises')
        .update({'exercise_id': newExerciseId})
        .eq('id', workoutExerciseId)
        .select('*, exercises(*), workout_sets(*)')
        .single();
    return WorkoutExercise.fromJson(response);
  }

  @override
  Future<void> reorderExercises(String workoutId, List<String> ids) async {
    await reorderWorkoutExercisesAtomically(
      operationId: _newOperationId(),
      workoutId: workoutId,
      exerciseIds: ids,
    );
  }

  @override
  Future<Workout> reorderWorkoutExercisesAtomically({
    required String operationId,
    required String workoutId,
    required List<String> exerciseIds,
  }) async {
    _userId;
    final receipt = await _supabase.rpc(
      'reorder_workout_exercises_v1',
      params: {
        'p_operation_id': operationId,
        'p_workout_id': workoutId,
        'p_exercise_ids': exerciseIds,
      },
    );
    if (receipt is! Map ||
        receipt['operation_id'] != operationId ||
        receipt['workout_id'] != workoutId ||
        receipt['exercise_count'] != exerciseIds.length) {
      throw StateError('invalid_reorder_receipt');
    }
    final workout = await getWorkoutDetail(workoutId);
    if (workout == null) throw StateError('reordered_workout_unavailable');
    return workout;
  }

  @override
  Future<Workout> addExerciseWithDefaultSets({
    required String operationId,
    required String workoutId,
    required String exerciseId,
    required WorkoutMode? mode,
    required List<Map<String, Object>> sets,
  }) async {
    _userId;
    final receipt = await _supabase.rpc(
      'add_workout_exercise_with_sets_v1',
      params: {
        'p_operation_id': operationId,
        'p_workout_id': workoutId,
        'p_exercise_id': exerciseId,
        'p_mode': mode?.wireValue,
        'p_sets': sets,
      },
    );
    final insertedId = receipt is Map ? receipt['workout_exercise_id'] : null;
    final setIds = receipt is Map ? receipt['set_ids'] : null;
    if (receipt is! Map ||
        receipt['operation_id'] != operationId ||
        receipt['workout_id'] != workoutId ||
        insertedId is! String ||
        insertedId.isEmpty ||
        setIds is! List ||
        setIds.length != sets.length ||
        setIds.any((id) => id is! String || id.isEmpty)) {
      throw StateError('invalid_add_exercise_receipt');
    }
    final workout = await getWorkoutDetail(workoutId);
    if (workout == null) throw StateError('added_workout_unavailable');
    final matches = workout.exercises.where((item) => item.id == insertedId);
    if (matches.length != 1 ||
        matches.single.exerciseId != exerciseId ||
        !setIds.every((id) => matches.single.sets.any((set) => set.id == id))) {
      throw StateError('added_exercise_unavailable');
    }
    return workout;
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
    WorkoutSetType? setType,
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
    if (setType != null) {
      data['set_type'] = setType == WorkoutSetType.warmup
          ? 'warmup'
          : 'workout';
    }
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
        .order('id', ascending: false)
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
