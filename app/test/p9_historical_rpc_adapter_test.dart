import 'dart:convert';

import 'package:app/features/workout/data/supabase_workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';
// Existing Supabase HTTP transport dependency, used only for synthetic requests.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'historical import adapter sends exact RPC bodies and decodes receipts',
    () async {
      final requests = <http.Request>[];
      final responses = <String, Map<String, dynamic>>{
        'import_historical_workout_v1': {
          'workoutId': '96000000-0000-4000-8000-000000000011',
          'alreadyImported': false,
          'createdCustomExerciseIds': ['96000000-0000-4000-8000-000000000012'],
        },
        'import_historical_measurement_v1': {
          'measurementId': '96000000-0000-4000-8000-000000000013',
          'alreadyImported': true,
        },
        'import_custom_exercise_v1': {
          'exerciseId': '96000000-0000-4000-8000-000000000014',
          'alreadyImported': false,
          'created': false,
        },
      };
      final client = SupabaseClient(
        'https://p9.invalid',
        'synthetic-public-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          requests.add(request);
          final name = request.url.pathSegments.last;
          final receipt = responses[name];
          if (receipt == null) throw StateError('Unexpected RPC $name');
          return http.Response(
            jsonEncode(receipt),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final session = Session(
        accessToken: 'synthetic-token',
        tokenType: 'bearer',
        user: User(
          id: '96000000-0000-4000-8000-000000000001',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: '2026-11-10T00:00:00Z',
        ),
      );
      await client.auth.setInitialSession(jsonEncode(session.toJson()));
      final repository = SupabaseWorkoutRepository(client);
      final workoutPayload = <String, dynamic>{
        'started_at': '2026-11-01T10:00:00Z',
        'exercises': [
          {
            'custom_exercise': {'id': '96000000-0000-4000-8000-000000000012'},
          },
        ],
      };
      final measurementPayload = <String, dynamic>{
        'measurement_type': 'body_weight',
        'value': 70,
        'unit': 'kg',
      };
      final customPayload = <String, dynamic>{
        'id': '96000000-0000-4000-8000-000000000014',
        'name': 'Owner Lift',
      };

      final workout = await repository.importHistoricalWorkout(
        importKey: 'workout-key',
        payload: workoutPayload,
      );
      final measurement = await repository.importHistoricalMeasurement(
        importKey: 'measurement-key',
        payload: measurementPayload,
      );
      final custom = await repository.importCustomExercise(
        importKey: 'custom-key',
        payload: customPayload,
      );

      expect(
        workout.workoutId,
        responses['import_historical_workout_v1']!['workoutId'],
      );
      expect(workout.alreadyImported, isFalse);
      expect(workout.createdCustomExerciseIds, [
        '96000000-0000-4000-8000-000000000012',
      ]);
      expect(
        measurement.measurementId,
        responses['import_historical_measurement_v1']!['measurementId'],
      );
      expect(measurement.alreadyImported, isTrue);
      expect(
        custom.exerciseId,
        responses['import_custom_exercise_v1']!['exerciseId'],
      );
      expect(custom.alreadyImported, isFalse);
      expect(custom.created, isFalse);
      expect(requests, hasLength(3));
      for (var index = 0; index < requests.length; index++) {
        final name = responses.keys.elementAt(index);
        expect(requests[index].method, 'POST');
        expect(requests[index].url.path, endsWith('/rest/v1/rpc/$name'));
        final body = jsonDecode(requests[index].body) as Map<String, dynamic>;
        expect(body.keys, unorderedEquals(['p_import_key', 'p_payload']));
        expect(
          body['p_import_key'],
          ['workout-key', 'measurement-key', 'custom-key'][index],
        );
        expect(
          body['p_payload'],
          [workoutPayload, measurementPayload, customPayload][index],
        );
        expect(body['p_payload'], isNot(contains('user_id')));
      }
    },
  );
}
