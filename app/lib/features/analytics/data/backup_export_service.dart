/// P4 Gate 7: Portable GymLvl user-data backup export (one-way export only).
///
/// Produces a versioned JSON structure containing owner-owned fitness data
/// suitable for a future restore design. This is NOT a database-level server
/// backup and restore/import is NOT implemented in P4.
///
/// Structure:
/// {
///   "format": "gymlvl-backup",
///   "version": 1,
///   "exportedAt": "...",
///   "data": { ... }
/// }
///
/// Never includes passwords, tokens, Supabase keys, secure-storage secrets,
/// or device credentials. Only owner-scoped records are included. Output is
/// deterministic: identical input yields identical JSON (sorted keys, stable
/// field order, ISO-8601 UTC timestamps).
library;

import 'dart:convert';

import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';

/// Backup format identifier.
const String kBackupFormat = 'gymlvl-backup';

/// Backup format version. Bump this when the structure changes.
const int kBackupVersion = 1;
const int kBackupVersion2 = 2;

/// Result of a backup export.
class BackupExportResult {
  /// Deterministic JSON string (sorted keys, UTF-8).
  final String json;

  /// Parsed object (for validation/testing).
  final Map<String, dynamic> object;

  const BackupExportResult({required this.json, required this.object});

  /// The backup version embedded in the export.
  int get version => object['version'] as int;

  /// The format identifier embedded in the export.
  String get format => object['format'] as String;
}

/// Builds a portable, versioned GymLvl backup from owner-scoped data.
class BackupExportService {
  /// Version 2 includes every supported workout measurement and the text-only
  /// definitions needed to resolve owner-created exercises on restore.
  Map<String, dynamic> buildBackupV2({
    required String userId,
    required List<Workout> workouts,
    required List<WorkoutExercise> workoutExercises,
    required List<WorkoutSet> sets,
    required List<BodyMeasurement> measurements,
    required List<Exercise> customExercises,
    required String exportedAtUtc,
  }) {
    if (userId.isEmpty ||
        workouts.any((w) => w.userId != userId) ||
        measurements.any((m) => m.userId != userId) ||
        customExercises.any((e) => e.userId != userId || e.source != 'user')) {
      throw StateError('backup_owner_mismatch');
    }
    if (customExercises.any(
      (e) =>
          e.externalId != null ||
          e.sourceRevision != null ||
          e.imageUrl != null,
    )) {
      throw StateError('backup_custom_provenance_invalid');
    }
    if (customExercises.map((e) => e.id).toSet().length !=
        customExercises.length) {
      throw StateError('backup_duplicate_custom_exercise');
    }
    final workoutIds = workouts.map((w) => w.id).toSet();
    final workoutExerciseIds = workoutExercises.map((e) => e.id).toSet();
    if (workouts.any(
          (w) =>
              w.status != WorkoutStatus.completed ||
              w.startedAt == null ||
              w.completedAt == null ||
              !w.completedAt!.isAfter(w.startedAt!) ||
              w.pausedAt != null,
        ) ||
        workoutExercises.any((e) => !workoutIds.contains(e.workoutId)) ||
        sets.any((s) => !workoutExerciseIds.contains(s.workoutExerciseId)) ||
        measurements.any((m) => !m.unitIsCanonical)) {
      throw StateError('backup_data_not_restorable');
    }
    final backup = buildBackup(
      userId: userId,
      workouts: workouts,
      workoutExercises: workoutExercises,
      sets: sets,
      measurements: measurements,
      preferences: const {},
      exportedAtUtc: exportedAtUtc,
    );
    final data = backup['data'] as Map<String, dynamic>;
    data.remove('preferences');
    for (final section in [
      'workouts',
      'workout_exercises',
      'workout_sets',
      'body_measurements',
    ]) {
      for (final row in (data[section] as List).cast<Map<String, dynamic>>()) {
        row.remove('created_at');
        row.remove('updated_at');
      }
    }
    final exerciseRows = (data['workout_exercises'] as List)
        .cast<Map<String, dynamic>>();
    final customById = {
      for (final exercise in customExercises) exercise.id: exercise,
    };
    final exerciseById = {
      for (final workoutExercise in workoutExercises)
        if (workoutExercise.exercise != null)
          workoutExercise.exercise!.id: workoutExercise.exercise!,
      ...customById,
    };
    final workoutExerciseById = {
      for (final exercise in workoutExercises) exercise.id: exercise,
    };
    for (final row in exerciseRows) {
      final original = workoutExerciseById[row['workout_exercise_id']];
      final definition = exerciseById[row['exercise_id']];
      final nested = original?.exercise;
      final canonicalCustom = customById[row['exercise_id']];
      if (nested != null &&
          canonicalCustom != null &&
          (nested.imageUrl != null ||
              json.encode(_customExerciseToJson(nested)) !=
                  json.encode(_customExerciseToJson(canonicalCustom)))) {
        throw StateError('backup_custom_definition_mismatch');
      }
      if (original == null ||
          definition == null ||
          (definition.source == 'user' &&
              (definition.userId != userId ||
                  !customExercises.any((e) => e.id == definition.id)))) {
        throw StateError('backup_exercise_definition_missing');
      }
      row.addAll({
        'mode': workoutModeToJson(original.mode),
        'superset_position': original.supersetPosition,
        'superset_locked': original.supersetLocked,
        'exercise_source': definition.source,
        'exercise_external_id': definition.externalId,
        'exercise_source_revision': definition.sourceRevision,
      });
    }
    final setById = {for (final set in sets) set.id: set};
    for (final row
        in (data['workout_sets'] as List).cast<Map<String, dynamic>>()) {
      final original = setById[row['set_id']];
      if (original == null) throw StateError('backup_set_missing');
      row.addAll({
        'baseline_weight_kg': original.baselineWeightKg,
        'rpe': original.rpe,
        'rir': original.rir,
      });
    }
    final workoutById = {for (final workout in workouts) workout.id: workout};
    for (final row in (data['workouts'] as List).cast<Map<String, dynamic>>()) {
      final original = workoutById[row['workout_id']];
      if (original == null) throw StateError('backup_workout_missing');
      row.addAll({
        'training_started_at': _isoOrEmpty(original.trainingStartedAt),
        'paused_seconds': original.pausedSeconds,
      });
    }
    data['custom_exercises'] =
        customExercises.map(_customExerciseToJson).toList()
          ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    backup['version'] = kBackupVersion2;
    backup['unsupported_sections'] = const ['preferences'];
    backup['data'] = _sortedMap(data);
    return _sortedMap(backup);
  }

  String exportV2({
    required String userId,
    required List<Workout> workouts,
    required List<WorkoutExercise> workoutExercises,
    required List<WorkoutSet> sets,
    required List<BodyMeasurement> measurements,
    required List<Exercise> customExercises,
    required String exportedAtUtc,
  }) => toJson(
    buildBackupV2(
      userId: userId,
      workouts: workouts,
      workoutExercises: workoutExercises,
      sets: sets,
      measurements: measurements,
      customExercises: customExercises,
      exportedAtUtc: exportedAtUtc,
    ),
  );

  Map<String, dynamic> _customExerciseToJson(Exercise exercise) => _sortedMap({
    'id': exercise.id,
    'user_id': exercise.userId,
    'source': exercise.source,
    'name': exercise.name,
    'category': exercise.category,
    'equipment': exercise.equipment,
    'force_type': exercise.forceType,
    'mechanic': exercise.mechanic,
    'instructions': exercise.instructions,
    'slug': exercise.slug,
    'name_vi': exercise.nameVi,
    'name_en': exercise.nameEn,
    'movement_pattern': exercise.movementPattern,
    'secondary_muscles': exercise.secondaryMuscles,
    'difficulty': exercise.difficulty,
    'form_cues': exercise.formCues,
    'common_mistakes': exercise.commonMistakes,
    'alternative_exercise_slugs': exercise.alternativeExerciseSlugs,
    'is_archived': exercise.isArchived,
  });

  /// Build the backup object (deterministic, sorted keys).
  Map<String, dynamic> buildBackup({
    required String userId,
    required List<Workout> workouts,
    required List<WorkoutExercise> workoutExercises,
    required List<WorkoutSet> sets,
    required List<BodyMeasurement> measurements,
    required Map<String, dynamic> preferences,
    required String exportedAtUtc,
  }) {
    final data = <String, dynamic>{
      'user_id': userId,
      'workouts': workouts.map(_workoutToJson).toList()
        ..sort(
          (a, b) =>
              (a['workout_id'] as String).compareTo(b['workout_id'] as String),
        ),
      'workout_exercises': workoutExercises.map(_workoutExerciseToJson).toList()
        ..sort(
          (a, b) => (a['workout_exercise_id'] as String).compareTo(
            b['workout_exercise_id'] as String,
          ),
        ),
      'workout_sets': sets.map(_workoutSetToJson).toList()
        ..sort(
          (a, b) => (a['set_id'] as String).compareTo(b['set_id'] as String),
        ),
      'body_measurements': measurements.map(_bodyMeasurementToJson).toList()
        ..sort(
          (a, b) => (a['measurement_id'] as String).compareTo(
            b['measurement_id'] as String,
          ),
        ),
      'preferences': _sortedMap(preferences),
    };

    return <String, dynamic>{
      'format': kBackupFormat,
      'version': kBackupVersion,
      'exported_at': exportedAtUtc,
      'data': _sortedMap(data),
    };
  }

  /// Serialize the backup object to deterministic JSON (UTF-8, sorted keys).
  String toJson(Map<String, dynamic> backup) {
    const JsonEncoder withIndent = JsonEncoder.withIndent('  ');
    return withIndent.convert(_sortedMap(backup));
  }

  /// Convenience: build + serialize.
  String export({
    required String userId,
    required List<Workout> workouts,
    required List<WorkoutExercise> workoutExercises,
    required List<WorkoutSet> sets,
    required List<BodyMeasurement> measurements,
    required Map<String, dynamic> preferences,
    required String exportedAtUtc,
  }) {
    final backup = buildBackup(
      userId: userId,
      workouts: workouts,
      workoutExercises: workoutExercises,
      sets: sets,
      measurements: measurements,
      preferences: preferences,
      exportedAtUtc: exportedAtUtc,
    );
    return toJson(backup);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Record serialization (stable field order, no secrets)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Map<String, dynamic> _workoutToJson(Workout w) =>
      _sortedMap(<String, dynamic>{
        'workout_id': w.id,
        'user_id': w.userId,
        'status': w.status.name,
        'duration_seconds': w.durationSeconds,
        'notes': w.notes,
        'started_at': _isoOrEmpty(w.startedAt),
        'completed_at': _isoOrEmpty(w.completedAt),
        'created_at': _isoOrEmpty(w.createdAt),
        'updated_at': _isoOrEmpty(w.updatedAt),
      });

  Map<String, dynamic> _workoutExerciseToJson(WorkoutExercise we) =>
      _sortedMap(<String, dynamic>{
        'workout_exercise_id': we.id,
        'workout_id': we.workoutId,
        'exercise_id': we.exerciseId,
        'exercise_name': we.exercise?.name,
        'order_index': we.orderIndex,
        'superset_group_id': we.supersetGroupId,
        'notes': we.notes,
        'created_at': _isoOrEmpty(we.createdAt),
      });

  Map<String, dynamic> _workoutSetToJson(WorkoutSet s) =>
      _sortedMap(<String, dynamic>{
        'set_id': s.id,
        'workout_exercise_id': s.workoutExerciseId,
        'set_number': s.setNumber,
        'reps': s.reps,
        'weight_kg': s.weightKg,
        'duration_seconds': s.durationSeconds,
        'is_completed': s.isCompleted,
        'set_type': s.setType.name,
        'rest_seconds': s.restSeconds,
        'created_at': _isoOrEmpty(s.createdAt),
      });

  Map<String, dynamic> _bodyMeasurementToJson(BodyMeasurement m) =>
      _sortedMap(<String, dynamic>{
        'measurement_id': m.id,
        'user_id': m.userId,
        'measurement_type': m.type.wireValue,
        'value': m.value,
        'unit': m.unit.wireValue,
        'measured_at': _isoOrEmpty(m.measuredAt),
        'notes': m.notes,
        'created_at': _isoOrEmpty(m.createdAt),
      });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Deterministic helpers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Serialize [DateTime] as ISO-8601 UTC, or null.
  static String? _isoOrEmpty(DateTime? value) =>
      value?.toUtc().toIso8601String();

  /// Return a map with keys sorted (recursively) for deterministic JSON.
  static Map<String, dynamic> _sortedMap(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    for (final key in input.keys.toList()..sort()) {
      result[key] = _sortedValue(input[key]);
    }
    return result;
  }

  static dynamic _sortedValue(dynamic value) {
    if (value is Map) {
      return _sortedMap(value.cast<String, dynamic>());
    }
    if (value is List) {
      return value.map(_sortedValue).toList();
    }
    return value;
  }
}
