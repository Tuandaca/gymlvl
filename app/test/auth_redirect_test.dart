import 'package:app/core/router/auth_redirect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? route({
    String location = '/dashboard',
    bool loading = false,
    bool error = false,
    bool signedIn = false,
    bool onboarded = false,
    bool recovering = false,
  }) => authRedirect(
    location: location,
    loading: loading,
    hasError: error,
    signedIn: signedIn,
    onboarded: onboarded,
    recoveringPassword: recovering,
  );

  test('deep links stay gated while restoring session', () {
    expect(route(location: '/workout/active', loading: true), '/session');
    expect(route(location: '/session', loading: true), isNull);
  });
  test('profile errors do not restart onboarding', () {
    expect(route(signedIn: true, error: true), '/session');
    expect(route(signedIn: true), '/onboarding');
  });
  test('protected routes require a session', () {
    expect(route(), '/login');
    expect(route(location: '/register'), isNull);
  });
  test('restored sessions reach dashboard and retain protected routes', () {
    expect(route(location: '/', signedIn: true, onboarded: true), '/dashboard');
    expect(
      route(location: '/session', signedIn: true, onboarded: true),
      '/dashboard',
    );
    expect(
      route(location: '/workout/history', signedIn: true, onboarded: true),
      isNull,
    );
  });
  test('recovery precedes onboarding and leaves after password update', () {
    expect(route(signedIn: true, recovering: true), '/reset-password');
    expect(
      route(location: '/reset-password', signedIn: true, recovering: true),
      isNull,
    );
    expect(
      route(location: '/reset-password', signedIn: true, onboarded: true),
      '/dashboard',
    );
  });
}
