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

  @override
  Future<void> resetPassword(String email) async {
    const redirect = String.fromEnvironment('AUTH_REDIRECT_URL');
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: redirect.isEmpty ? null : redirect,
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
