import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _url = 'https://shulhhxdebsfbsxcborq.supabase.co';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNodWxoaHhkZWJzZmJzeGNib3JxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3NTQ5MTMsImV4cCI6MjA5MDMzMDkxM30.4sSiGpf2M-um6-AyS5mCeJFqPlFeQSqFAln6f4kPNIo';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
