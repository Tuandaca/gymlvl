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
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';

/// Portable, versioned GymLvl backup for the current user.
///
/// Computed from owner-filtered data. [exportedAt] is stamped in UTC.
final backupExportProvider = FutureProvider<String>((ref) async {
  final workouts = await ref
      .read(workoutRepositoryProvider)
      .getWorkoutHistory(limit: 10000, offset: 0);
  await ref.read(exerciseRepositoryProvider).getExercises();

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

  final auth = ref.watch(authStateStreamProvider);
  final userId = auth.value?.session?.user.id ?? '';

  final service = BackupExportService();
  return service.export(
    userId: userId,
    workouts: workouts,
    workoutExercises: workoutExercises,
    sets: sets,
    measurements: measurements,
    preferences: const <String, dynamic>{'locale': 'vi'},
    exportedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
});
