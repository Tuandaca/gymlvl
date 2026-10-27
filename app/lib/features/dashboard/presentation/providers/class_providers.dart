import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final userClassesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final userId = ref.watch(
    authStateStreamProvider.select((state) => state.value?.session?.user.id),
  );
  if (userId == null) return [];
  final data = await SupabaseConfig.client
      .from('user_classes')
      .select()
      .eq('user_id', userId)
      .order('slot');
  return List<Map<String, dynamic>>.from(data);
});

final classControllerProvider = AsyncNotifierProvider<ClassController, void>(
  ClassController.new,
);

class ClassController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}
  Future<void> switchClass({
    required String newClassId,
    required String slot,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await SupabaseConfig.client.rpc(
        'switch_class',
        params: {'p_new_class_id': newClassId, 'p_slot': slot},
      );
      ref.invalidate(userClassesProvider);
    });
    if (state.hasError) throw state.error!;
  }
}
