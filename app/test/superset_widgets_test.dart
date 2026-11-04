import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/widgets/workout_exercise_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedLanguage extends LocalizationModeNotifier {
  _FixedLanguage(this.mode);
  final AppLangMode mode;

  @override
  AppLangMode build() => mode;
}

void main() {
  for (final language in [AppLangMode.en, AppLangMode.vi]) {
    testWidgets(
      'grouped timed tile fits 320dp with 2x text in ${language.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localizationModeProvider.overrideWith(
                () => _FixedLanguage(language),
              ),
            ],
            child: MaterialApp(
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: WorkoutExerciseTile(
                      workoutExercise: const WorkoutExercise(
                        id: 'workout-exercise',
                        workoutId: 'workout',
                        exerciseId: 'exercise',
                        supersetGroupId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                        supersetPosition: 0,
                        mode: WorkoutMode.timed,
                        exercise: Exercise(
                          id: 'exercise',
                          name: 'Plank with a long exercise name',
                          category: 'Core',
                          equipment: 'Bodyweight',
                        ),
                        sets: [
                          WorkoutSet(
                            id: 'set',
                            workoutExerciseId: 'workout-exercise',
                            setNumber: 1,
                            durationSeconds: 60,
                          ),
                        ],
                      ),
                      canReorder: false,
                      isGroupLocked: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Superset'), findsWidgets);
        expect(find.byIcon(Icons.drag_indicator), findsNothing);
      },
    );

    testWidgets(
      'legacy NULL mode stays visibly unspecified in ${language.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localizationModeProvider.overrideWith(
                () => _FixedLanguage(language),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: WorkoutExerciseTile(
                    workoutExercise: const WorkoutExercise(
                      id: 'legacy',
                      workoutId: 'workout',
                      exerciseId: 'exercise',
                      exercise: Exercise(
                        id: 'exercise',
                        name: 'Legacy Exercise',
                        category: 'Core',
                        equipment: 'Bodyweight',
                      ),
                      sets: [
                        WorkoutSet(
                          id: 'legacy-set',
                          workoutExerciseId: 'legacy',
                          reps: 0,
                          durationSeconds: 60,
                          isCompleted: true,
                        ),
                      ],
                    ),
                    isEditable: false,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(
            language == AppLangMode.en
                ? 'Legacy mode unspecified'
                : 'Chế độ cũ chưa xác định',
          ),
          findsOneWidget,
        );
        expect(find.text('Bodyweight + added load'), findsNothing);
        expect(
          find.textContaining(
            language == AppLangMode.en ? 'Duration: 60' : 'Thời lượng: 60',
          ),
          findsOneWidget,
        );
      },
    );
  }
}
