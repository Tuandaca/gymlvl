// P4 Gate 6: CSV data export service.
///
/// Produces RFC 4180-compatible CSV (UTF-8) from owner-scoped domain data.
/// The service is pure Dart: it receives already owner-filtered data and
/// never reads credentials, tokens, or another user's data. Output is
/// deterministic for identical input (stable column order, stable escaping,
/// no timestamps beyond the source data).
///
/// Column formats are stable across versions so the export is usable outside
/// GymLvl. Dates/times are serialized as ISO-8601 UTC strings.
library;

import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';

/// Escape a single CSV field per RFC 4180.
///
/// Fields containing a comma, double quote, or line break are enclosed in
/// double quotes; embedded double quotes are doubled. All other fields are
/// emitted verbatim.
String _escapeCsvField(String? value) {
  final field = value ?? '';
  final needsQuoting =
      field.contains(',') ||
      field.contains('"') ||
      field.contains('\n') ||
      field.contains('\r');
  if (!needsQuoting) return field;
  return '"${field.replaceAll('"', '""')}"';
}

/// Serialize a [DateTime] as ISO-8601 UTC, or empty string when null.
String _isoOrEmpty(DateTime? value) =>
    value == null ? '' : value.toUtc().toIso8601String();

/// Serialize a double, trimming trailing zeros for clean output.
String _num(double value) => value.toStringAsFixed(2);

/// The result of a CSV export: one file name per table plus its CSV content.
class CsvExportResult {
  final Map<String, String> files; // file name (without .csv) -> CSV content
  final String exportedAtUtc;

  const CsvExportResult({required this.files, required this.exportedAtUtc});

  /// All tables concatenated into a single CSV stream with table header
  /// comments (useful for a single-file export).
  String toSingleStream() {
    final buffer = StringBuffer();
    buffer.writeln('# GymLvl CSV export');
    buffer.writeln('# Exported at (UTC): $exportedAtUtc');
    buffer.writeln('# Owner data only. UTF-8. RFC 4180.');
    buffer.writeln();
    for (final entry in files.entries) {
      buffer.writeln('# --- ${entry.key} ---');
      buffer.write(entry.value);
      if (!entry.value.endsWith('\n')) buffer.writeln();
      buffer.writeln();
    }
    return buffer.toString();
  }
}

/// CSV export for GymLvl owner fitness data.
class CsvExportService {
  /// Export completed workouts to CSV.
  ///
  /// Columns: workout_id,user_id,status,duration_seconds,notes,started_at,
  /// completed_at,created_at,updated_at
  String exportWorkouts(List<Workout> workouts) {
    final lines = <String>[];
    lines.add(
      'workout_id,user_id,status,duration_seconds,notes,started_at,completed_at,created_at,updated_at',
    );
    for (final w in workouts) {
      lines.add(
        _csv([
          w.id,
          w.userId,
          w.status.name,
          w.durationSeconds.toString(),
          w.notes,
          _isoOrEmpty(w.startedAt),
          _isoOrEmpty(w.completedAt),
          _isoOrEmpty(w.createdAt),
          _isoOrEmpty(w.updatedAt),
        ]),
      );
    }
    return '${lines.join('\n')}\n';
  }

  /// Export workout exercises to CSV.
  ///
  /// Columns: workout_exercise_id,workout_id,exercise_id,exercise_name,
  /// order_index,superset_group_id,notes,created_at
  String exportWorkoutExercises(List<WorkoutExercise> workoutExercises) {
    final lines = <String>[];
    lines.add(
      'workout_exercise_id,workout_id,exercise_id,exercise_name,order_index,superset_group_id,notes,created_at',
    );
    for (final we in workoutExercises) {
      lines.add(
        _csv([
          we.id,
          we.workoutId,
          we.exerciseId,
          we.exercise?.name,
          we.orderIndex.toString(),
          we.supersetGroupId,
          we.notes,
          _isoOrEmpty(we.createdAt),
        ]),
      );
    }
    return '${lines.join('\n')}\n';
  }

  /// Export workout sets to CSV.
  ///
  /// Columns: set_id,workout_exercise_id,set_number,reps,weight_kg,
  /// duration_seconds,is_completed,set_type,rest_seconds,created_at
  String exportWorkoutSets(List<WorkoutSet> sets) {
    final lines = <String>[];
    lines.add(
      'set_id,workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed,set_type,rest_seconds,created_at',
    );
    for (final s in sets) {
      lines.add(
        _csv([
          s.id,
          s.workoutExerciseId,
          s.setNumber.toString(),
          s.reps.toString(),
          _num(s.weightKg),
          s.durationSeconds.toString(),
          s.isCompleted.toString(),
          s.setType.name,
          s.restSeconds.toString(),
          _isoOrEmpty(s.createdAt),
        ]),
      );
    }
    return '${lines.join('\n')}\n';
  }

  /// Export body measurements to CSV.
  ///
  /// Columns: measurement_id,user_id,measurement_type,value,unit,measured_at,
  /// notes,created_at
  String exportBodyMeasurements(List<BodyMeasurement> measurements) {
    final lines = <String>[];
    lines.add(
      'measurement_id,user_id,measurement_type,value,unit,measured_at,notes,created_at',
    );
    for (final m in measurements) {
      lines.add(
        _csv([
          m.id,
          m.userId,
          m.type.wireValue,
          _num(m.value),
          m.unit.wireValue,
          _isoOrEmpty(m.measuredAt),
          m.notes,
          _isoOrEmpty(m.createdAt),
        ]),
      );
    }
    return '${lines.join('\n')}\n';
  }

  /// Export all supported owner tables to a [CsvExportResult].
  ///
  /// [exportedAtUtc] is the export timestamp (UTC) stamped on the result.
  CsvExportResult exportAll({
    required List<Workout> workouts,
    required List<WorkoutExercise> workoutExercises,
    required List<WorkoutSet> sets,
    required List<BodyMeasurement> measurements,
    required String exportedAtUtc,
  }) {
    return CsvExportResult(
      files: <String, String>{
        'workouts': exportWorkouts(workouts),
        'workout_exercises': exportWorkoutExercises(workoutExercises),
        'workout_sets': exportWorkoutSets(sets),
        'body_measurements': exportBodyMeasurements(measurements),
      },
      exportedAtUtc: exportedAtUtc,
    );
  }

  /// Escape and join a row of raw values into a single CSV line.
  ///
  /// Each field is escaped per RFC 4180; nulls become empty fields.
  String _csv(List<Object?> fields) =>
      fields.map((f) => _escapeCsvField(f?.toString())).join(',');
}
