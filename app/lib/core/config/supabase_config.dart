import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  static bool get isConfigured =>
      Uri.tryParse(_url)?.hasAuthority == true && isPublicClientKey(_anonKey);

  /// Fail closed if someone accidentally places a privileged key in client config.
  static bool isPublicClientKey(String key) {
    if (key.startsWith('sb_publishable_')) return true;
    if (key.startsWith('sb_secret_')) return false;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(key.split('.')[1]))),
      );
      return payload is Map && payload['role'] == 'anon';
    } catch (_) {
      return false;
    }
  }

  static Future<void> initialize() async {
    if (!isConfigured) {
      throw StateError('Provide SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.');
    }
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
