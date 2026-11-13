import 'dart:convert';

import 'package:app/features/ai_trainer/presentation/providers/pt_recommendation_provider.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/coach/data/coach_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Existing Supabase HTTP transport dependency, used only for synthetic requests.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test(
    'explicit chat send carries consent without a client workout context',
    () async {
      http.Request? sent;
      final client = SupabaseClient(
        'https://p9.invalid',
        'synthetic-public-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode({'answer': 'Rest today.'}),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);

      final result = await SupabaseCoachRepository(client).ask(
        'How should I recover?',
        [const CoachMessage('user', 'I trained yesterday.')],
      );
      expect(result, 'Rest today.');
      expect(sent?.url.path, '/functions/v1/ai-coach');
      final body = jsonDecode(sent!.body) as Map<String, dynamic>;
      expect(body['consent'], isTrue);
      expect(body['message'], 'How should I recover?');
      expect(body.containsKey('context'), isFalse);
      expect(body.containsKey('user_id'), isFalse);
    },
  );

  test('PT request omits account UUID and synthetic client context', () async {
    const ownerId = 'a9000000-0000-4000-8000-000000000051';
    http.Request? sent;
    final client = SupabaseClient(
      'https://p9.invalid',
      'synthetic-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({'answer': 'Train conservatively.', 'generated': true}),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);
    final authState = AuthState(
      AuthChangeEvent.signedIn,
      Session(
        accessToken: 'synthetic-token',
        tokenType: 'bearer',
        user: User(
          id: ownerId,
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: '2026-11-13T00:00:00Z',
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWithValue(AsyncValue.data(authState)),
        ptCoachClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);

    final advice = await container.read(ptRecommendationProvider.future);
    expect(advice.summary, 'Train conservatively.');
    expect(advice.isValidated, isFalse);
    expect(advice.hasActionable, isFalse);
    expect(advice.confidence, 0);
    final body = jsonDecode(sent!.body) as Map<String, dynamic>;
    expect(body['consent'], isTrue);
    expect(body.containsKey('context'), isFalse);
    expect(jsonEncode(body).contains(ownerId), isFalse);
    expect(body['message'], contains('Respond in Vietnamese.'));
  });

  test(
    'first PT request honors stored English before locale restore',
    () async {
      SharedPreferences.setMockInitialValues({'lang_mode': 'en'});
      http.Request? sent;
      final client = SupabaseClient(
        'https://p9.invalid',
        'synthetic-public-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode({'answer': 'Train conservatively.'}),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final authState = AuthState(
        AuthChangeEvent.signedIn,
        Session(
          accessToken: 'synthetic-token',
          tokenType: 'bearer',
          user: User(
            id: 'a9000000-0000-4000-8000-000000000052',
            appMetadata: const {},
            userMetadata: const {},
            aud: 'authenticated',
            createdAt: '2026-11-13T00:00:00Z',
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWithValue(AsyncValue.data(authState)),
          ptCoachClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      await container.read(ptRecommendationProvider.future);
      final body = jsonDecode(sent!.body) as Map<String, dynamic>;
      expect(body['message'], contains('Respond in English.'));
    },
  );
}
