import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/analytics/data/csv_export_service.dart';
import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_set.dart';

void main() {
  final service = CsvExportService();

  group('CsvExportService', () {
    test('header stability and column order', () {
      final workouts = [
        Workout(
          id: 'w1',
          userId: 'u1',
          status: WorkoutStatus.completed,
          durationSeconds: 1200,
          completedAt: DateTime.utc(2026, 10, 1, 10, 0),
          createdAt: DateTime.utc(2026, 10, 1, 9, 0),
        ),
      ];
      final csv = service.exportWorkouts(workouts);
      final lines = csv.split('\n');
      expect(
        lines.first,
        'workout_id,user_id,status,duration_seconds,notes,started_at,completed_at,created_at,updated_at',
      );
      expect(lines.last.isEmpty, true); // trailing newline
    });

    test('UTF-8 content and escaping comma/quote/newline', () {
      final workouts = [
        Workout(
          id: 'w1',
          userId: 'u1',
          status: WorkoutStatus.completed,
          notes: 'Tập, "có" nhảy\nmới', // comma, quote, newline, Vietnamese
          completedAt: DateTime.utc(2026, 10, 1, 10, 0),
        ),
      ];
      final csv = service.exportWorkouts(workouts);
      // UTF-8 encodable
      expect(utf8.encode(csv).isNotEmpty, true);
      // Quoted field: embedded quotes doubled, comma/newline inside quotes
      expect(csv, contains('"Tập, ""có"" nhảy\nmới"'));
    });

    test('owner-only records — exports exactly what is given', () {
      final workouts = [
        Workout(id: 'w1', userId: 'owner_a', status: WorkoutStatus.completed),
        Workout(id: 'w2', userId: 'owner_b', status: WorkoutStatus.completed),
      ];
      // Service is pure: it exports the rows passed in. The caller (provider)
      // filters by owner before calling.
      final csv = service.exportWorkouts(workouts);
      expect(csv, contains('owner_a'));
      expect(csv, contains('owner_b'));
      expect(csv.split('\n').length, 4); // header + 2 rows + trailing newline
    });

    test('sets export includes set_type and weight', () {
      final sets = [
        WorkoutSet(
          id: 's1',
          workoutExerciseId: 'we1',
          setNumber: 1,
          reps: 10,
          weightKg: 50.5,
          isCompleted: true,
          setType: WorkoutSetType.workout,
        ),
      ];
      final csv = service.exportWorkoutSets(sets);
      expect(csv, contains('50.50'));
      expect(csv, contains('workout'));
    });

    test('measurements export with units', () {
      final measurements = [
        BodyMeasurement(
          id: 'm1',
          userId: 'u1',
          type: BodyMeasurementType.chest,
          value: 95.0,
          unit: BodyMeasurementUnit.cm,
          measuredAt: DateTime.utc(2026, 10, 1),
        ),
      ];
      final csv = service.exportBodyMeasurements(measurements);
      expect(csv, contains('chest'));
      expect(csv, contains('95.00'));
      expect(csv, contains('cm'));
    });

    test('exportAll produces stable top-level files', () {
      final result = service.exportAll(
        workouts: const [],
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      expect(
        result.files.keys.toSet(),
        equals(<String>{
          'workouts',
          'workout_exercises',
          'workout_sets',
          'body_measurements',
        }),
      );
      // Deterministic: same input -> same output
      final result2 = service.exportAll(
        workouts: const [],
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      expect(result.toSingleStream(), equals(result2.toSingleStream()));
    });
  });
}
