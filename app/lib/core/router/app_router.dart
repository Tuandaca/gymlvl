import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_redirect.dart';
import '../../features/auth/presentation/screens/session_gate_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/coach/presentation/coach_screen.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/training_plan/presentation/newcomer_journey_screen.dart';
import '../../features/training_plan/presentation/screens/routine_list_screen.dart';
import '../../features/training_plan/presentation/screens/routine_editor_screen.dart';
import '../../features/training_plan/presentation/screens/weekly_schedule_screen.dart';
import '../../features/training_plan/presentation/screens/planned_workouts_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/bodyweight/presentation/screens/bodyweight_screen.dart';
import '../../features/bodyweight/presentation/screens/body_measurements_screen.dart';
import '../../features/analytics/presentation/screens/data_export_screen.dart';
import '../../features/analytics/presentation/screens/exercise_progress_screen.dart';
import '../../features/workout/presentation/screens/workout_screen.dart';
import '../../features/workout/presentation/screens/exercise_picker_screen.dart';
import '../../features/workout/presentation/screens/exercise_detail_screen.dart';
import '../../features/workout/presentation/screens/active_workout_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/quests/presentation/screens/quests_screen.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/unlocks/presentation/screens/unlocks_screen.dart';
import '../../features/post_workout_feedback/presentation/screens/post_workout_feedback_screen.dart';
import '../../features/ai_trainer/presentation/screens/ai_trainer_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/workout/presentation/screens/workout_summary_screen.dart';
import '../../features/workout/domain/workout.dart';
import '../../features/workout/domain/workout_exercise.dart';
import '../../features/workout/domain/exercise.dart';
import 'main_shell_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateStreamProvider, (_, _) => notifyListeners());
    _ref.listen(passwordRecoveryProvider, (_, _) => notifyListeners());
    _ref.listen(currentUserProvider, (_, _) => notifyListeners());
  }
}

// Sử dụng Refractoring để tránh tạo lại GoRouter khi Provider thay đổi.
// GoRouter chỉ được khởi tạo MỘT LẦN duy nhất.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authStateStreamProvider);
      final user = ref.read(currentUserProvider);
      final signedIn = auth.value?.session != null;
      return authRedirect(
        location: state.matchedLocation,
        loading:
            (auth.isLoading && !auth.hasValue) ||
            (signedIn &&
                user.isLoading &&
                user.value?['id'] != auth.value?.session?.user.id),
        hasError: auth.hasError || (signedIn && user.hasError),
        signedIn: signedIn,
        onboarded: user.value?['onboarding_completed'] == true,
        recoveringPassword: ref.read(passwordRecoveryProvider),
      );
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
      GoRoute(path: '/session', builder: (_, _) => const SessionGateScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(path: '/coach', builder: (_, _) => const CoachScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ─── Main App Shell (Bottom Navigation) ───
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workout',
                builder: (context, state) => const WorkoutScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quests',
                builder: (context, state) => const QuestsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ─── Workout Flow Routes (ngoài Shell vì cần fullscreen) ───
      GoRoute(
        path: '/workout/active',
        builder: (context, state) => const ActiveWorkoutScreen(),
      ),
      GoRoute(
        path: '/workout/summary',
        // A direct deep link has no real workout context. Redirect instead of
        // fabricating a completed workout and reward.
        redirect: (context, state) =>
            hasWorkoutSummaryContext(state.extra) ? null : '/workout',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is WorkoutSummaryScreen) {
            return extra;
          }
          if (extra is Workout) {
            return WorkoutSummaryScreen(
              workout: extra,
              totalVolumeKg: 0,
              durationSeconds: 0,
              completedSetsCount: 0,
              totalSetsCount: 0,
            );
          }
          final summary = extra as Map<String, dynamic>;
          return WorkoutSummaryScreen(
            workout: summary['workout'] as Workout,
            xpResult: summary['xpResult'] as Map<String, dynamic>?,
            totalVolumeKg:
                (summary['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
            durationSeconds: (summary['durationSeconds'] as num?)?.toInt() ?? 0,
            completedSetsCount:
                (summary['completedSetsCount'] as num?)?.toInt() ?? 0,
            totalSetsCount: (summary['totalSetsCount'] as num?)?.toInt() ?? 0,
            exercises:
                (summary['exercises'] as List<WorkoutExercise>?) ?? const [],
          );
        },
      ),
      GoRoute(
        path: '/workout/history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: '/workout/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkoutDetailScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: '/exercise-picker',
        builder: (context, state) {
          final multiSelect =
              state.uri.queryParameters['multiSelect'] == 'true';
          return ExercisePickerScreen(multiSelect: multiSelect);
        },
      ),
      GoRoute(
        path: '/exercise/:id',
        builder: (context, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['id'] ?? '',
          initialExercise: state.extra is Exercise
              ? state.extra as Exercise
              : null,
          canSelect: state.uri.queryParameters['select'] == 'true',
        ),
      ),
      // ─── P2: Routine & Planning ───
      GoRoute(
        path: '/routines',
        builder: (context, state) => const RoutineListScreen(),
      ),
      GoRoute(
        path: '/routine/new',
        builder: (context, state) => const RoutineEditorScreen(),
      ),
      GoRoute(
        path: '/routine/:id',
        builder: (context, state) =>
            RoutineEditorScreen(routineId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const WeeklyScheduleScreen(),
      ),
      GoRoute(
        path: '/planned',
        builder: (context, state) => const PlannedWorkoutsScreen(),
      ),
      // ─── M5: Newcomer journey (first-week plan) ───
      GoRoute(
        path: '/plan',
        builder: (context, state) => const NewcomerJourneyScreen(),
      ),
      // ─── M5: Analytics ───
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      // ─── M5: Bodyweight ───
      GoRoute(
        path: '/bodyweight',
        builder: (context, state) => const BodyweightScreen(),
      ),
      GoRoute(
        path: '/body-measurements',
        builder: (context, state) => const BodyMeasurementsScreen(),
      ),
      GoRoute(
        path: '/data-export',
        builder: (context, state) => const DataExportScreen(),
      ),
      // ─── P4: Exercise-level progress / history ───
      GoRoute(
        path: '/exercise-progress/:id',
        builder: (context, state) => ExerciseProgressScreen(
          exerciseId: state.pathParameters['id'] ?? '',
          exerciseName: state.extra is String ? state.extra as String : null,
        ),
      ),
      // ─── P5: Achievements ───
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      // ─── P5: Unlocks ───
      GoRoute(
        path: '/unlocks',
        builder: (context, state) => const UnlocksScreen(),
      ),
      // ─── P5: Post-workout feedback ───
      GoRoute(
        path: '/workout/feedback',
        builder: (context, state) => const PostWorkoutFeedbackScreen(),
      ),
      // ─── P6: AI Personal Trainer ───
      GoRoute(
        path: '/ai-trainer',
        builder: (context, state) => const AiTrainerScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    notifier.dispose();
  });
  return router;
});
