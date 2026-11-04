// ignore_for_file: invalid_annotation_target

/// A single body-mass measurement (weigh-in) on the client.
///
/// Body mass is authoritative from [profiles.weight_kg]; this value type is a
/// client-side record of a weigh-in point. workout_sets.weight_kg is NEVER body
/// mass — it is external/additional load only (weighted vest, dip belt, etc.).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'bodyweight_measurement.freezed.dart';
part 'bodyweight_measurement.g.dart';

/// Source of a single body-mass measurement.
enum BodyweightSource {
  profileBaseline('profile_baseline'),
  manualWeighIn('manual_weigh_in'),
  scale('scale');

  const BodyweightSource(this.wireValue);
  final String wireValue;
}

/// One weigh-in point: body mass in kg at a point in time.
///
/// The only legitimate way a profile weight becomes a measurement is
/// [BodyweightMeasurement.fromProfile], which reads [profiles.weight_kg].
/// Workout sets never contribute body mass to this type.
@freezed
abstract class BodyweightMeasurement with _$BodyweightMeasurement {
  const BodyweightMeasurement._();
  const factory BodyweightMeasurement({
    required String id,
    required String userId,
    @JsonKey(name: 'weight_kg') required double weightKg,
    @JsonKey(name: 'measured_at') required DateTime measuredAt,
    @JsonKey(name: 'source') required BodyweightSource source,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _BodyweightMeasurement;

  factory BodyweightMeasurement.fromJson(Map<String, dynamic> json) =>
      _$BodyweightMeasurementFromJson(json);

  /// Builds a baseline measurement from the authoritative profile body mass
  /// ([profiles.weight_kg]). workout_sets.weight_kg is never used here.
  factory BodyweightMeasurement.fromProfile({
    required String userId,
    required double profileWeightKg,
    String id = '',
    DateTime? measuredAt,
  }) {
    return BodyweightMeasurement(
      id: id,
      userId: userId,
      weightKg: profileWeightKg,
      measuredAt: measuredAt ?? DateTime.utc(2026, 11, 1),
      source: BodyweightSource.profileBaseline,
    );
  }

  /// True when this measurement is the onboarding/profile baseline.
  bool get isBaseline => source == BodyweightSource.profileBaseline;
}
