import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Stream<AuthState> get authStateChange => _supabase.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);

    // The database Auth trigger creates identity records, including when email
    // confirmation means sign-up does not return an authenticated session.
  }

  // Mobile password reset / magic link / OAuth confirmation uses the
  // com.gymlvl.app:// custom scheme so the link opens the installed app on a
  // real device. Flutter web development uses http://localhost:8080 via the
  // AUTH_REDIRECT_URL build-time define (localhost is local-development only
  // and never used by a release mobile build).
  static const _mobileRedirect = 'com.gymlvl.app://auth-recovery';

  @override
  Future<void> resetPassword(String email) async {
    final redirect = kIsWeb
        ? (const String.fromEnvironment('AUTH_REDIRECT_URL')).isNotEmpty
              ? const String.fromEnvironment('AUTH_REDIRECT_URL')
              : null
        : _mobileRedirect;
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: redirect,
    );
  }

  @override
  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
