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

final passwordRecoveryProvider =
    NotifierProvider<PasswordRecoveryNotifier, bool>(
      PasswordRecoveryNotifier.new,
    );

class PasswordRecoveryNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(authStateStreamProvider, (_, next) {
      final auth = next.value;
      if (auth?.event == AuthChangeEvent.passwordRecovery) {
        state = true;
      } else if (next.hasValue && auth?.session == null) {
        state = false;
      }
    });
    return ref.read(authStateStreamProvider).value?.event ==
        AuthChangeEvent.passwordRecovery;
  }

  void setRequired(bool value) => state = value;
}

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final session = ref.watch(authStateStreamProvider).value?.session;
  if (session == null) return null;

  return await SupabaseConfig.client
      .from('users')
      .select()
      .eq('id', session.user.id)
      .maybeSingle();
});

final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final session = ref.watch(authStateStreamProvider).value?.session;
  if (session == null) return null;

  return await SupabaseConfig.client
      .from('profiles')
      .select()
      .eq('id', session.user.id)
      .maybeSingle();
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
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
    });
  }

  Future<void> signUp(String email, String password) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password);
    });
  }

  Future<void> signOut() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      ref.read(passwordRecoveryProvider.notifier).setRequired(false);
    });
  }

  Future<void> resetPassword(String email) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).resetPassword(email),
    );
  }

  Future<void> updatePassword(String password) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updatePassword(password);
      ref.read(passwordRecoveryProvider.notifier).setRequired(false);
    });
  }
}
