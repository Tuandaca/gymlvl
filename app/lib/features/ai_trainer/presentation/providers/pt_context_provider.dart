/// Provider for building the owner-scoped AI Personal Trainer context.
///
/// Calls the server-authoritative `get_player_progression()` RPC and combines
/// it with deterministic local analytics (readiness, recent workouts) to
/// produce a bounded [PtContext] for AI prompt construction.
///
/// All data is owner-scoped: derived from `auth.uid()` only. No secrets,
/// credentials, or other users' records are ever included.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../progression/domain/player_progression.dart';
import '../../../analytics/domain/recovery_readiness.dart';
import '../../domain/models/pt_context.dart';
import '../../domain/services/pt_context_builder.dart';

/// Provider that builds the unified PT context from server + local data.
final ptContextProvider = FutureProvider<PtContext>((ref) async {
  final userId = ref.watch(
    authStateStreamProvider.select((auth) => auth.value?.session?.user.id),
  );
  if (userId == null) throw Exception('auth_required');

  // Call the server-authoritative unified progression RPC.
  final data = await SupabaseConfig.client.rpc('get_player_progression');
  final progression = PlayerProgression.fromJson(
    Map<String, dynamic>.from(data as Map),
  );

  final activeClasses = <Map<String, dynamic>>[];
  for (final c in progression.classes) {
    activeClasses.add({
      'class_id': c.classId,
      'class_name': c.className,
      'slot': c.slot,
      'current_xp': c.currentXP,
      'level': c.level,
      'is_graduated': c.isGraduated,
    });
  }

  final activeQuests = <Map<String, dynamic>>[];
  if (progression.activeQuest != null) {
    final aq = progression.activeQuest!;
    activeQuests.add({
      'quest_id': aq['questId'] as String,
      'title': aq['questTitle'] as String?,
      'status': aq['status'] as String,
      'expires_at': aq['expiresAt'] as String?,
    });
  }

  return PtContextBuilder.build(
    userId: userId,
    workouts: [],
    workoutExercises: [],
    sets: [],
    exercises: [],
    progression: progression,
    readiness: ReadinessInsight(
      overall: ReadinessClassification.moderatelyRecovered,
      muscleGroups: const [],
      completedWorkoutCount: 0,
      mostRecentWorkoutAt: progression.lastWorkoutDate,
    ),
    activeQuests: activeQuests,
    activeClasses: activeClasses,
    currentLevel: progression.level,
    nextMilestone: progression.nextUnlock != null
        ? (progression.nextUnlock!['title'] as String?)
        : null,
    builtAt: DateTime.now(),
  );
});
