import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/auth/domain/auth_repository.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _EnglishLanguage extends LocalizationModeNotifier {
  @override
  AppLangMode build() => AppLangMode.en;
}

class _FakeAuthRepository implements AuthRepository {
  bool fail = false;
  int updateCalls = 0;

  @override
  Stream<AuthState> get authStateChange => const Stream.empty();

  @override
  User? get currentUser => null;

  void _check() {
    if (fail) throw const AuthException('Session expired');
  }

  @override
  Future<void> signInWithEmail(String email, String password) async => _check();

  @override
  Future<void> signUpWithEmail(String email, String password) async => _check();

  @override
  Future<void> signOut() async => _check();

  @override
  Future<void> resetPassword(String email) async => _check();

  @override
  Future<void> updatePassword(String password) async {
    updateCalls++;
    _check();
  }
}

void main() {
  testWidgets('a previous sign-in failure is not shown on recovery entry', (
    tester,
  ) async {
    final repository = _FakeAuthRepository()..fail = true;
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        localizationModeProvider.overrideWith(_EnglishLanguage.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .signIn('person@example.test', 'wrong-password');
    expect(container.read(authControllerProvider).hasError, isTrue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ResetPasswordScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not update your password'), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), 'new-password');
    await tester.enterText(find.byType(TextFormField).at(1), 'new-password');
    await tester.tap(find.text('Save password'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 1);
    expect(
      find.textContaining('Could not update your password'),
      findsOneWidget,
    );

    repository.fail = false;
    await tester.tap(find.text('Save password'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 2);
    expect(find.textContaining('Could not update your password'), findsNothing);
  });
}
