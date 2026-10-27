import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class CoachMessage {
  const CoachMessage(this.role, this.content);
  final String role;
  final String content;
  Map<String, String> toJson() => {'role': role, 'content': content};
}

class CoachFailure implements Exception {
  const CoachFailure(this.code);
  final String code;
}

abstract class CoachRepository {
  Future<String> ask(String message, List<CoachMessage> history);
}

class SupabaseCoachRepository implements CoachRepository {
  SupabaseCoachRepository(this.client);
  final SupabaseClient client;

  @override
  Future<String> ask(String message, List<CoachMessage> history) async {
    try {
      final response = await client.functions
          .invoke(
            'ai-coach',
            body: {
              'message': message,
              'history': history.map((m) => m.toJson()).toList(),
            },
          )
          .timeout(const Duration(seconds: 35));
      final data = response.data;
      if (response.status != 200 || data is! Map || data['answer'] is! String) {
        throw const CoachFailure('coach_unavailable');
      }
      return data['answer'] as String;
    } on FunctionException catch (error) {
      final details = error.details;
      throw CoachFailure(
        details is Map
            ? details['code']?.toString() ?? 'coach_unavailable'
            : 'coach_unavailable',
      );
    } on CoachFailure {
      rethrow;
    } catch (_) {
      throw const CoachFailure('coach_unavailable');
    }
  }
}

final coachRepositoryProvider = Provider<CoachRepository>(
  (ref) => SupabaseCoachRepository(SupabaseConfig.client),
);

class CoachState {
  const CoachState({
    this.messages = const [],
    this.sending = false,
    this.errorCode,
  });
  final List<CoachMessage> messages;
  final bool sending;
  final String? errorCode;
}

final coachControllerProvider = NotifierProvider<CoachController, CoachState>(
  CoachController.new,
);

class CoachController extends Notifier<CoachState> {
  int _generation = 0;

  @override
  CoachState build() {
    ref.watch(
      authStateStreamProvider.select((auth) => auth.value?.session?.user.id),
    );
    _generation++;
    return const CoachState();
  }

  Future<bool> send(String input) async {
    if (state.sending) return false;
    final message = input.trim();
    if (message.isEmpty || message.length > 2000) return false;
    final generation = _generation;
    final previous = state.messages;
    state = CoachState(messages: previous, sending: true);
    try {
      final history = previous
          .skip(previous.length > 8 ? previous.length - 8 : 0)
          .toList();
      final answer = await ref
          .read(coachRepositoryProvider)
          .ask(message, history);
      if (!ref.mounted || generation != _generation) return false;
      state = CoachState(
        messages: [
          ...previous,
          CoachMessage('user', message),
          CoachMessage('assistant', answer),
        ],
      );
      return true;
    } catch (error) {
      if (!ref.mounted || generation != _generation) return false;
      state = CoachState(
        messages: previous,
        errorCode: error is CoachFailure ? error.code : 'coach_unavailable',
      );
      return false;
    }
  }
}
