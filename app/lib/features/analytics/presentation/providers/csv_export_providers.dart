/// Riverpod providers for P4 CSV data export (Gate 6).
///
/// Owner-scoped: data is read through the owner's repositories and the export
/// contains only the current user's records. No credentials or secrets are
/// ever included.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/config/supabase_config.dart';
import 'package:app/features/analytics/data/csv_export_service.dart';
import 'package:app/features/bodyweight/data/supabase_body_measurement_repository.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';

/// CSV export result for the current user.
///
/// Computed from owner-filtered data. [exportedAt] is stamped in UTC.
final csvExportProvider = FutureProvider<CsvExportResult>((ref) async {
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

  final service = CsvExportService();
  return service.exportAll(
    workouts: workouts,
    workoutExercises: workoutExercises,
    sets: sets,
    measurements: measurements,
    exportedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
});
