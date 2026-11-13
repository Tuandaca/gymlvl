import 'dart:convert';

import 'package:app/features/bodyweight/data/supabase_body_measurement_repository.dart';
import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:flutter_test/flutter_test.dart';
// Existing Supabase HTTP transport dependency, used for a local request boundary.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _ownerId = '92000000-0000-4000-8000-000000000011';

BodyMeasurement _bodyFat(BodyMeasurementUnit unit) => BodyMeasurement(
  id: '92000000-0000-4000-8000-000000000021',
  userId: _ownerId,
  type: BodyMeasurementType.bodyFatPercentage,
  value: 18.5,
  unit: unit,
  measuredAt: DateTime.utc(2026, 11, 1, 7, 30),
);

void main() {
  test('body fat percentage uses percent and repository accepts it', () async {
    Map<String, dynamic>? inserted;
    final client = SupabaseClient(
      'https://p9.invalid',
      'synthetic-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, endsWith('/rest/v1/body_measurements'));
        inserted = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            ...inserted!,
            'id': _bodyFat(BodyMeasurementUnit.percent).id,
          }),
          201,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);

    expect(BodyMeasurementType.bodyFatPercentage.canonicalUnit, 'percent');
    expect(_bodyFat(BodyMeasurementUnit.percent).unitIsCanonical, isTrue);
    final result = await SupabaseBodyMeasurementRepository(
      client,
    ).insert(_bodyFat(BodyMeasurementUnit.percent));
    expect(result.unit, BodyMeasurementUnit.percent);
    expect(inserted?['unit'], 'percent');
  });

  test(
    'repository rejects kg for body fat percentage before network',
    () async {
      var writes = 0;
      final client = SupabaseClient(
        'https://p9.invalid',
        'synthetic-public-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          writes++;
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({...payload, 'id': _bodyFat(BodyMeasurementUnit.kg).id}),
            201,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);

      await expectLater(
        SupabaseBodyMeasurementRepository(
          client,
        ).insert(_bodyFat(BodyMeasurementUnit.kg)),
        throwsArgumentError,
      );
      expect(writes, 0);
    },
  );
}
