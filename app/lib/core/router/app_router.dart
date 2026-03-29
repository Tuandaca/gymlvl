import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateStreamProvider);
  final currentUserAsync = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/login', // Fallback, redirect logic handles the actual start
    redirect: (context, state) {
      final authState = authStateAsync.valueOrNull;
      final currentUser = currentUserAsync.valueOrNull;
      
      // Vẫn đang tải Auth hoặc chưa kéo xong Profile
      if (authStateAsync.isLoading || currentUserAsync.isLoading) return null;

      final isAuth = authState?.session != null;
      final isOnboarded = currentUser?['onboarding_completed'] == true;

      final loc = state.matchedLocation;
      final isGoingToLogin = loc == '/login';
      final isGoingToRegister = loc == '/register';
      final isGoingToOnboarding = loc == '/onboarding';
      
      // 1. Chưa đăng nhập -> đá về Login
      if (!isAuth && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      // 2. Đã đăng nhập NHƯNG chưa Onboard => đá về Onboarding
      if (isAuth && !isOnboarded && !isGoingToOnboarding) {
        return '/onboarding';
      }

      // 3. Đã đăng nhập VÀ Đã Onboard => Không được quay lại Login/Register/Onboarding
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
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
});

// Temporary placeholder for dashboard, we will move this to features later
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GymLevel Dashboard')),
      body: const Center(
        child: Text('Welcome! You are authenticated.'),
      ),
    );
  }
}
