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
import '../../features/workout/presentation/screens/workout_screen.dart';
import '../../features/workout/presentation/screens/exercise_picker_screen.dart';
import '../../features/workout/presentation/screens/active_workout_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/quests/presentation/screens/quests_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/workout/presentation/screens/workout_summary_screen.dart';
import '../../features/workout/domain/workout.dart';
import '../../features/workout/domain/workout_exercise.dart';
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
        builder: (context, state) {
          final extra = state.extra;
          if (extra is WorkoutSummaryScreen) {
            return extra;
          }
          if (extra is Map<String, dynamic>) {
            return WorkoutSummaryScreen(
              workout:
                  extra['workout'] as Workout? ??
                  Workout(
                    id: 'summary-preview',
                    userId: 'user',
                    status: WorkoutStatus.completed,
                    startedAt: DateTime.now(),
                  ),
              xpResult: extra['xpResult'] as Map<String, dynamic>?,
              totalVolumeKg:
                  (extra['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
              durationSeconds: (extra['durationSeconds'] as num?)?.toInt() ?? 0,
              completedSetsCount:
                  (extra['completedSetsCount'] as num?)?.toInt() ?? 0,
              totalSetsCount: (extra['totalSetsCount'] as num?)?.toInt() ?? 0,
              exercises:
                  (extra['exercises'] as List<WorkoutExercise>?) ?? const [],
            );
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
          return WorkoutSummaryScreen(
            workout: Workout(
              id: 'summary-default',
              userId: 'user',
              status: WorkoutStatus.completed,
              startedAt: DateTime.now(),
            ),
            totalVolumeKg: 0,
            durationSeconds: 0,
            completedSetsCount: 0,
            totalSetsCount: 0,
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
    ],
  );
  ref.onDispose(() {
    router.dispose();
    notifier.dispose();
  });
  return router;
});
