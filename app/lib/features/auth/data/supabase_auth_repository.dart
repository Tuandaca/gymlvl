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
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // After sign-up, create a blank user document in public.users if a user is created
    // Note: It's safer if Supabase trigger does this, but we can do it client-side if we own the policy
    if (res.user != null) {
      final userExists = await _supabase
          .from('users')
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();
      
      if (userExists == null) {
         await _supabase.from('users').insert({
          'id': res.user!.id,
          'email': res.user!.email,
          'created_at': DateTime.now().toUtc().toIso8601String(),
         });
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
