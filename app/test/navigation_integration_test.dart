import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:app/core/router/persistent_active_workout_banner.dart';
import 'package:app/core/theme/candy_colors.dart';
import 'package:app/core/theme/candy_theme.dart';
import 'package:app/ui/candy/candy_button.dart';
import 'package:app/ui/candy/candy_navigation_item.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';

class MockActiveWorkoutNotifier extends ActiveWorkoutController {
  final ActiveWorkoutState _initialState;
  MockActiveWorkoutNotifier(this._initialState);

  @override
  ActiveWorkoutState build() => _initialState;
}

void main() {
  group('Worker M6: Navigation & Integration Tests', () {
    test(
      'Theme Configuration Contract: CandyTheme exposes theme, lightTheme, darkTheme',
      () {
        expect(CandyTheme.theme, isNotNull);
        expect(CandyTheme.lightTheme, isNotNull);
        expect(CandyTheme.darkTheme, isNotNull);
        expect(
          CandyTheme.theme.scaffoldBackgroundColor,
          equals(CandyColors.canvas),
        );
        expect(
          CandyTheme.theme.textTheme.bodyMedium?.fontFamily,
          equals(CandyFonts.body),
        );
      },
    );

    test('Zero Orbitron references remain in app/lib/**', () {
      final libDir = Directory('lib');
      final files = libDir.listSync(recursive: true).whereType<File>();
      final dartFiles = files.where((f) => f.path.endsWith('.dart'));

      int orbitronCount = 0;
      final offendingFiles = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        if (content.toLowerCase().contains('orbitron')) {
          orbitronCount++;
          offendingFiles.add(file.path);
        }
      }

      expect(
        orbitronCount,
        equals(0),
        reason:
            'Orbitron must be completely eradicated from app/lib. Found in: $offendingFiles',
      );
    });

    testWidgets(
      'PersistentActiveWorkoutBanner: hides when workout is inactive',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            activeWorkoutControllerProvider.overrideWith(
              () => MockActiveWorkoutNotifier(const ActiveWorkoutState()),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(body: PersistentActiveWorkoutBanner()),
            ),
          ),
        );

        expect(find.byType(CandyButton), findsNothing);
        expect(find.text('Tiếp tục'), findsNothing);
        expect(find.text('Resume'), findsNothing);
      },
    );

    testWidgets(
      'PersistentActiveWorkoutBanner: renders live timer, exercise summary and tactile CandyButton when active',
      (tester) async {
        final now = DateTime.now().toUtc();
        final activeWorkout = Workout(
          id: 'w-1',
          userId: 'u-1',
          status: WorkoutStatus.active,
          startedAt: now.subtract(const Duration(minutes: 5, seconds: 23)),
          trainingStartedAt: now.subtract(
            const Duration(minutes: 5, seconds: 23),
          ),
        );

        const exercise = Exercise(
          id: 'bench-press',
          name: 'Barbell Bench Press',
          category: 'chest',
          equipment: 'barbell',
        );

        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          workoutId: 'w-1',
          exerciseId: 'bench-press',
          exercise: exercise,
          orderIndex: 0,
          sets: const [
            WorkoutSet(
              id: 's-1',
              workoutExerciseId: 'we-1',
              setNumber: 1,
              reps: 10,
              weightKg: 60,
              isCompleted: true,
            ),
            WorkoutSet(
              id: 's-2',
              workoutExerciseId: 'we-1',
              setNumber: 2,
              reps: 10,
              weightKg: 60,
              isCompleted: false,
            ),
          ],
        );

        final state = ActiveWorkoutState(
          workout: activeWorkout,
          exercises: [workoutExercise],
          elapsedSeconds: 323, // 05:23
          isSetupPhase: false,
        );

        final container = ProviderContainer(
          overrides: [
            activeWorkoutControllerProvider.overrideWith(
              () => MockActiveWorkoutNotifier(state),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(body: PersistentActiveWorkoutBanner()),
            ),
          ),
        );
        await tester.pump();

        // Verify Live indicator and formatted elapsed time
        expect(find.text('05:23'), findsOneWidget);
        expect(find.textContaining('Barbell Bench Press'), findsOneWidget);
        expect(find.textContaining('1/2'), findsOneWidget);

        // Verify tactile CandyButton Resume CTA
        expect(find.byType(CandyButton), findsOneWidget);
        expect(find.text('Tiếp tục'), findsOneWidget);
      },
    );

    testWidgets(
      'CandyNavigationItem primitive: renders active pill and label correctly',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  CandyNavigationItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Tổng quan',
                    isSelected: true,
                    activeColor: CandyColors.canaryYellow,
                    onTap: () => tapped = true,
                  ),
                  CandyNavigationItem(
                    icon: Icons.fitness_center_rounded,
                    label: 'Tập luyện',
                    isSelected: false,
                    badgeText: '!',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Tổng quan'), findsOneWidget);
        expect(find.text('Tập luyện'), findsOneWidget);
        expect(find.text('!'), findsOneWidget);

        await tester.tap(find.text('Tổng quan'));
        expect(tapped, isTrue);
      },
    );

    test(
      'GoRouter configuration: all required routes are wired and accessible',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final routePaths = <String>[];

        void collectPaths(List<RouteBase> routes) {
          for (final route in routes) {
            if (route is GoRoute) {
              routePaths.add(route.path);
            }
            if (route is StatefulShellRoute) {
              for (final branch in route.branches) {
                collectPaths(branch.routes);
              }
            }
            if (route is ShellRoute) {
              collectPaths(route.routes);
            }
          }
        }

        collectPaths(router.configuration.routes);

        expect(routePaths, contains('/'));
        expect(routePaths, contains('/dashboard'));
        expect(routePaths, contains('/workout'));
        expect(routePaths, contains('/workout/active'));
        expect(routePaths, contains('/workout/summary'));
        expect(routePaths, contains('/quests'));
        expect(routePaths, contains('/profile'));
        expect(routePaths, contains('/session'));
        expect(routePaths, contains('/login'));
        expect(routePaths, contains('/register'));
        expect(routePaths, contains('/onboarding'));
      },
    );
  });
}
