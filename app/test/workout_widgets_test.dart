import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/widgets/workout_exercise_tile.dart';
import 'package:app/features/workout/presentation/widgets/rest_timer_widget.dart';
import 'package:app/features/workout/presentation/widgets/workout_summary_card.dart';
import 'package:app/ui/candy/candy_button.dart';
import 'package:app/ui/candy/candy_card.dart';

class FixedLanguage extends LocalizationModeNotifier {
  final AppLangMode mode;
  FixedLanguage(this.mode);
  @override
  AppLangMode build() => mode;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final mode in [AppLangMode.en, AppLangMode.vi]) {
    for (final width in [320.0, 768.0, 1280.0]) {
      testWidgets('editable workout works at $width in ${mode.name}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var deleted = false;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localizationModeProvider.overrideWith(() => FixedLanguage(mode)),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: WorkoutExerciseTile(
                    workoutExercise: const WorkoutExercise(
                      id: 'we',
                      workoutId: 'w',
                      exerciseId: 'e',
                      exercise: Exercise(
                        id: 'e',
                        name: 'Incline Bench Press (Dumbbell)',
                        category: 'Chest',
                        equipment: 'Dumbbell',
                      ),
                      sets: [
                        WorkoutSet(
                          id: 's',
                          workoutExerciseId: 'we',
                          reps: 12,
                          weightKg: 20,
                        ),
                      ],
                    ),
                    onDeleteSet: (_) => deleted = true,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final tooltip = mode == AppLangMode.en ? 'Delete set' : 'Xóa hiệp';
        expect(find.byTooltip(tooltip), findsOneWidget);
        await tester.tap(find.byTooltip(tooltip));
        expect(deleted, true);
        expect(find.text('+3 XP'), findsNothing);
      });
    }
  }
  testWidgets('rest selector fits narrow mobile and exposes real buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: DurationWheelPicker(onSelect: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CandyButton), findsNWidgets(2));
    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    expect(find.text('Đặt thời gian nghỉ'), findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('phút'), findsOneWidget);
    expect(find.text('giây'), findsOneWidget);
  });
  testWidgets('rest timer keeps every action accessible at 320dp and 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var skipped = 0;
    var paused = 0;
    var reset = 0;
    var added = 0;
    var subtracted = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localizationModeProvider.overrideWith(
            () => FixedLanguage(AppLangMode.en),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SingleChildScrollView(
                child: RestTimerWidget(
                  secondsRemaining: 90,
                  secondsTotal: 120,
                  onSkip: () => skipped++,
                  onPauseResume: () => paused++,
                  onReset: () => reset++,
                  onAdd30: () => added++,
                  onSubtract15: () => subtracted++,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CandyCard), findsOneWidget);
    expect(find.bySemanticsLabel('Rest timer: 01:30'), findsOneWidget);

    for (final label in ['Finish rest', '-15s', 'Pause', 'Reset', '+30s']) {
      final button = find.widgetWithText(CandyButton, label);
      expect(button, findsOneWidget);
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      await tester.ensureVisible(button);
      await tester.tap(button);
    }
    expect([skipped, subtracted, paused, reset, added], [1, 1, 1, 1, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paused rest timer has localized Vietnamese resume control', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var resumed = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localizationModeProvider.overrideWith(
            () => FixedLanguage(AppLangMode.vi),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SingleChildScrollView(
                child: RestTimerWidget(
                  secondsRemaining: 45,
                  secondsTotal: 60,
                  isPaused: true,
                  onSkip: () {},
                  onPauseResume: () => resumed++,
                  onReset: () {},
                  onAdd30: () {},
                  onSubtract15: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Đồng hồ nghỉ: 00:45'), findsOneWidget);
    final resumeButton = find.widgetWithText(CandyButton, 'Tiếp tục');
    expect(tester.getSize(resumeButton).height, greaterThanOrEqualTo(48));
    await tester.ensureVisible(resumeButton);
    await tester.tap(resumeButton);
    expect(resumed, 1);
    expect(tester.takeException(), isNull);
  });
  test(
    'relative workout dates follow calendar midnight, not 24-hour duration',
    () {
      expect(
        WorkoutSummaryCard.calendarDaysApart(
          DateTime(2026, 10, 26, 1),
          DateTime(2026, 10, 25, 23),
        ),
        1,
      );
    },
  );
}
