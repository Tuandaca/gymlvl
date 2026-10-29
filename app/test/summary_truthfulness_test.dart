import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/presentation/screens/workout_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _EnglishLanguage extends LocalizationModeNotifier {
  @override
  AppLangMode build() => AppLangMode.en;
}

Workout _completedWorkout() => Workout(
  id: 'workout-1',
  userId: 'user-1',
  status: WorkoutStatus.completed,
  startedAt: DateTime(2026, 10, 29),
);

Widget _app(Widget home) => ProviderScope(
  overrides: [localizationModeProvider.overrideWith(_EnglishLanguage.new)],
  child: MaterialApp(home: home),
);

void main() {
  test('summary context requires a real workout', () {
    final workout = _completedWorkout();
    expect(hasWorkoutSummaryContext(null), isFalse);
    expect(hasWorkoutSummaryContext('unexpected'), isFalse);
    expect(hasWorkoutSummaryContext(<String, dynamic>{}), isFalse);
    expect(
      hasWorkoutSummaryContext(<String, dynamic>{
        'xpResult': <String, dynamic>{},
      }),
      isFalse,
    );
    expect(
      hasWorkoutSummaryContext(<String, dynamic>{'workout': workout}),
      isTrue,
    );
    expect(hasWorkoutSummaryContext(workout), isTrue);
  });

  testWidgets('missing receipt does not fabricate XP or level progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        WorkoutSummaryScreen(
          workout: _completedWorkout(),
          totalVolumeKg: 0,
          durationSeconds: 65,
          completedSetsCount: 0,
          totalSetsCount: 0,
        ),
      ),
    );

    expect(find.text('Workout Complete!'), findsOneWidget);
    expect(find.text('+500 XP'), findsNothing);
    expect(find.textContaining('+500'), findsNothing);
    expect(find.text('LVL 1'), findsNothing);
  });

  testWidgets('an acknowledged zero reward is shown as zero, not invented', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        WorkoutSummaryScreen(
          workout: _completedWorkout(),
          xpResult: const {
            'earnedXP': 0,
            'totalXP': 100,
            'newLevel': 2,
            'leveledUp': true,
            'nextLevelXp': 500,
          },
          totalVolumeKg: 0,
          durationSeconds: 65,
          completedSetsCount: 0,
          totalSetsCount: 0,
        ),
      ),
    );

    expect(find.text('+0 XP'), findsOneWidget);
    expect(find.text('LVL 2'), findsOneWidget);
    expect(find.text('LEVEL UP!'), findsOneWidget);
  });

  testWidgets('a real receipt keeps its awarded values', (tester) async {
    await tester.pumpWidget(
      _app(
        WorkoutSummaryScreen(
          workout: _completedWorkout(),
          xpResult: const {
            'earnedXP': 350,
            'totalXP': 2500,
            'newLevel': 6,
            'leveledUp': false,
            'nextLevelXp': 1500,
          },
          totalVolumeKg: 0,
          durationSeconds: 65,
          completedSetsCount: 0,
          totalSetsCount: 0,
        ),
      ),
    );

    expect(find.text('+350 XP'), findsOneWidget);
    expect(find.text('LVL 6'), findsOneWidget);
  });

  testWidgets('a receipt without progression data shows no invented level', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        WorkoutSummaryScreen(
          workout: _completedWorkout(),
          xpResult: const {'earnedXP': 40},
          totalVolumeKg: 0,
          durationSeconds: 65,
          completedSetsCount: 0,
          totalSetsCount: 0,
        ),
      ),
    );

    expect(find.text('+40 XP'), findsOneWidget);
    expect(find.textContaining('LVL'), findsNothing);
    expect(find.textContaining('/ 1000 XP'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
