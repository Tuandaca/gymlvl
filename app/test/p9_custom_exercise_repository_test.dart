import 'dart:convert';

import 'package:app/features/workout/data/supabase_exercise_repository.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:flutter_test/flutter_test.dart';
// Existing Supabase HTTP transport dependency, used for a local request boundary.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('custom exercise creation leaves timestamps to the database', () async {
    Map<String, dynamic>? inserted;
    final client = SupabaseClient(
      'https://p9.invalid',
      'synthetic-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, endsWith('/rest/v1/exercises'));
        inserted = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            ...inserted!,
            'created_at': '2026-11-10T00:00:00Z',
            'updated_at': '2026-11-10T00:00:00Z',
          }),
          201,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);

    await SupabaseExerciseRepository(client).createCustomExercise(
      const Exercise(
        id: '90000000-0000-4000-8000-000000000031',
        name: 'P9 custom lift',
        category: 'Arms',
        equipment: 'Dumbbell',
        source: 'user',
        userId: '90000000-0000-4000-8000-000000000001',
      ),
    );

    expect(inserted, isNotNull);
    expect(inserted!.containsKey('created_at'), isFalse);
    expect(inserted!.containsKey('updated_at'), isFalse);
  });

  test('custom exercise update leaves timestamps to the database', () async {
    Map<String, dynamic>? updated;
    final client = SupabaseClient(
      'https://p9.invalid',
      'synthetic-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, endsWith('/rest/v1/exercises'));
        updated = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            ...updated!,
            'created_at': '2026-11-10T00:00:00Z',
            'updated_at': '2026-11-10T01:00:00Z',
          }),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);

    await SupabaseExerciseRepository(client).updateCustomExercise(
      const Exercise(
        id: '90000000-0000-4000-8000-000000000031',
        name: 'P9 renamed lift',
        category: 'Arms',
        equipment: 'Dumbbell',
        source: 'user',
        userId: '90000000-0000-4000-8000-000000000001',
      ),
    );

    expect(updated, isNotNull);
    expect(updated!.containsKey('created_at'), isFalse);
    expect(updated!.containsKey('updated_at'), isFalse);
  });
}
