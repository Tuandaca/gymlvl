/// Validates that [WorkoutSet.weightKg] is treated strictly as external /
/// additional load (e.g. weighted vest, dip belt) and never as body mass.
///
/// Body mass comes exclusively from [profiles.weight_kg]. This validator never
/// derives body weight from workout_sets.weight_kg, and never accepts a profile
/// weight as a set weight. It only validates the external-load range (finite,
/// 0-1000 kg, matching the client half of validateWorkoutSetForMode).
library;

import 'package:app/features/workout/domain/workout_set.dart';

/// Validation errors produced by [BodyweightValidator].
class BodyweightValidationException implements Exception {
  final String code;
  final String message;
  const BodyweightValidationException(this.code, this.message);
  @override
  String toString() => 'BodyweightValidationException($code: $message)';
}

/// Validator for workout-set weight_kg as external load only.
class BodyweightValidator {
  /// Minimum valid external load (kg). Zero means bodyweight-only, no added
  /// load — valid.
  static const double minExternalLoadKg = 0;

  /// Maximum valid external load (kg), mirroring the workout mode contract.
  static const double maxExternalLoadKg = 1000;

  /// Returns [value] when it is a valid external load (finite, 0-1000 kg).
  /// Throws [ArgumentError] with code 'invalid_external_load' otherwise.
  ///
  /// This is external load only. Body mass is read from
  /// [profiles.weight_kg] and is never validated here.
  double validateExternalLoadKg(double value) {
    if (!value.isFinite ||
        value < minExternalLoadKg ||
        value > maxExternalLoadKg) {
      throw ArgumentError('invalid_external_load');
    }
    return value;
  }

  /// True when [value] is a valid external load.
  bool isValidExternalLoad(double value) {
    try {
      validateExternalLoadKg(value);
      return true;
    } on ArgumentError {
      return false;
    }
  }

  /// Validates [set].weightKg as external load. Does not inspect or derive
  /// body mass, and does not depend on the workout mode.
  void validateSet(WorkoutSet set) {
    validateExternalLoadKg(set.weightKg);
  }

  /// Always true: workout_sets.weight_kg is external load only, never body
  /// mass. Kept explicit so call sites can assert the contract.
  bool get isExternalLoadOnly => true;
}
