import 'dart:async';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Session session(String id) => Session(
  accessToken: 'test-token',
  tokenType: 'bearer',
  user: User(
    id: id,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-10-26T00:00:00Z',
  ),
);

void main() {
  late StreamController<AuthState> events;
  late ProviderContainer container;
  setUp(() {
    events = StreamController<AuthState>.broadcast();
    container = ProviderContainer(
      overrides: [authStateStreamProvider.overrideWith((ref) => events.stream)],
    );
  });
  tearDown(() async {
    container.dispose();
    await events.close();
  });
  Future<void> emit(AuthChangeEvent event, Session? current) async {
    events.add(AuthState(event, current));
    await Future<void>.delayed(Duration.zero);
    await container.pump();
  }

  test(
    'biometric onboarding drafts are scoped to identity, not token refresh',
    () async {
      container.listen(onboardingDraftProvider, (_, _) {});
      await emit(AuthChangeEvent.signedIn, session('a'));
      container
          .read(onboardingDraftProvider.notifier)
          .update((draft) => draft.copyWith(age: 32, weightKg: 70));
      await emit(AuthChangeEvent.tokenRefreshed, session('a'));
      expect(container.read(onboardingDraftProvider).age, 32);
      await emit(AuthChangeEvent.signedIn, session('b'));
      expect(container.read(onboardingDraftProvider).age, isNull);
      expect(container.read(onboardingDraftProvider).weightKg, isNull);
    },
  );

  test(
    'SDK signout clears recovery before a different user signs in',
    () async {
      container.listen(passwordRecoveryProvider, (_, _) {});
      await emit(AuthChangeEvent.passwordRecovery, session('a'));
      expect(container.read(passwordRecoveryProvider), isTrue);
      await emit(AuthChangeEvent.signedOut, null);
      expect(container.read(passwordRecoveryProvider), isFalse);
      await emit(AuthChangeEvent.signedIn, session('b'));
      expect(container.read(passwordRecoveryProvider), isFalse);
    },
  );
}
