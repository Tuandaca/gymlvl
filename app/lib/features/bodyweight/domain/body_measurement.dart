// ignore_for_file: invalid_annotation_target

/// A single general body measurement (P4 Gate 2).
///
/// Normalized record: measurement_type + numeric value + explicit unit.
/// Supported types mirror OpenGym's measurement set: body weight, body fat
/// percentage, chest, waist, hips, upper arm, thigh. Units are canonical
/// per type (kg for weight/fat, cm for girths) and are stored explicitly —
/// historical values are never silently converted.
///
/// This extends (and is compatible with) the existing M5 bodyweight domain:
/// body mass remains authoritative from [profiles.weight_kg] and
/// public.bodyweight_measurements; this table is additive and does not
/// replace it. workout_sets.weight_kg remains external/added load only.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_measurement.freezed.dart';
part 'body_measurement.g.dart';

/// Supported body measurement types (canonical, owner-scoped).
enum BodyMeasurementType {
  @JsonValue('body_weight')
  bodyWeight,
  @JsonValue('body_fat_percentage')
  bodyFatPercentage,
  @JsonValue('chest')
  chest,
  @JsonValue('waist')
  waist,
  @JsonValue('hips')
  hips,
  @JsonValue('upper_arm')
  upperArm,
  @JsonValue('thigh')
  thigh,
}

extension BodyMeasurementTypeX on BodyMeasurementType {
  /// Canonical unit for this type.
  String get canonicalUnit {
    switch (this) {
      case BodyMeasurementType.bodyWeight:
        return 'kg';
      case BodyMeasurementType.bodyFatPercentage:
        return 'percent';
      case BodyMeasurementType.chest:
      case BodyMeasurementType.waist:
      case BodyMeasurementType.hips:
      case BodyMeasurementType.upperArm:
      case BodyMeasurementType.thigh:
        return 'cm';
    }
  }

  /// Wire value persisted to the database.
  String get wireValue {
    switch (this) {
      case BodyMeasurementType.bodyWeight:
        return 'body_weight';
      case BodyMeasurementType.bodyFatPercentage:
        return 'body_fat_percentage';
      case BodyMeasurementType.chest:
        return 'chest';
      case BodyMeasurementType.waist:
        return 'waist';
      case BodyMeasurementType.hips:
        return 'hips';
      case BodyMeasurementType.upperArm:
        return 'upper_arm';
      case BodyMeasurementType.thigh:
        return 'thigh';
    }
  }

  /// Localization key for the type's human-readable label.
  String get labelKey {
    switch (this) {
      case BodyMeasurementType.bodyWeight:
        return 'body_weight';
      case BodyMeasurementType.bodyFatPercentage:
        return 'body_fat_percentage';
      case BodyMeasurementType.chest:
        return 'chest';
      case BodyMeasurementType.waist:
        return 'waist';
      case BodyMeasurementType.hips:
        return 'hips';
      case BodyMeasurementType.upperArm:
        return 'upper_arm';
      case BodyMeasurementType.thigh:
        return 'thigh';
    }
  }
}

/// Explicit measurement unit, matched to the type's canonical unit.
enum BodyMeasurementUnit {
  @JsonValue('kg')
  kg,
  @JsonValue('cm')
  cm,
  @JsonValue('percent')
  percent,
}

extension BodyMeasurementUnitX on BodyMeasurementUnit {
  String get wireValue {
    switch (this) {
      case BodyMeasurementUnit.kg:
        return 'kg';
      case BodyMeasurementUnit.cm:
        return 'cm';
      case BodyMeasurementUnit.percent:
        return 'percent';
    }
  }
}

/// One body measurement point.
@freezed
abstract class BodyMeasurement with _$BodyMeasurement {
  const BodyMeasurement._();
  const factory BodyMeasurement({
    required String id,
    required String userId,
    required BodyMeasurementType type,
    @JsonKey(name: 'measurement_type') BodyMeasurementType? measurementType,
    required double value,
    required BodyMeasurementUnit unit,
    @JsonKey(name: 'measured_at') required DateTime measuredAt,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BodyMeasurement;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementFromJson(json);

  /// True when the stored unit matches the type's canonical unit.
  bool get unitIsCanonical => unit.wireValue == type.canonicalUnit;

  Map<String, dynamic> toSupabaseJson() => <String, dynamic>{
    'user_id': userId,
    'measurement_type': type.wireValue,
    'value': value,
    'unit': unit.wireValue,
    'measured_at': measuredAt.toUtc().toIso8601String(),
    if (notes != null) 'notes': notes,
  };

  /// Localization key for the type's human-readable label.
  String get typeLabelKey => type.labelKey;
}
