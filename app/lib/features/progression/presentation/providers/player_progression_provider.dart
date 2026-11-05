// Unified player-progression provider. Calls the server-authoritative
// `get_player_progression()` RPC and exposes one canonical player state:
// Class, Level, current XP, XP to next level, streak, active quests,
// recent achievements, next milestone/unlock.
//
// All values are derived from `auth.uid()` only. The client never submits
// XP, level, quest completion, achievement, unlock or streak values —
// `complete_workout` remains the sole authoritative reward path.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

part 'player_progression_provider.g.dart';

/// Canonical player-progression state aggregated from the server.
///
/// Fields:
/// - [userId], [level], [totalXP], [currentTitle], [lastWorkoutDate]
/// - [streak] (raw JSON from `public.streaks`)
/// - [achievements] (list of earned achievement rows)
/// - [classes] (list of user class rows with currentXP/level)
/// - [activeQuest] (today's active quest instance, or null)
/// - [nextUnlock] (next not-yet-unlocked unlock definition, or null)
@riverpod
class PlayerProgressionController extends _$PlayerProgressionController {
  @override
  FutureOr<Map<String, dynamic>?> build() async {
    final userId = ref.watch(
      authStateStreamProvider.select((state) => state.value?.session?.user.id),
    );
    if (userId == null) return null;
    return _fetch();
  }

  Future<Map<String, dynamic>?> _fetch() async {
    final data = await SupabaseConfig.client.rpc('get_player_progression');
    return data == null ? null : Map<String, dynamic>.from(data as Map);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
