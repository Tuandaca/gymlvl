import 'dart:async';

import 'package:app/features/auth/domain/auth_repository.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository implements AuthRepository {
  Completer<void>? pendingSignIn;
  Object? failure;
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  String? resetEmail;
  String? updatedPassword;

  @override
  Stream<AuthState> get authStateChange => const Stream.empty();
  @override
  User? get currentUser => null;

  void checkFailure() {
    if (failure != null) throw failure!;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    signInCalls++;
    if (pendingSignIn != null) await pendingSignIn!.future;
    checkFailure();
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    signUpCalls++;
    checkFailure();
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    checkFailure();
  }

  @override
  Future<void> resetPassword(String email) async {
    resetEmail = email;
    checkFailure();
  }

  @override
  Future<void> updatePassword(String password) async {
    updatedPassword = password;
    checkFailure();
  }
}

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });
  tearDown(() => container.dispose());

  Future<AuthController> controller() async {
    await container.read(authControllerProvider.future);
    return container.read(authControllerProvider.notifier);
  }

  test('repeated submit starts one authentication request', () async {
    repository.pendingSignIn = Completer<void>();
    final auth = await controller();
    final first = auth.signIn('person@example.test', 'password');
    expect(container.read(authControllerProvider).isLoading, isTrue);
    await auth.signIn('person@example.test', 'password');
    await auth.signUp('person@example.test', 'password');
    expect(repository.signInCalls, 1);
    expect(repository.signUpCalls, 0);
    repository.pendingSignIn!.complete();
    await first;
    expect(container.read(authControllerProvider).hasError, isFalse);
    expect(container.read(authControllerProvider).isLoading, isFalse);
  });

  test('a failed sign in exposes error and allows retry', () async {
    repository.failure = const AuthException('Invalid login credentials');
    final auth = await controller();
    await auth.signIn('person@example.test', 'wrong');
    expect(container.read(authControllerProvider).hasError, isTrue);
    repository.failure = null;
    await auth.signIn('person@example.test', 'correct');
    expect(repository.signInCalls, 2);
    expect(container.read(authControllerProvider).hasError, isFalse);
  });

  test(
    'registration service failure is not a successful registration',
    () async {
      repository.failure = const AuthException('Registration unavailable');
      final auth = await controller();
      await auth.signUp('person@example.test', 'password');
      expect(repository.signUpCalls, 1);
      expect(container.read(authControllerProvider).hasError, isTrue);
    },
  );

  test(
    'password reset forwards the requested email and handles failure',
    () async {
      repository.failure = const AuthException('Network unavailable');
      final auth = await controller();
      await auth.resetPassword('person@example.test');
      expect(repository.resetEmail, 'person@example.test');
      expect(container.read(authControllerProvider).hasError, isTrue);
      repository.failure = null;
      await auth.resetPassword('person@example.test');
      expect(container.read(authControllerProvider).hasError, isFalse);
    },
  );

  test(
    'failed password update keeps recovery required until successful',
    () async {
      final auth = await controller();
      container.read(passwordRecoveryProvider.notifier).setRequired(true);
      repository.failure = const AuthException('Session expired');
      await auth.updatePassword('new-password');
      expect(container.read(passwordRecoveryProvider), isTrue);
      expect(container.read(authControllerProvider).hasError, isTrue);
      repository.failure = null;
      await auth.updatePassword('new-password');
      expect(repository.updatedPassword, 'new-password');
      expect(container.read(passwordRecoveryProvider), isFalse);
    },
  );

  test(
    'sign out clears recovery only after successful server response',
    () async {
      final auth = await controller();
      container.read(passwordRecoveryProvider.notifier).setRequired(true);
      repository.failure = const AuthException('Network unavailable');
      await auth.signOut();
      expect(container.read(passwordRecoveryProvider), isTrue);
      expect(container.read(authControllerProvider).hasError, isTrue);
      repository.failure = null;
      await auth.signOut();
      expect(repository.signOutCalls, 2);
      expect(container.read(passwordRecoveryProvider), isFalse);
    },
  );
}
