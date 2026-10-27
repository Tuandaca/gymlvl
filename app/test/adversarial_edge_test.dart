import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/localization/localization_engine.dart';
import 'package:app/core/router/main_shell_screen.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/coach/data/coach_repository.dart';
import 'package:app/features/coach/presentation/coach_screen.dart';
import 'package:app/features/progression/domain/progression_engine.dart';
import 'package:app/features/workout/data/supabase_workout_repository.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/widgets/set_row_widget.dart';
import 'package:go_router/go_router.dart';

class AdversarialCoachRepo implements CoachRepository {
  AdversarialCoachRepo({this.failureCode});
  String? failureCode;
  int callCount = 0;
  List<CoachMessage> sentHistory = [];

  @override
  Future<String> ask(String message, List<CoachMessage> history) async {
    callCount++;
    sentHistory = history;
    if (failureCode != null) {
      throw CoachFailure(failureCode!);
    }
    return 'Adversarial response for: $message';
  }
}

class FixedLanguage extends LocalizationModeNotifier {
  FixedLanguage(this.mode);
  final AppLangMode mode;
  @override
  AppLangMode build() => mode;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final font in {
      'Inter': 'assets/fonts/InterVariable.ttf',
      'Orbitron': 'assets/fonts/OrbitronVariable.ttf',
    }.entries) {
      if (File(font.value).existsSync()) {
        final loader = FontLoader(font.key)
          ..addFont(
            Future.value(
              ByteData.sublistView(await File(font.value).readAsBytes()),
            ),
          );
        await loader.load();
      }
    }
  });

  group('Adversarial Set Validation & Numeric Boundaries', () {
    test('validateSet rejects out-of-boundary and non-finite inputs', () {
      // Reps boundaries: 0..1000
      expect(
        () => SupabaseWorkoutRepository.validateSet(reps: -1),
        throwsArgumentError,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(reps: -9999),
        throwsArgumentError,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(reps: 0),
        returnsNormally,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(reps: 1000),
        returnsNormally,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(reps: 1001),
        throwsArgumentError,
      );

      // Weight boundaries: 0..1000
      expect(
        () => SupabaseWorkoutRepository.validateSet(weightKg: -0.1),
        throwsArgumentError,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(weightKg: 0.0),
        returnsNormally,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(weightKg: 1000.0),
        returnsNormally,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(weightKg: 1000.1),
        throwsArgumentError,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(weightKg: double.nan),
        throwsArgumentError,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(weightKg: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(
          weightKg: double.negativeInfinity,
        ),
        throwsArgumentError,
      );

      // Rest seconds boundaries: 0..7200
      expect(
        () => SupabaseWorkoutRepository.validateSet(restSeconds: -1),
        throwsArgumentError,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(restSeconds: 0),
        returnsNormally,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(restSeconds: 7200),
        returnsNormally,
      );
      expect(
        () => SupabaseWorkoutRepository.validateSet(restSeconds: 7201),
        throwsArgumentError,
      );
    });

    test('ProgressionEngine survives extreme load without NaN/Overflow', () {
      final now = DateTime.utc(2026, 10, 26, 10);
      final workout = Workout(
        id: 'w-extreme',
        userId: 'u1',
        startedAt: now,
        trainingStartedAt: now,
        completedAt: now.add(const Duration(minutes: 45)),
        exercises: [
          WorkoutExercise(
            id: 'we1',
            workoutId: 'w-extreme',
            exerciseId: 'squat',
            exercise: const Exercise(
              id: 'squat',
              name: 'Heavy Squat',
              category: 'Legs',
              equipment: 'Barbell',
            ),
            sets: List.generate(
              10,
              (i) => WorkoutSet(
                id: 'set-$i',
                workoutExerciseId: 'we1',
                setNumber: i + 1,
                reps: 1000,
                weightKg: 1000.0,
                isCompleted: true,
              ),
            ),
          ),
        ],
      );

      final xp = ProgressionEngine.calculateXP(
        durationSeconds: 45 * 60,
        completedSets: workout.exercises.first.sets,
        uniqueCategories: 1,
        userStreak: 30,
      );
      expect(xp, isA<int>());
      expect(xp, greaterThan(0));
      expect(
        xp <= 1000,
        isTrue,
        reason: 'XP calculation must be capped at 1000',
      );
    });

    test('ProgressionEngine with 0 reps or 0 completed sets yields 0 XP', () {
      final now = DateTime.utc(2026, 10, 26, 10);
      final workout = Workout(
        id: 'w-zero',
        userId: 'u1',
        startedAt: now,
        trainingStartedAt: now,
        completedAt: now.add(const Duration(minutes: 30)),
        exercises: [
          WorkoutExercise(
            id: 'we1',
            workoutId: 'w-zero',
            exerciseId: 'squat',
            sets: [
              const WorkoutSet(
                id: 's1',
                workoutExerciseId: 'we1',
                reps: 0,
                weightKg: 50.0,
                isCompleted: true,
              ),
              const WorkoutSet(
                id: 's2',
                workoutExerciseId: 'we1',
                reps: 10,
                weightKg: 50.0,
                isCompleted: false, // not completed
              ),
            ],
          ),
        ],
      );

      final xp = ProgressionEngine.calculateXP(
        durationSeconds: 30 * 60,
        completedSets: workout.exercises.first.sets,
        uniqueCategories: 1,
        userStreak: 5,
      );
      expect(xp, 0);
    });
  });

  group('SetRowWidget Edge Input & Narrow Viewport Stress', () {
    for (final width in [320.0, 390.0]) {
      testWidgets(
        'SetRowWidget handles 0 reps and rejects >1000 at width $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          int? lastReps;
          double? lastWeight;

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: AppTheme.darkTheme,
                home: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SetRowWidget(
                      setNumber: 1,
                      reps: 10,
                      weightKg: 50,
                      onRepsChanged: (r) => lastReps = r,
                      onWeightChanged: (w) => lastWeight = w,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          final textFields = find.byType(TextField);
          expect(textFields, findsNWidgets(2));

          // Enter 0 reps
          final repsField = textFields.at(1);
          await tester.enterText(repsField, '0');
          await tester.pumpAndSettle();
          expect(lastReps, 0);

          // Attempt to enter reps > 1000 (e.g. 1500) -> blocked by formatter
          await tester.enterText(repsField, '1500');
          await tester.pumpAndSettle();
          expect(lastReps, isNot(1500));

          // Weight field: enter 0kg
          final weightField = textFields.at(0);
          await tester.enterText(weightField, '0');
          await tester.pumpAndSettle();
          expect(lastWeight, 0.0);

          // Weight field: attempt to enter 2500kg -> blocked by formatter
          await tester.enterText(weightField, '2500');
          await tester.pumpAndSettle();
          expect(lastWeight, isNot(2500.0));

          // Weight field: enter comma-formatted decimal (e.g. "42,5")
          await tester.enterText(weightField, '42,5');
          await tester.pumpAndSettle();
          expect(lastWeight, 42.5);

          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('AI Coach 503 Fallback & Responsive Stress', () {
    for (final mode in [
      AppLangMode.vi,
      AppLangMode.en,
      AppLangMode.bilingual,
    ]) {
      for (final width in [320.0, 390.0, 768.0, 1440.0]) {
        testWidgets(
          'CoachScreen handles 503 unconfigured at $width in ${mode.name}',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final repo = AdversarialCoachRepo(
              failureCode: 'coach_unconfigured',
            );
            final container = ProviderContainer(
              overrides: [
                localizationModeProvider.overrideWith(
                  () => FixedLanguage(mode),
                ),
                coachRepositoryProvider.overrideWithValue(repo),
                authStateStreamProvider.overrideWith(
                  (ref) => const Stream.empty(),
                ),
              ],
            );
            addTearDown(container.dispose);

            await tester.pumpWidget(
              UncontrolledProviderScope(
                container: container,
                child: MaterialApp(
                  theme: AppTheme.darkTheme,
                  locale: Locale(mode == AppLangMode.en ? 'en' : 'vi'),
                  supportedLocales: const [Locale('en'), Locale('vi')],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: const CoachScreen(),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);

            // Enter message and click send
            final input = find.byType(TextField);
            expect(input, findsOneWidget);
            await tester.enterText(input, 'Adversarial test prompt');
            await tester.tap(find.byType(IconButton));
            await tester.pumpAndSettle();

            // Verify error is displayed gracefully without throwing
            expect(tester.takeException(), isNull);
            if (mode == AppLangMode.vi) {
              expect(
                find.textContaining('AI Coach chưa được cấu hình'),
                findsOneWidget,
              );
            } else if (mode == AppLangMode.en) {
              expect(
                find.textContaining('AI Coach is not configured yet'),
                findsOneWidget,
              );
            }

            // Verify input remains usable (user can retry or ask another question)
            final controller = container.read(coachControllerProvider);
            expect(controller.sending, isFalse);
            expect(controller.errorCode, 'coach_unconfigured');
          },
        );
      }
    }
  });

  group('MainShellScreen Navigation Across Viewport Breakpoints', () {
    for (final width in [320.0, 390.0, 768.0, 959.0, 960.0, 1440.0]) {
      for (final mode in [AppLangMode.vi, AppLangMode.en]) {
        testWidgets(
          'Shell renders at width $width in ${mode.name} without overflow',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final testRouter = GoRouter(
              initialLocation: '/tab0',
              routes: [
                StatefulShellRoute.indexedStack(
                  builder: (context, state, navigationShell) =>
                      MainShellScreen(navigationShell: navigationShell),
                  branches: List.generate(
                    4,
                    (i) => StatefulShellBranch(
                      routes: [
                        GoRoute(
                          path: '/tab$i',
                          builder: (_, _) => Text('Tab $i Content'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );

            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  localizationModeProvider.overrideWith(
                    () => FixedLanguage(mode),
                  ),
                ],
                child: MaterialApp.router(
                  theme: AppTheme.darkTheme,
                  routerConfig: testRouter,
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);

            if (width >= 960) {
              expect(find.text('GYMLEVEL'), findsOneWidget);
            } else {
              expect(find.text('GYMLEVEL'), findsNothing);
            }
          },
        );
      }
    }
  });
}
