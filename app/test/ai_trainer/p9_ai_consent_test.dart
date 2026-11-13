import 'dart:async';

import 'package:app/features/ai_trainer/domain/models/pt_recommendation.dart';
import 'package:app/features/ai_trainer/presentation/providers/pt_recommendation_provider.dart';
import 'package:app/features/ai_trainer/presentation/screens/ai_trainer_screen.dart';
import 'package:app/features/ai_trainer/presentation/screens/ask_coach_screen.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/core/localization/localization_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

AuthState _signedIn(String userId) => AuthState(
  AuthChangeEvent.signedIn,
  Session(
    accessToken: 'synthetic-token',
    tokenType: 'bearer',
    user: User(
      id: userId,
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-11-13T00:00:00Z',
    ),
  ),
);

class _EnglishMode extends LocalizationModeNotifier {
  @override
  AppLangMode build() => AppLangMode.en;
}

void main() {
  for (final screen in <Widget>[
    const AiTrainerScreen(),
    const AskCoachScreen(),
  ]) {
    testWidgets('${screen.runtimeType} waits for Generate before AI request', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateStreamProvider.overrideWithValue(
              AsyncValue.data(_signedIn('owner-a')),
            ),
            ptRecommendationProvider.overrideWith((ref) async {
              calls++;
              return const PtRecommendation(
                summary: 'Advisory text only',
                reasoning: [],
                recommendations: [],
                confidence: 0,
                isValidated: false,
              );
            }),
          ],
          child: MaterialApp(home: screen),
        ),
      );
      await tester.pumpAndSettle();

      expect(calls, 0);
      expect(
        find.textContaining(RegExp('dịch vụ AI|AI service')),
        findsWidgets,
      );
      expect(find.textContaining('môi trường tập'), findsWidgets);
      expect(find.textContaining('mức tạ'), findsWidgets);
      final generate = find.textContaining(RegExp('TẠO GỢI Ý|GENERATE ADVICE'));
      expect(generate, findsOneWidget);
      await tester.ensureVisible(generate);
      await tester.tap(generate);
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(find.text('Advisory text only'), findsOneWidget);
      expect(find.text('APPLY TO ROUTINE'), findsNothing);
      expect(
        find.textContaining(RegExp('ĐỘ TIN CẬY|CONFIDENCE')),
        findsNothing,
      );
    });
    testWidgets('${screen.runtimeType} English disclosure names shared facts', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localizationModeProvider.overrideWith(_EnglishMode.new),
            authStateStreamProvider.overrideWithValue(
              AsyncValue.data(_signedIn('owner-a')),
            ),
          ],
          child: MaterialApp(home: screen),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('training environment'), findsWidgets);
      expect(
        find.textContaining('completed-set reps and weights'),
        findsWidgets,
      );
    });
    testWidgets('${screen.runtimeType} hides backend details on AI failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateStreamProvider.overrideWithValue(
              AsyncValue.data(_signedIn('owner-a')),
            ),
            ptRecommendationProvider.overrideWith((ref) async {
              throw StateError('private provider path and token');
            }),
          ],
          child: MaterialApp(home: screen),
        ),
      );
      final generate = find.textContaining(RegExp('TẠO GỢI Ý|GENERATE ADVICE'));
      await tester.ensureVisible(generate);
      await tester.tap(generate);
      await tester.pumpAndSettle();
      expect(find.textContaining('private provider path'), findsNothing);
      expect(
        find.textContaining(RegExp('chưa phản hồi|unavailable')),
        findsWidgets,
      );
    });
  }

  testWidgets('account switch requires new AI consent before another request', (
    tester,
  ) async {
    final authEvents = StreamController<AuthState>.broadcast();
    addTearDown(authEvents.close);
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateStreamProvider.overrideWith((ref) => authEvents.stream),
          ptRecommendationProvider.overrideWith((ref) async {
            calls++;
            return const PtRecommendation(
              summary: 'Advisory text only',
              reasoning: [],
              recommendations: [],
              confidence: 0,
              isValidated: false,
            );
          }),
        ],
        child: const MaterialApp(home: AiTrainerScreen()),
      ),
    );
    authEvents.add(_signedIn('owner-a'));
    await tester.pumpAndSettle();
    final generate = find.textContaining(RegExp('TẠO GỢI Ý|GENERATE ADVICE'));
    await tester.ensureVisible(generate);
    await tester.tap(generate);
    await tester.pumpAndSettle();
    expect(calls, 1);

    authEvents.add(_signedIn('owner-b'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(generate, findsOneWidget);
  });
}
