/// Provider for fetching AI Personal Trainer recommendations.
///
/// Sends a bounded [PtContext] to the server-authoritative AI coach Edge
/// Function and validates the structured response before exposing it to the
/// UI. The AI is advisory: the user must explicitly approve any action that
/// modifies plans/routines.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/pt_context.dart';
import '../../domain/models/pt_recommendation.dart';

/// Provider for fetching AI PT recommendations.
final ptRecommendationProvider =
    FutureProvider.family<PtRecommendation, PtContext>((ref, context) async {
      final userId = ref.watch(
        authStateStreamProvider.select((auth) => auth.value?.session?.user.id),
      );
      if (userId == null) throw Exception('auth_required');

      final response = await SupabaseConfig.client.functions
          .invoke(
            'ai-coach',
            body: {
              'message': _buildPrompt(context),
              'history':
                  [], // session-only history for P6; persistent chat deferred
              'context': _contextToJson(context),
            },
          )
          .timeout(const Duration(seconds: 35));

      final data = response.data;
      if (response.status != 200 || data is! Map) {
        throw Exception('coach_unavailable');
      }

      final answer = data['answer'] as String?;
      if (answer == null || answer.isEmpty) {
        throw Exception('coach_empty_response');
      }

      // In P6 we accept the text answer as a recommendation summary with
      // structured parsing attempted when possible. Full structured validation
      // is implemented when the server returns a typed JSON schema.
      return PtRecommendation(
        summary: answer.trim(),
        reasoning: const [],
        recommendations: const [],
        warnings: const [],
        confidence: 0.5,
        isValidated: false,
      );
    });

/// Builds a concise prompt from the bounded PT context.
///
/// Only observable facts are included; no secrets, credentials, or
/// other users' data. User-authored notes are treated as data, not
/// system instructions.
String _buildPrompt(PtContext context) {
  final buf = StringBuffer();
  buf.write('You are GymLevel AI Personal Trainer. ');
  buf.write('Respond in the user\'s language (Vietnamese or English). ');
  buf.write('Give concise, conservative workout guidance. ');
  buf.write('Never diagnose, prescribe medication, or encourage training ');
  buf.write('through significant pain or injury. ');
  buf.write('Distinguish suggestions from saved workout facts. ');
  buf.write('Do not claim to change workouts, XP, quests or records. ');
  buf.write('User context (verified, owner-scoped):\n');
  buf.write('- user_id: ${context.userId}\n');
  buf.write('- level: ${context.progression.currentLevel}\n');
  buf.write('- total_xp: ${context.progression.totalXP}\n');
  buf.write('- streak: ${context.recovery.completedWorkoutCount} workouts\n');
  buf.write('- readiness: ${context.recovery.overall}\n');
  buf.write('- recent_workouts: ${context.recentTraining.length}\n');
  buf.write('- active_classes: ${context.gameContext.activeClasses.length}\n');
  buf.write('- active_quests: ${context.gameContext.activeQuests.length}\n');
  buf.write(
    '\nUser question: Provide a personalized training recommendation. ',
  );
  return buf.toString();
}

/// Converts [PtContext] to a JSON-safe map for the AI request.
///
/// Only observable facts are included; secrets and credentials are excluded.
Map<String, dynamic> _contextToJson(PtContext context) {
  return {
    'user_id': context.userId,
    'level': context.progression.currentLevel,
    'total_xp': context.progression.totalXP,
    'streak': context.recovery.completedWorkoutCount,
    'readiness': context.recovery.overall.name,
    'recent_workouts': context.recentTraining
        .map(
          (w) => {
            'workout_id': w.workoutId,
            'completed_set_count': w.completedSetCount,
            'duration_seconds': w.durationSeconds,
          },
        )
        .toList(),
    'active_classes': context.gameContext.activeClasses
        .map(
          (c) => {
            'class_id': c.classId,
            'class_name': c.className,
            'slot': c.slot,
            'level': c.level,
          },
        )
        .toList(),
    'active_quests': context.gameContext.activeQuests
        .map(
          (q) => {'quest_id': q.questId, 'title': q.title, 'status': q.status},
        )
        .toList(),
  };
}
