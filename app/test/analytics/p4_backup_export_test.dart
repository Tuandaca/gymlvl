import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/analytics/data/backup_export_service.dart';
import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_set.dart';

void main() {
  final service = BackupExportService();

  group('BackupExportService', () {
    test('stable top-level schema with version present', () {
      final json = service.export(
        userId: 'owner_a',
        workouts: const [],
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        preferences: const {},
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      final object = jsonDecode(json) as Map<String, dynamic>;
      expect(object['format'], 'gymlvl-backup');
      expect(object['version'], 1);
      expect(object['exported_at'], '2026-11-05T00:00:00.000Z');
      expect(object['data'], isA<Map<String, dynamic>>());
      final data = object['data'] as Map<String, dynamic>;
      expect(data.keys, contains('workouts'));
      expect(data.keys, contains('workout_exercises'));
      expect(data.keys, contains('workout_sets'));
      expect(data.keys, contains('body_measurements'));
      expect(data.keys, contains('preferences'));
    });

    test('deterministic serialization', () {
      final workouts = [
        Workout(
          id: 'w2',
          userId: 'u1',
          status: WorkoutStatus.completed,
          durationSeconds: 600,
          completedAt: DateTime.utc(2026, 10, 2),
          createdAt: DateTime.utc(2026, 10, 2),
        ),
        Workout(
          id: 'w1',
          userId: 'u1',
          status: WorkoutStatus.completed,
          durationSeconds: 1200,
          completedAt: DateTime.utc(2026, 10, 1),
          createdAt: DateTime.utc(2026, 10, 1),
        ),
      ];
      final a = service.export(
        userId: 'u1',
        workouts: workouts,
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        preferences: const {},
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      final b = service.export(
        userId: 'u1',
        workouts: workouts,
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        preferences: const {},
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      expect(a, equals(b));
      // Records sorted by id: w1 before w2 despite input order w2,w1.
      final object = jsonDecode(a) as Map<String, dynamic>;
      final ids = (object['data']['workouts'] as List)
          .map((e) => e['workout_id'] as String)
          .toList();
      expect(ids, equals(['w1', 'w2']));
    });

    test('owner-only records — user_id stamped, no other users', () {
      final json = service.export(
        userId: 'owner_x',
        workouts: const [
          Workout(id: 'w1', userId: 'owner_x', status: WorkoutStatus.completed),
        ],
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        preferences: const {},
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      final object = jsonDecode(json) as Map<String, dynamic>;
      expect(object['data']['user_id'], 'owner_x');
      expect(json, isNot(contains('owner_y')));
    });

    test('no secrets — no passwords, tokens, keys, or credentials', () {
      final json = service.export(
        userId: 'u1',
        workouts: const [],
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        preferences: const {'locale': 'vi', 'theme': 'light'},
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      final lower = json.toLowerCase();
      expect(lower, isNot(contains('password')));
      expect(lower, isNot(contains('token')));
      expect(lower, isNot(contains('secret')));
      expect(lower, isNot(contains('service_role')));
      expect(lower, isNot(contains('api_key')));
      expect(lower, isNot(contains('credential')));
    });

    test('measurements and sets included with values', () {
      final json = service.export(
        userId: 'u1',
        workouts: const [],
        workoutExercises: const [],
        sets: [
          WorkoutSet(
            id: 's1',
            workoutExerciseId: 'we1',
            setNumber: 1,
            reps: 8,
            weightKg: 60.0,
            isCompleted: true,
            setType: WorkoutSetType.workout,
          ),
        ],
        measurements: [
          BodyMeasurement(
            id: 'm1',
            userId: 'u1',
            type: BodyMeasurementType.bodyWeight,
            value: 72.5,
            unit: BodyMeasurementUnit.kg,
            measuredAt: DateTime.utc(2026, 10, 1),
          ),
        ],
        preferences: const {},
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      expect(json, contains('"set_id": "s1"'));
      expect(json, contains('"measurement_id": "m1"'));
      expect(json, contains('body_weight'));
    });

    test('version and format accessible via BackupExportResult', () {
      final object = service.buildBackup(
        userId: 'u1',
        workouts: const [],
        workoutExercises: const [],
        sets: const [],
        measurements: const [],
        preferences: const {},
        exportedAtUtc: '2026-11-05T00:00:00.000Z',
      );
      final result = BackupExportResult(
        json: service.toJson(object),
        object: object,
      );
      expect(result.version, 1);
      expect(result.format, 'gymlvl-backup');
    });
  });
}
