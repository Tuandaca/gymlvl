import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/unlock.dart';

part 'unlock_providers.g.dart';

/// All unlock definitions with unlocked/locked state for the current user.
@riverpod
class UnlocksController extends _$UnlocksController {
  @override
  FutureOr<List<Unlock>> build() async {
    final userId = ref.watch(
      authStateStreamProvider.select((state) => state.value?.session?.user.id),
    );
    if (userId == null) return [];

    final defs = await SupabaseConfig.client
        .from('unlock_definitions')
        .select(
          'id,title,description,unlock_type,threshold_value,reward_type,reward_value',
        )
        .order('threshold_value');

    final unlocked = await SupabaseConfig.client
        .from('user_unlocks')
        .select('unlock_id')
        .eq('user_id', userId);

    final unlockedIds = <String>{};
    for (final u in unlocked) {
      final id = u['unlock_id'];
      if (id != null) unlockedIds.add(id.toString());
    }

    return (defs as List).map((e) {
      final id = e['id']?.toString() ?? '';
      return Unlock(
        unlockId: id,
        title: e['title']?.toString() ?? '',
        description: e['description']?.toString(),
        unlockType: e['unlock_type']?.toString() ?? '',
        thresholdValue: (e['threshold_value'] as num?)?.toInt() ?? 0,
        rewardType: e['reward_type']?.toString() ?? '',
        rewardValue: e['reward_value']?.toString() ?? '',
        isUnlocked: unlockedIds.contains(id),
      );
    }).toList()..sort((a, b) {
      // Unlocked first, then by catalogue order.
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      return a.unlockId.compareTo(b.unlockId);
    });
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
