import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/workout/presentation/screens/workout_screen.dart';
import '../../features/quests/presentation/screens/quests_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'main_shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateStreamProvider);
  final currentUserAsync = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/login', // Fallback, redirect logic handles the actual start
    redirect: (context, state) {
      final authState = authStateAsync.value;
      final currentUser = currentUserAsync.value;
      
      // Vẫn đang tải Auth hoặc chưa kéo xong Profile
      if (authStateAsync.isLoading || currentUserAsync.isLoading) return null;

      final isAuth = authState?.session != null;
      final isOnboarded = currentUser?['onboarding_completed'] == true;

      final loc = state.matchedLocation;
      final isGoingToLogin = loc == '/login';
      final isGoingToRegister = loc == '/register';
      final isGoingToOnboarding = loc == '/onboarding';
      
      // Khởi động không có auth -> login
      if (!isAuth && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      // Đăng nhập rồi nhưng chưa onboard -> onboarding
      if (isAuth && !isOnboarded && !isGoingToOnboarding) {
        return '/onboarding';
      }

      // Đăng nhập rồi, đã onboard -> chặn quay lại màn hình nhập môn/đăng nhập
      if (isAuth && isOnboarded && (isGoingToLogin || isGoingToRegister || isGoingToOnboarding)) {
        return '/dashboard'; 
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Trả về bộ khung (Bottom Navigation) chứa 4 tab.
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
    ],
  );
});
