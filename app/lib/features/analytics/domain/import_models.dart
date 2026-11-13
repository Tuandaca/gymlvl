/// P7 Gate 3: normalized import models for the reusable import pipeline.
///
/// These models are the canonical in-memory representation of a parsed
/// workout file, independent of the source format. They are validated before
/// persistence and never written directly to XP/reward tables.
library;

bool _sameImportedSets(List<ImportedSet> left, List<ImportedSet> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

/// A single normalized set from an imported source.
class ImportedSet {
  const ImportedSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    required this.durationSeconds,
    this.unit, // 'kg' | 'lb' | null; null = no weight (bodyweight/timed/cardio)
    this.notes,

    /// Raw source value preserved for audit/debugging (never canonical).
    this.rawWeight,
    this.rawUnit,
  });

  final int setNumber;
  final int reps;
  final double weightKg; // normalized to kg
  final int durationSeconds; // normalized to seconds
  final String? unit;
  final String? notes;
  final String? rawWeight;
  final String? rawUnit;

  ImportedSet copyWith({
    int? setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    String? unit,
    String? notes,
    String? rawWeight,
    String? rawUnit,
  }) {
    return ImportedSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      rawWeight: rawWeight ?? this.rawWeight,
      rawUnit: rawUnit ?? this.rawUnit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportedSet &&
          runtimeType == other.runtimeType &&
          setNumber == other.setNumber &&
          reps == other.reps &&
          weightKg == other.weightKg &&
          durationSeconds == other.durationSeconds &&
          unit == other.unit &&
          notes == other.notes;

  @override
  int get hashCode =>
      Object.hash(setNumber, reps, weightKg, durationSeconds, unit, notes);
}

/// A single normalized exercise within an imported workout.
class ImportedExercise {
  const ImportedExercise({
    required this.sourceName, // name as it appeared in the source file
    this.exerciseId, // resolved canonical/custom exercise id (null if unresolved)
    this.matchedExerciseId, // canonical exercise id when matched to catalogue
    this.customExerciseId, // user-owned custom exercise id when created/mapped
    this.resolution, // how the exercise was resolved
    required this.sets,
    this.notes,
    this.orderIndex,
  });

  final String sourceName;
  final String? exerciseId; // resolved id used for persistence
  final String? matchedExerciseId;
  final String? customExerciseId;
  final ImportExerciseResolution? resolution;
  final List<ImportedSet> sets;
  final String? notes;
  final int? orderIndex;

  ImportedExercise copyWith({
    String? sourceName,
    String? exerciseId,
    String? matchedExerciseId,
    String? customExerciseId,
    ImportExerciseResolution? resolution,
    List<ImportedSet>? sets,
    String? notes,
    int? orderIndex,
  }) {
    return ImportedExercise(
      sourceName: sourceName ?? this.sourceName,
      exerciseId: exerciseId ?? this.exerciseId,
      matchedExerciseId: matchedExerciseId ?? this.matchedExerciseId,
      customExerciseId: customExerciseId ?? this.customExerciseId,
      resolution: resolution ?? this.resolution,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportedExercise &&
          runtimeType == other.runtimeType &&
          sourceName == other.sourceName &&
          exerciseId == other.exerciseId &&
          _sameImportedSets(sets, other.sets);

  @override
  int get hashCode => Object.hash(sourceName, exerciseId, sets);
}

/// How an imported exercise name was resolved to a GymLvl exercise.
enum ImportExerciseResolution {
  matched, // exact/alias match to an existing catalogue/custom exercise
  created, // a new user-owned custom exercise was created
  skipped, // exercise could not be resolved and was skipped
}

/// A single normalized imported workout.
class ImportedWorkout {
  const ImportedWorkout({
    required this.sourceId, // stable identity from the source (for dedup)
    required this.sourceFile, // originating file name (for audit)
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.notes,
    required this.exercises,
    this.fingerprint, // deterministic dedup fingerprint
  });

  final String sourceId;
  final String sourceFile;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final String? notes;
  final List<ImportedExercise> exercises;
  final String? fingerprint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportedWorkout &&
          runtimeType == other.runtimeType &&
          sourceId == other.sourceId &&
          fingerprint == other.fingerprint;

  @override
  int get hashCode => Object.hash(sourceId, fingerprint);
}

/// Outcome of importing a preview into the database.
class ImportResult {
  const ImportResult({
    required this.importedCount,
    this.skippedDuplicates = 0,
    this.warnings = const [],
    this.createdCustomExerciseIds = const [],
  });

  final int importedCount;
  final int skippedDuplicates;
  final List<ImportWarning> warnings;
  final List<String> createdCustomExerciseIds;
}

/// A non-blocking issue detected during parsing or validation.
class ImportWarning {
  const ImportWarning({
    required this.code,
    required this.message,
    this.row,
    this.exerciseName,
  });

  final String code; // e.g. 'unknown_exercise', 'invalid_unit', 'duplicate'
  final String message;
  final int? row; // source row number (1-based)
  final String? exerciseName;
}

/// A validation problem that blocks persistence until resolved.
class ImportValidationIssue {
  const ImportValidationIssue({
    required this.code,
    required this.message,
    this.row,
  });

  final String code;
  final String message;
  final int? row;
}

/// Result of parsing a file: normalized preview plus parse-level warnings.
class ImportPreview {
  const ImportPreview({
    required this.format,
    required this.workouts,
    required this.warnings,
    this.validationIssues = const [],
  });

  final ImportFormat format;
  final List<ImportedWorkout> workouts;
  final List<ImportWarning> warnings;
  final List<ImportValidationIssue> validationIssues;

  /// True when there are no blocking validation issues.
  bool get isValid => validationIssues.isEmpty;

  int get workoutCount => workouts.length;
}

/// Detected source format.
enum ImportFormat {
  gymLvlCsv, // GymLvl portable CSV export (workouts/workout_exercises/workout_sets)
  genericCsv, // generic per-set workout CSV (date, exercise, reps, weight, unit)
  unknown,
}
