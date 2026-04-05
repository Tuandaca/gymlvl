import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/auth_repository.dart';
import '../../data/supabase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(SupabaseConfig.client);
});

final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChange;
});

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final session = ref.watch(authStateStreamProvider).value?.session;
  if (session == null) return null;
  
  try {
    final res = await SupabaseConfig.client
        .from('users')
        .select()
        .eq('id', session.user.id)
        .maybeSingle();
    return res;
  } catch (e) {
    return null;
  }
});

final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final session = ref.watch(authStateStreamProvider).value?.session;
  if (session == null) return null;
  
  try {
    final res = await SupabaseConfig.client
        .from('profiles')
        .select()
        .eq('id', session.user.id)
        .maybeSingle();
    return res;
  } catch (e) {
    return null;
  }
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initialize if needed
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
    });
  }
}
