import 'dart:async';
import 'dart:convert';

import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/workout/data/supabase_workout_repository.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:app/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:app/features/workout/presentation/screens/workout_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Existing Supabase HTTP transport dependency, used only for synthetic requests.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'session_isolation_test.dart' as auth_fixture;
import 'workout_controller_test.dart' as workout_fixture;
import 'workout_widgets_test.dart' show FixedLanguage;

http.Response jsonResponse(
  http.Request request,
  Object? body, [
  int status = 200,
]) => http.Response(
  jsonEncode(body),
  status,
  request: request,
  headers: {'content-type': 'application/json'},
);

class PendingUiRepository extends workout_fixture.FakeRepository {
  int hydrations = 0;

  @override
  Future<WorkoutCompletion> finishWorkout(
    String workoutId, {
    String? notes,
  }) async {
    finishes++;
    throw WorkoutReconciliationRequired(
      WorkoutReceipt(workoutId, active.userId, {'earnedXP': 0}),
    );
  }

  @override
  Future<WorkoutCompletion> reconcileCompletion(WorkoutReceipt receipt) async {
    hydrations++;
    return WorkoutCompletion(
      active.copyWith(
        status: WorkoutStatus.completed,
        completedAt: DateTime.now().toUtc(),
        durationSeconds: 7,
      ),
      receipt.rewards,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SupabaseClient client;
  late SupabaseWorkoutRepository repository;
  late ProviderContainer container;
  late StreamController<AuthState> events;
  late Workout active;
  Workout? detail;
  Object? malformedDetail;
  late Object? acknowledgement;
  late String rpcMode;
  late bool detailError;
  late int rpcCalls;
  late int detailCalls;
  late int writes;
  late List<String> requestedIds;
  Completer<void>? detailEntered;
  Completer<void>? detailGate;

  Future<void> identity(String id) async {
    final session = auth_fixture.session(id);
    await client.auth.setInitialSession(jsonEncode(session.toJson()));
    events.add(AuthState(AuthChangeEvent.signedIn, session));
    await Future<void>.delayed(Duration.zero);
    await container.pump();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    active = workout_fixture.fixture().copyWith(
      startedAt: DateTime.now().toUtc().subtract(const Duration(seconds: 120)),
      trainingStartedAt: DateTime.now().toUtc().subtract(
        const Duration(seconds: 120),
      ),
    );
    detail = active.copyWith(
      status: WorkoutStatus.completed,
      completedAt: DateTime.now().toUtc(),
      durationSeconds: 7,
    );
    acknowledgement = {
      'earnedXP': 0,
      'totalXP': 0,
      'newLevel': 1,
      'leveledUp': false,
    };
    rpcMode = 'ok';
    detailError = false;
    malformedDetail = null;
    rpcCalls = 0;
    detailCalls = 0;
    writes = 0;
    requestedIds = [];
    detailEntered = null;
    detailGate = null;
    client = SupabaseClient(
      'https://synthetic.invalid',
      'synthetic-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/rpc/start_workout')) {
          return jsonResponse(request, active.toJson());
        }
        if (path.endsWith('/rpc/complete_workout')) {
          rpcCalls++;
          requestedIds.add(
            (jsonDecode(request.body) as Map)['p_workout_id'] as String,
          );
          if (rpcMode == 'lost') {
            throw http.ClientException('synthetic lost response');
          }
          if (rpcMode == 'reject') {
            return jsonResponse(request, {
              'code': '22023',
              'message': 'synthetic validation rejection',
            }, 400);
          }
          return jsonResponse(request, acknowledgement);
        }
        if (path.endsWith('/workouts')) {
          detailCalls++;
          detailEntered?.complete();
          await detailGate?.future;
          if (detailError) {
            return jsonResponse(request, {
              'message': 'synthetic unavailable',
            }, 503);
          }
          return jsonResponse(request, malformedDetail ?? detail?.toJson());
        }
        if (path.endsWith('/workout_sets')) {
          writes++;
          return jsonResponse(
            request,
            active.exercises.first.sets.first.toJson(),
          );
        }
        throw StateError('Unexpected synthetic HTTP request $path');
      }),
    );
    repository = SupabaseWorkoutRepository(client);
    events = StreamController<AuthState>.broadcast();
    container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((ref) => events.stream),
        workoutRepositoryProvider.overrideWithValue(repository),
        localizationModeProvider.overrideWith(
          () => FixedLanguage(AppLangMode.en),
        ),
      ],
    );
    container.listen(activeWorkoutControllerProvider, (_, _) {});
    await identity('user');
    expect(await repository.startWorkout(), active);
  });

  tearDown(() async {
    container.dispose();
    await events.close();
    await client.dispose();
  });

  for (final missing in [false, true]) {
    test(
      'acknowledged award with detail ${missing ? 'null' : 'error'} reconciles without a second RPC',
      () async {
        final controller = container.read(
          activeWorkoutControllerProvider.notifier,
        );
        await controller.startWorkout();
        detailError = !missing;
        if (missing) detail = null;
        expect(await controller.completeWorkout(), isNull);
        expect(
          container.read(activeWorkoutControllerProvider).errorMessage,
          'completion_pending',
        );
        expect(
          container.read(activeWorkoutControllerProvider).workout?.status,
          WorkoutStatus.active,
        );
        await controller.updateSet('exercise', 'set', reps: 15);
        await controller.cancelWorkout();
        expect(writes, 0);
        detailError = false;
        detail = active.copyWith(
          status: WorkoutStatus.completed,
          completedAt: DateTime.now().toUtc(),
          durationSeconds: 7,
        );
        final result = await controller.completeWorkout();
        expect(result?['workout'], detail);
        expect(result?['durationSeconds'], 7);
        expect((result?['xpResult'] as Map?)?['earnedXP'], 0);
        expect(rpcCalls, 1);
        expect(detailCalls, 2);
      },
    );
  }

  test(
    'hydrated server duration wins over the 120-second local timer',
    () async {
      final controller = container.read(
        activeWorkoutControllerProvider.notifier,
      );
      await controller.startWorkout();
      expect(
        container.read(activeWorkoutControllerProvider).elapsedSeconds,
        greaterThanOrEqualTo(120),
      );
      final result = await controller.completeWorkout();
      expect(result?['durationSeconds'], 7);
      expect(result?['workout'], detail);
      expect((result?['xpResult'] as Map?)?['earnedXP'], 0);
    },
  );

  test(
    'repository retains the exact rewards-only receipt when detail decoding fails',
    () async {
      acknowledgement = {'earnedXP': 0, 'alreadyAwarded': true};
      malformedDetail = {'id': 42};
      try {
        await repository.finishWorkout(active.id);
        fail('Malformed detail must require reconciliation');
      } on WorkoutReconciliationRequired catch (error) {
        expect(error.receipt.workoutId, active.id);
        expect(error.receipt.userId, 'user');
        expect(error.receipt.rewards, acknowledgement);
        expect(
          () => error.receipt.rewards['earnedXP'] = 100,
          throwsUnsupportedError,
        );
      }
      expect(rpcCalls, 1);
    },
  );

  test(
    'reload reconciles acknowledged detail instead of querying the active session',
    () async {
      final controller = container.read(
        activeWorkoutControllerProvider.notifier,
      );
      await controller.startWorkout();
      detailError = true;
      await controller.completeWorkout();
      expect(controller.completionNeedsRecovery, isTrue);
      controller.clearError();
      expect(
        container.read(activeWorkoutControllerProvider).errorMessage,
        'completion_pending',
      );
      detailError = false;
      await controller.checkForActiveWorkout();
      expect(rpcCalls, 1);
      expect(detailCalls, 2);
      expect(container.read(activeWorkoutControllerProvider).workout, isNull);
      expect(controller.completionNeedsRecovery, isFalse);
    },
  );

  for (final invalid in ['id', 'owner', 'status']) {
    test(
      'mismatched hydrated $invalid remains pending, never a completed receipt',
      () async {
        detail = switch (invalid) {
          'id' => detail!.copyWith(id: 'other-workout'),
          'owner' => detail!.copyWith(userId: 'other-user'),
          _ => detail!.copyWith(status: WorkoutStatus.active),
        };
        final controller = container.read(
          activeWorkoutControllerProvider.notifier,
        );
        await controller.startWorkout();
        expect(await controller.completeWorkout(), isNull);
        expect(
          container.read(activeWorkoutControllerProvider).errorMessage,
          'completion_pending',
        );
        expect(rpcCalls, 1);
      },
    );
  }

  for (final invalid in [
    null,
    <String, Object>{},
    {'earnedXP': -1},
    {'earnedXP': 'zero'},
  ]) {
    test(
      'invalid reward acknowledgement $invalid cannot confirm completion',
      () async {
        acknowledgement = invalid;
        final controller = container.read(
          activeWorkoutControllerProvider.notifier,
        );
        await controller.startWorkout();
        expect(await controller.completeWorkout(), isNull);
        expect(
          container.read(activeWorkoutControllerProvider).errorMessage,
          'completion_uncertain',
        );
        expect(
          container.read(activeWorkoutControllerProvider).hasActiveWorkout,
          isTrue,
        );
        expect(detailCalls, 0);
      },
    );
  }

  for (final mode in ['reject', 'lost']) {
    test('$mode response is not a confirmed completion', () async {
      rpcMode = mode;
      final controller = container.read(
        activeWorkoutControllerProvider.notifier,
      );
      await controller.startWorkout();
      expect(await controller.completeWorkout(), isNull);
      expect(
        container.read(activeWorkoutControllerProvider).errorMessage,
        mode == 'reject' ? 'completion_rejected' : 'completion_uncertain',
      );
      expect(detailCalls, 0);
      if (mode == 'lost') {
        await controller.updateSet('exercise', 'set', reps: 15);
        expect(writes, 0);
        rpcMode = 'ok';
        acknowledgement = {'earnedXP': 0, 'alreadyAwarded': true};
        expect(await controller.completeWorkout(), isNotNull);
        expect(requestedIds, ['workout', 'workout']);
        // This proves request identity, not database commit/award counts.
      }
    });
  }

  test(
    'identity B cannot receive A acknowledgement after a delayed detail read',
    () async {
      final controller = container.read(
        activeWorkoutControllerProvider.notifier,
      );
      await controller.startWorkout();
      detailEntered = Completer<void>();
      detailGate = Completer<void>();
      final pending = controller.completeWorkout();
      await detailEntered!.future;
      await identity('b');
      detailGate!.complete();
      expect(await pending, isNull);
      expect(container.read(activeWorkoutControllerProvider).workout, isNull);
      expect(
        container.read(activeWorkoutControllerProvider).errorMessage,
        isNull,
      );
    },
  );

  testWidgets(
    'rendered finish receives completed server workout and seven-second duration',
    (tester) async {
      // Transport behavior is covered above; this exercises the actual screen callback
      // and controller with a deterministic repository under the widget-test clock.
      final uiRepository = workout_fixture.FakeRepository()
        ..active = active.copyWith(durationSeconds: 7);
      final uiContainer = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWith((ref) => const Stream.empty()),
          workoutRepositoryProvider.overrideWithValue(uiRepository),
          localizationModeProvider.overrideWith(
            () => FixedLanguage(AppLangMode.en),
          ),
        ],
      );
      addTearDown(uiContainer.dispose);
      final controller = uiContainer.read(
        activeWorkoutControllerProvider.notifier,
      );
      await controller.startWorkout();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: uiContainer,
          child: const MaterialApp(home: ActiveWorkoutScreen()),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Finish').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
      await tester.pumpAndSettle();
      final summary = tester.widget<WorkoutSummaryScreen>(
        find.byType(WorkoutSummaryScreen),
      );
      expect(summary.workout.status, WorkoutStatus.completed);
      expect(summary.workout.id, active.id);
      expect(summary.durationSeconds, 7);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final language in [AppLangMode.en, AppLangMode.vi]) {
    testWidgets('pending receipt renders and reloads safely in ${language.name}', (
      tester,
    ) async {
      final uiRepository = PendingUiRepository()..active = active;
      final uiContainer = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWith((ref) => const Stream.empty()),
          workoutRepositoryProvider.overrideWithValue(uiRepository),
          localizationModeProvider.overrideWith(() => FixedLanguage(language)),
        ],
      );
      addTearDown(uiContainer.dispose);
      final controller = uiContainer.read(
        activeWorkoutControllerProvider.notifier,
      );
      await controller.startWorkout();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: uiContainer,
          child: const MaterialApp(home: ActiveWorkoutScreen()),
        ),
      );
      await tester.pump();
      final finishLabel = language == AppLangMode.en ? 'Finish' : 'Hoàn thành';
      await tester.tap(find.text(finishLabel).first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, finishLabel));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutSummaryScreen), findsNothing);
      expect(find.byType(MaterialBanner), findsOneWidget);
      expect(
        find.text(
          language == AppLangMode.en
              ? 'Rewards were acknowledged. Reload completed session details before continuing.'
              : 'Đã nhận xác nhận phần thưởng. Tải lại chi tiết buổi tập đã hoàn thành trước khi tiếp tục.',
        ),
        findsOneWidget,
      );
      final reload = language == AppLangMode.en
          ? 'Reload completion receipt'
          : 'Tải lại kết quả hoàn thành';
      await tester.tap(find.text(reload).first);
      await tester.pumpAndSettle();
      final summary = tester.widget<WorkoutSummaryScreen>(
        find.byType(WorkoutSummaryScreen),
      );
      expect(summary.workout.status, WorkoutStatus.completed);
      expect(summary.durationSeconds, 7);
      expect(uiRepository.finishes, 1);
      expect(uiRepository.hydrations, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
