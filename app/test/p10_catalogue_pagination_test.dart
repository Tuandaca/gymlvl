import 'dart:convert';

import 'package:app/features/workout/data/supabase_exercise_repository.dart';
import 'package:flutter_test/flutter_test.dart';
// Existing Supabase HTTP transport dependency; no new package is introduced.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  for (final total in [0, 1000, 1474, 2000]) {
    test(
      'catalogue fetch returns all $total rows through bounded pages',
      () async {
        final offsets = <int>[];
        final orders = <String?>[];
        final client = SupabaseClient(
          'https://p10.invalid',
          'synthetic-public-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
          httpClient: MockClient((request) async {
            final params = request.url.queryParameters;
            final offset = int.parse(params['offset'] ?? '0');
            final limit = int.parse(params['limit'] ?? '1000');
            expect(limit, lessThanOrEqualTo(1000));
            offsets.add(offset);
            orders.add(params['order']);
            final end = (offset + limit).clamp(0, total);
            return http.Response(
              jsonEncode([
                for (var i = offset; i < end; i++)
                  {
                    'id': 'exercise-$i',
                    'name': 'Same name',
                    'name_en': 'Imported lift $i',
                    'name_vi': '',
                    'category': 'Arms',
                    'equipment': 'Dumbbell',
                  },
              ]),
              200,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        addTearDown(client.dispose);
        final exercises = await SupabaseExerciseRepository(
          client,
        ).getExercises();
        expect(exercises.length, total);
        expect(
          exercises.map((exercise) => exercise.id).toSet(),
          hasLength(total),
        );
        expect(offsets, [for (var i = 0; i <= total ~/ 1000; i++) i * 1000]);
        expect(orders, everyElement('name.asc.nullslast,id.asc.nullslast'));
        if (exercises.isNotEmpty) {
          expect(
            exercises.last.localizedName('vi'),
            'Imported lift ${total - 1}',
          );
          expect(
            exercises.last.localizedName('en'),
            'Imported lift ${total - 1}',
          );
        }
      },
    );
  }
}
