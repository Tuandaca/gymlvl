/// Provider for fetching AI Personal Trainer recommendations.
///
/// Requests advice from the server-authoritative AI coach Edge Function.
/// The current Edge response is text only, so no structured action is exposed.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/localization/localization_engine.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/pt_recommendation.dart';

final ptCoachClientProvider = Provider<SupabaseClient>(
  (ref) => SupabaseConfig.client,
);

/// Provider for fetching AI PT recommendations.
final ptRecommendationProvider = FutureProvider<PtRecommendation>((ref) async {
  final userId = ref.watch(
    authStateStreamProvider.select((auth) => auth.value?.session?.user.id),
  );
  if (userId == null) throw Exception('auth_required');
  final language = await ref
      .read(localizationModeProvider.notifier)
      .settledMode();

  final response = await ref
      .read(ptCoachClientProvider)
      .functions
      .invoke(
        'ai-coach',
        body: {
          'message': _buildPrompt(language),
          'history':
              [], // session-only history for P6; persistent chat deferred
          'consent': true,
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

  // A plain answer carries neither validated actions nor model confidence.
  return PtRecommendation(
    summary: answer.trim(),
    reasoning: const [],
    recommendations: const [],
    warnings: const [],
    confidence: 0,
    isValidated: false,
  );
});

/// Asks the server to use its own verified, bounded workout context.
///
/// The client context is never sent upstream: the Edge Function builds it from
/// the authenticated account, and no internal account UUID is needed here.
String _buildPrompt(AppLangMode language) {
  final buf = StringBuffer();
  buf.write('You are GymLevel AI Personal Trainer. ');
  buf.write(switch (language) {
    AppLangMode.vi => 'Respond in Vietnamese. ',
    AppLangMode.en => 'Respond in English. ',
    AppLangMode.bilingual => 'Respond in Vietnamese, then English. ',
  });
  buf.write('Give concise, conservative workout guidance. ');
  buf.write('Never diagnose, prescribe medication, or encourage training ');
  buf.write('through significant pain or injury. ');
  buf.write('Distinguish suggestions from saved workout facts. ');
  buf.write('Do not claim to change workouts, XP, quests or records. ');
  buf.write('Use only the verified server context. ');
  buf.write('Provide a personalized training recommendation.');
  return buf.toString();
}
