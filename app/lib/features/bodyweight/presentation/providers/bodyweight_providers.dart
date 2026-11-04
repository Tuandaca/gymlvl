/// Riverpod providers for the M5 bodyweight presentation.
///
/// Body mass comes exclusively from [profiles.weight_kg]. workout_sets.weight_kg
/// is external/added load only and is never used as body mass here.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/bodyweight/domain/bodyweight_measurement.dart';
import 'package:app/features/bodyweight/domain/bodyweight_trend.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';

/// Bodyweight measurements for the current user.
///
/// Builds a baseline measurement from [profiles.weight_kg] (authoritative body
/// mass). Returns an empty list when no profile weight is recorded.
final bodyweightMeasurementsProvider =
    FutureProvider<List<BodyweightMeasurement>>((ref) async {
  final profile = await ref.read(currentUserProfileProvider.future);
  final auth = ref.watch(authStateStreamProvider);
  final userId = auth.value?.session?.user.id ?? '';
  final weightKg = (profile?['weight_kg'] as num?)?.toDouble();
  if (weightKg == null || weightKg <= 0) return const [];
  return [
    BodyweightMeasurement.fromProfile(
      userId: userId,
      profileWeightKg: weightKg,
    ),
  ];
});

/// Bodyweight trend points (date, weightKg) sorted ascending, for chart consumption.
final bodyweightTrendProvider =
    FutureProvider<List<BodyweightTrendPoint>>((ref) async {
  final measurements = await ref.read(bodyweightMeasurementsProvider.future);
  return BodyweightTrend(measurements).toChartPoints();
});
