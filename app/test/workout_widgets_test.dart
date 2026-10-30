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
