import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/quests/domain/quest_instance.dart';
import 'package:app/features/quests/presentation/widgets/daily_quest_card.dart';
import 'package:app/ui/candy/candy_quest_card.dart';
import 'package:app/ui/candy/candy_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _EnglishLanguage extends LocalizationModeNotifier {
  @override
  AppLangMode build() => AppLangMode.en;
}

Widget _app(Widget home) => ProviderScope(
  overrides: [localizationModeProvider.overrideWith(_EnglishLanguage.new)],
  child: MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: home)),
  ),
);

QuestInstance _quest({String status = 'active', int? earnedXp}) =>
    QuestInstance(
      id: 'quest-1',
      userId: 'user-1',
      questId: 'daily',
      status: status,
      expiresAt: DateTime.now().add(const Duration(hours: 6)),
      earnedXp: earnedXp,
      config: const [
        PrescribedExercise(
          exerciseId: 'squat',
          exerciseName: 'Bodyweight Squat',
          sets: 3,
          reps: 12,
          weightKg: 0,
        ),
      ],
    );

void main() {
  testWidgets('an active quest with unknown reward shows no invented XP', (
    tester,
  ) async {
    await tester.pumpWidget(_app(DailyQuestCard(quest: _quest())));
    await tester.pumpAndSettle();

    expect(find.textContaining('350 XP'), findsNothing);
    expect(find.textContaining('100 XP'), findsNothing);
    expect(find.text('35%'), findsNothing);
    expect(find.byType(CandyProgressBar), findsNothing);
    expect(find.text('1 EXERCISES'), findsOneWidget);
  });

  testWidgets('a completed quest without a reward omits the amount', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(DailyQuestCard(quest: _quest(status: 'completed'))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('350 XP'), findsNothing);
    expect(find.text('ĐÃ NHẬN +350 XP'), findsNothing);
    expect(find.text('COMPLETED'), findsWidgets);
  });

  testWidgets('unknown quest progress is rendered as unknown, not zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const CandyQuestCard(
          title: 'Daily Quest',
          description: 'Squat',
          currentProgress: null,
          targetProgress: 3,
          xpReward: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('- / 3'), findsOneWidget);
    expect(find.text('0 / 3'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.byType(CandyProgressBar), findsNothing);
  });
}
