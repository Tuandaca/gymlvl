import 'dart:convert';
import 'package:app/core/config/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String token(String role) =>
      'header.${base64Url.encode(utf8.encode(jsonEncode({'role': role})))}.signature';
  test('client accepts only publishable or legacy anon keys', () {
    expect(SupabaseConfig.isPublicClientKey('sb_publishable_example'), isTrue);
    expect(SupabaseConfig.isPublicClientKey(token('anon')), isTrue);
    expect(SupabaseConfig.isPublicClientKey(token('service_role')), isFalse);
    expect(SupabaseConfig.isPublicClientKey('sb_secret_example'), isFalse);
    expect(SupabaseConfig.isPublicClientKey(''), isFalse);
    expect(SupabaseConfig.isPublicClientKey('invalid'), isFalse);
  });
}
