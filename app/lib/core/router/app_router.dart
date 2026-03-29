import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateStreamProvider);

  return GoRouter(
    initialLocation: '/login', // Fallback, redirect logic handles the actual start
    redirect: (context, state) {
      final authState = authStateAsync.valueOrNull;
      
      // Still loading auth state 
      // (Supabase usually resolves this very quickly because of local storage)
      if (authStateAsync.isLoading) return null;

      final isAuth = authState?.session != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      
      // If not authenticated and trying to access secure pages
      if (!isAuth && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      // If authenticated and trying to access auth pages
      if (isAuth && (isGoingToLogin || isGoingToRegister)) {
        return '/dashboard'; // Later this might redirect to a router guard checking onboarding state instead
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
    ],
  );
}

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
