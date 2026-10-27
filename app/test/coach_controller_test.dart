import 'dart:async';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/coach/data/coach_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCoach implements CoachRepository {
  Completer<String>? pending;
  int calls = 0;
  String? failure;
  List<CoachMessage> receivedHistory = [];
  @override
  Future<String> ask(String message, List<CoachMessage> history) async {
    calls++;
    receivedHistory = history;
    if (failure != null) throw CoachFailure(failure!);
    return pending == null ? 'Rest and recover.' : pending!.future;
  }
}

void main() {
  late FakeCoach repository;
  late ProviderContainer container;
  setUp(() {
    repository = FakeCoach();
    container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((ref) => const Stream.empty()),
        coachRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('coach ignores blank and duplicate in-flight submissions', () async {
    final controller = container.read(coachControllerProvider.notifier);
    expect(await controller.send('  '), isFalse);
    repository.pending = Completer<String>();
    final pending = controller.send('How can I recover?');
    expect(await controller.send('Repeat'), isFalse);
    expect(repository.calls, 1);
    repository.pending!.complete('Rest.');
    expect(await pending, isTrue);
    expect(container.read(coachControllerProvider).messages.length, 2);
  });

  test('unconfigured coach preserves conversation and allows retry', () async {
    final controller = container.read(coachControllerProvider.notifier);
    repository.failure = 'coach_unconfigured';
    expect(await controller.send('Plan a workout'), isFalse);
    expect(container.read(coachControllerProvider).messages, isEmpty);
    expect(
      container.read(coachControllerProvider).errorCode,
      'coach_unconfigured',
    );
    repository.failure = null;
    expect(await controller.send('Plan a workout'), isTrue);
    expect(container.read(coachControllerProvider).errorCode, isNull);
  });

  test('provider context is bounded to eight previous messages', () async {
    final controller = container.read(coachControllerProvider.notifier);
    for (var i = 0; i < 6; i++) {
      await controller.send('Question $i');
    }
    expect(repository.receivedHistory.length, 8);
    expect(repository.receivedHistory.first.content, 'Question 1');
  });
}
