/// Keeps loading and failed sessions behind a gate, including deep links.
String? authRedirect({
  required String location,
  required bool loading,
  required bool hasError,
  required bool signedIn,
  required bool onboarded,
  required bool recoveringPassword,
}) {
  if (loading || hasError) return location == '/session' ? null : '/session';
  final publicAuth = location == '/login' || location == '/register';
  if (!signedIn) return publicAuth ? null : '/login';
  if (recoveringPassword) {
    return location == '/reset-password' ? null : '/reset-password';
  }
  if (!onboarded) return location == '/onboarding' ? null : '/onboarding';
  if (publicAuth ||
      location == '/' ||
      location == '/session' ||
      location == '/onboarding' ||
      location == '/reset-password') {
    return '/dashboard';
  }
  return null;
}
