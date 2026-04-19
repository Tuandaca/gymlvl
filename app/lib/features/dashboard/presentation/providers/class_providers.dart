import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider that fetches user's active classes from the `user_classes` table.
final userClassesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final session = ref.watch(authStateStreamProvider).value?.session;
  if (session == null) return [];

  try {
    final res = await SupabaseConfig.client
        .from('user_classes')
        .select()
        .eq('user_id', session.user.id)
        .order('slot', ascending: true); // primary first

    return List<Map<String, dynamic>>.from(res ?? []);
  } catch (e) {
    return [];
  }
});

final classControllerProvider = AsyncNotifierProvider<ClassController, void>(() {
  return ClassController();
});

class ClassController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> switchClass({required String newClassId, required String slot}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = SupabaseConfig.client.auth.currentSession;
      final token = session?.accessToken;

      if (token == null) throw Exception('No session token');

      final response = await SupabaseConfig.client.functions.invoke(
        'switch-class',
        body: {
          'new_class_id': newClassId,
          'slot': slot,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.status == 200) {
        // Refresh classes
        ref.invalidate(userClassesProvider);
      } else {
        throw Exception('Lỗi hệ thống: \${response.data?["error"] ?? "Unknown"}');
      }
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}

