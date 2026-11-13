import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/widgets/set_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedLanguage extends LocalizationModeNotifier {
  _FixedLanguage(this.language);
  final AppLangMode language;
  @override
  AppLangMode build() => language;
}

void main() {
  test('production M3 mode and superset gates remain closed', () {
    expect(productionWorkoutModesEnabled, isFalse);
    expect(productionSupersetEnabled, isFalse);
  });

  test(
    'Supabase set_type warm-up round-trips and missing type stays workout',
    () {
      final warmup = WorkoutSet.fromJson({
        'id': 'warmup-set',
        'workout_exercise_id': 'exercise',
        'set_type': 'warmup',
      });
      expect(warmup.isWarmup, isTrue);
      expect(warmup.toJson()['set_type'], 'warmup');
      expect(warmup.toJson().containsKey('setType'), isFalse);

      final legacy = WorkoutSet.fromJson({
        'id': 'legacy-set',
        'workout_exercise_id': 'exercise',
      });
      expect(legacy.setType, WorkoutSetType.workout);
    },
  );

  test(
    'persisted mode values round-trip and legacy NULL remains unspecified',
    () {
      for (final mode in WorkoutMode.values) {
        final exercise = WorkoutExercise.fromJson({
          'id': 'we',
          'workout_id': 'w',
          'exercise_id': 'e',
          'mode': mode.wireValue,
          'superset_group_id': 'group',
          'superset_position': 0,
          'superset_locked': true,
        });
        expect(exercise.mode, mode);
        expect(exercise.toJson()['mode'], mode.wireValue);
        expect(exercise.supersetGroupId, 'group');
        expect(exercise.supersetPosition, 0);
        expect(exercise.supersetLocked, isTrue);
      }
      final legacy = WorkoutExercise.fromJson({
        'id': 'legacy',
        'workout_id': 'w',
        'exercise_id': 'e',
        'workout_sets': [
          {
            'id': 's',
            'workout_exercise_id': 'legacy',
            'reps': 0,
            'duration_seconds': 60,
          },
        ],
      });
      expect(legacy.mode, isNull);
      expect(legacy.supersetLocked, isNull);
      expect(legacy.sets.single.durationSeconds, 60);
      expect(
        () => WorkoutExercise.fromJson({
          'id': 'bad',
          'workout_id': 'w',
          'exercise_id': 'e',
          'mode': 'distance',
        }),
        throwsFormatException,
      );
    },
  );

  test(
    'completed reps and bodyweight sets require reps and use added load',
    () {
      for (final mode in [WorkoutMode.repsWeight, WorkoutMode.bodyweight]) {
        validateWorkoutSetForMode(
          mode: mode,
          reps: 1,
          weightKg: mode == WorkoutMode.bodyweight ? 5 : 0,
          durationSeconds: 0,
          isCompleted: true,
        );
        validateWorkoutSetForMode(
          mode: mode,
          reps: 1000,
          weightKg: 1000,
          durationSeconds: 0,
          isCompleted: true,
        );
        expect(
          () => validateWorkoutSetForMode(
            mode: mode,
            reps: 0,
            weightKg: 0,
            durationSeconds: 0,
            isCompleted: true,
          ),
          throwsArgumentError,
        );
        expect(
          () => validateWorkoutSetForMode(
            mode: mode,
            reps: 1,
            weightKg: 0,
            durationSeconds: 60,
            isCompleted: true,
          ),
          throwsArgumentError,
        );
      }
    },
  );

  test('timed and cardio accept duration only within 1..7200 seconds', () {
    for (final mode in [WorkoutMode.timed, WorkoutMode.cardio]) {
      for (final seconds in [1, 7200]) {
        validateWorkoutSetForMode(
          mode: mode,
          reps: 0,
          weightKg: 0,
          durationSeconds: seconds,
          isCompleted: true,
        );
      }
      for (final invalid in [
        (0, 0.0, 0),
        (0, 0.0, 7201),
        (1, 0.0, 60),
        (0, 5.0, 60),
      ]) {
        expect(
          () => validateWorkoutSetForMode(
            mode: mode,
            reps: invalid.$1,
            weightKg: invalid.$2,
            durationSeconds: invalid.$3,
            isCompleted: true,
          ),
          throwsArgumentError,
        );
      }
    }
  });

  test('completed legacy NULL mode requires reps even with duration', () {
    expect(
      () => validateWorkoutSetForMode(
        mode: null,
        reps: 0,
        weightKg: 0,
        durationSeconds: 30,
        isCompleted: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => validateWorkoutSetForMode(
        mode: null,
        reps: 1,
        weightKg: 0,
        durationSeconds: 0,
        isCompleted: true,
      ),
      returnsNormally,
    );
  });

  test('draft sets allow zero values but reject cross-mode measurements', () {
    validateWorkoutSetForMode(
      mode: WorkoutMode.repsWeight,
      reps: 0,
      weightKg: 0,
      durationSeconds: 0,
      isCompleted: false,
    );
    validateWorkoutSetForMode(
      mode: WorkoutMode.timed,
      reps: 0,
      weightKg: 0,
      durationSeconds: 0,
      isCompleted: false,
    );
    expect(
      () => validateWorkoutSetForMode(
        mode: WorkoutMode.bodyweight,
        reps: 0,
        weightKg: 0,
        durationSeconds: 1,
        isCompleted: false,
      ),
      throwsArgumentError,
    );
    expect(
      () => validateWorkoutSetForMode(
        mode: WorkoutMode.cardio,
        reps: 1,
        weightKg: 0,
        durationSeconds: 0,
        isCompleted: false,
      ),
      throwsArgumentError,
    );
    expect(
      () => validateWorkoutSetForMode(
        mode: WorkoutMode.timed,
        reps: 0,
        weightKg: 5,
        durationSeconds: 30,
        isCompleted: false,
      ),
      throwsArgumentError,
    );
  });

  for (final language in [AppLangMode.en, AppLangMode.vi]) {
    for (final mode in [
      WorkoutMode.bodyweight,
      WorkoutMode.timed,
      WorkoutMode.cardio,
    ]) {
      testWidgets(
        '${mode.name} input fits 320dp at 2x text in ${language.name}',
        (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final timed = mode == WorkoutMode.timed || mode == WorkoutMode.cardio;
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                localizationModeProvider.overrideWith(
                  () => _FixedLanguage(language),
                ),
              ],
              child: MaterialApp(
                home: Scaffold(
                  body: MediaQuery(
                    data: const MediaQueryData(
                      size: Size(320, 700),
                      textScaler: TextScaler.linear(2),
                    ),
                    child: SetRowWidget(
                      setNumber: 1,
                      reps: timed ? 0 : 10,
                      weightKg: 0,
                      durationSeconds: timed ? 60 : 0,
                      isBodyweight: mode == WorkoutMode.bodyweight,
                      isTimeBased: timed,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(TextField), findsOneWidget);
          if (timed) {
            expect(find.textContaining('kg'), findsNothing);
          } else {
            final load = find.textContaining(
              language == AppLangMode.en ? 'Added load' : 'Tạ thêm',
            );
            expect(load, findsWidgets);
            await tester.tap(load.first);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(TextField), findsNWidgets(2));
          }
        },
      );
    }
  }
}
