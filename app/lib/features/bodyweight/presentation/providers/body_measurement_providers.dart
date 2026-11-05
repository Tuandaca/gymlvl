/// Riverpod providers for P4 general body measurements.
///
/// Owner-scoped: every measurement belongs to the authenticated user.
/// Values are read/written through PostgREST + RLS on public.body_measurements.
/// This provider never writes XP, levels, streaks, or rewards.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/config/supabase_config.dart';
import 'package:app/features/bodyweight/data/supabase_body_measurement_repository.dart';
import 'package:app/features/bodyweight/domain/body_measurement.dart';

/// Repository for owner-scoped body measurements.
final bodyMeasurementRepositoryProvider = Provider<BodyMeasurementRepository>((
  ref,
) {
  return SupabaseBodyMeasurementRepository(SupabaseConfig.client);
});

/// All body measurements for the owner, newest first.
final bodyMeasurementsProvider = FutureProvider<List<BodyMeasurement>>((
  ref,
) async {
  final repository = ref.watch(bodyMeasurementRepositoryProvider);
  return repository.getMeasurements();
});

/// Measurements for a single type, newest first.
final bodyMeasurementsByTypeProvider =
    FutureProvider.family<List<BodyMeasurement>, BodyMeasurementType>((
      ref,
      type,
    ) async {
      final repository = ref.watch(bodyMeasurementRepositoryProvider);
      return repository.getMeasurementsByType(type);
    });
