/// Compile-time gates stay closed until remote schema deployment and the
/// separate production activation checks are authorized and verified.
const bool productionWorkoutModesEnabled = false;
const bool productionSupersetEnabled = false;

/// The persisted workout-exercise discriminator. A null value means legacy
/// data with no recorded mode; it must never be inferred from set fields.
enum WorkoutMode {
  repsWeight('reps-weight'),
  bodyweight('bodyweight'),
  timed('timed'),
  cardio('cardio');

  const WorkoutMode(this.wireValue);
  final String wireValue;
}

WorkoutMode? workoutModeFromJson(String? value) {
  if (value == null) return null;
  for (final mode in WorkoutMode.values) {
    if (mode.wireValue == value) return mode;
  }
  throw FormatException('Unsupported workout mode: $value');
}

String? workoutModeToJson(WorkoutMode? value) => value?.wireValue;

/// Client validation mirrors the approved contract. PostgreSQL independently
/// validates completed sets and remains the completion/reward authority.
void validateWorkoutSetForMode({
  required WorkoutMode? mode,
  required int reps,
  required double weightKg,
  required int durationSeconds,
  required bool isCompleted,
}) {
  if (reps < 0 || reps > 1000) throw ArgumentError('invalid_reps');
  if (!weightKg.isFinite || weightKg < 0 || weightKg > 1000) {
    throw ArgumentError('invalid_weight');
  }
  if (durationSeconds < 0 || durationSeconds > 7200) {
    throw ArgumentError('invalid_duration');
  }

  switch (mode) {
    case WorkoutMode.repsWeight:
    case WorkoutMode.bodyweight:
      if (durationSeconds != 0) throw ArgumentError('invalid_duration');
      if (isCompleted && reps == 0) throw ArgumentError('invalid_reps');
      return;
    case WorkoutMode.timed:
    case WorkoutMode.cardio:
      if (reps != 0) throw ArgumentError('invalid_reps');
      if (weightKg != 0) throw ArgumentError('invalid_weight');
      if (isCompleted && durationSeconds == 0) {
        throw ArgumentError('invalid_duration');
      }
      return;
    case null:
      if (isCompleted && reps == 0 && durationSeconds == 0) {
        throw ArgumentError('invalid_measurements');
      }
      return;
  }
}
