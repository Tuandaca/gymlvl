import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/quest_instance.dart';
part 'quest_providers.g.dart';

@riverpod
class ActiveQuestController extends _$ActiveQuestController {
  @override
  FutureOr<QuestInstance?> build() async {
    final userId = ref.watch(
      authStateStreamProvider.select((state) => state.value?.session?.user.id),
    );
    if (userId == null) return null;
    return _fetch();
  }

  Future<QuestInstance?> _fetch() async {
    final data = await SupabaseConfig.client.rpc('sync_daily_data');
    final quest = (data as Map)['quest'];
    return quest == null
        ? null
        : QuestInstance.fromJson(Map<String, dynamic>.from(quest as Map));
  }

  Future<void> refresh() async {
    // Rebuilding lets Riverpod discard results belonging to an old identity.
    ref.invalidateSelf();
  }
}
