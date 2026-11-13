/// Riverpod providers for P4 portable backup export (Gate 7).
///
/// Owner-scoped: data is read through the owner's repositories and the backup
/// contains only the current user's records. No credentials, tokens, keys, or
/// secrets are ever included. Restore/import is NOT implemented in P4.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/config/supabase_config.dart';
import 'package:app/features/analytics/data/backup_export_service.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/bodyweight/data/supabase_body_measurement_repository.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Portable, versioned GymLvl backup for the current user.
///
/// Computed from owner-filtered data. [exportedAt] is stamped in UTC.
final backupExportProvider = FutureProvider<String>((ref) async {
  final auth = ref.watch(authStateStreamProvider);
  final userId = auth.value?.session?.user.id;
  if (userId == null) throw StateError('session_required');

  final workoutRepository = ref.read(workoutRepositoryProvider);
  final expectedWorkoutCount = await workoutRepository
      .getCompletedWorkoutCount();
  final workouts = <Workout>[];
  const pageSize = 500;
  for (var offset = 0; ; offset += pageSize) {
    final page = await workoutRepository.getWorkoutHistory(
      limit: pageSize,
      offset: offset,
    );
    workouts.addAll(page);
    if (page.length < pageSize) break;
  }
  if (workouts.length != expectedWorkoutCount ||
      workouts.map((workout) => workout.id).toSet().length !=
          expectedWorkoutCount ||
      await workoutRepository.getCompletedWorkoutCount() !=
          expectedWorkoutCount) {
    throw StateError('workout_export_incomplete');
  }

  final exerciseRepository = ref.read(exerciseRepositoryProvider);
  final activeCustom = await exerciseRepository.getCustomExercises(userId);
  final archivedCustom = await exerciseRepository.getArchivedCustomExercises(
    userId,
  );
  // Compare with server counts so an unpaginated repository read cannot
  // silently produce an incomplete backup under any configured row cap.
  final customQuery = SupabaseConfig.client
      .from('exercises')
      .count(CountOption.exact)
      .eq('user_id', userId)
      .eq('source', 'user');
  final activeCount = await customQuery.eq('is_archived', false);
  final archivedCount = await SupabaseConfig.client
      .from('exercises')
      .count(CountOption.exact)
      .eq('user_id', userId)
      .eq('source', 'user')
      .eq('is_archived', true);
  if (activeCustom.length != activeCount ||
      archivedCustom.length != archivedCount) {
    throw StateError('custom_exercise_export_incomplete');
  }
  final customExercises = [...activeCustom, ...archivedCustom];

  final workoutExercises = <WorkoutExercise>[];
  final sets = <WorkoutSet>[];
  for (final w in workouts) {
    for (final we in w.exercises) {
      workoutExercises.add(we);
      sets.addAll(we.sets);
    }
  }

  final measurementRepository = SupabaseBodyMeasurementRepository(
    SupabaseConfig.client,
  );
  final measurements = await measurementRepository.getMeasurements();
  final measurementCount = await SupabaseConfig.client
      .from('body_measurements')
      .count(CountOption.exact)
      .eq('user_id', userId);
  if (measurements.length != measurementCount) {
    throw StateError('measurement_export_incomplete');
  }

  final service = BackupExportService();
  return service.exportV2(
    userId: userId,
    workouts: workouts,
    workoutExercises: workoutExercises,
    sets: sets,
    measurements: measurements,
    customExercises: customExercises,
    exportedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
});
