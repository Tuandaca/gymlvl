import 'dart:async';
import 'dart:convert';

import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/workout/data/supabase_workout_repository.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Existing Supabase HTTP transport dependency, used only for synthetic requests.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _started = DateTime.utc(2026, 11, 13);

Workout _workout({List<WorkoutExercise> exercises = const []}) => Workout(
  id: 'workout-a',
  userId: 'owner-a',
  startedAt: _started,
  exercises: exercises,
);

Workout _orderedWorkout() => _workout(
  exercises: [
    for (var i = 0; i < 3; i++)
      WorkoutExercise(
        id: 'we-$i',
        workoutId: 'workout-a',
        exerciseId: 'exercise-$i',
        orderIndex: i,
      ),
  ],
);

const _catalogExercise = Exercise(
  id: 'catalog-a',
  name: 'Bench press',
  category: 'Strength',
  equipment: 'Barbell',
);

AuthState _signedIn(String userId) => AuthState(
  AuthChangeEvent.signedIn,
  Session(
    accessToken: 'synthetic-token',
    tokenType: 'bearer',
    user: User(
      id: userId,
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-11-13T00:00:00Z',
    ),
  ),
);

class _FaultyWorkoutRepository extends Fake
    implements WorkoutRepository, AtomicWorkoutMutationRepository {
  Workout remote = _workout();
  int? failSetNumber;
  bool failPreviousSetLookup = false;
  bool failCleanup = false;
  bool failReorderAfterFirstWrite = false;
  bool loseAddAckOnce = false;
  bool loseReorderAckOnce = false;
  bool failDetailReadOnce = false;
  WorkoutSet? suggestedSet;
  int lastSetLookups = 0;
  int legacyExerciseWrites = 0;
  int legacySetWrites = 0;
  int legacyReorderWrites = 0;
  int atomicAddCalls = 0;
  int atomicReorderCalls = 0;
  List<Map<String, Object>>? lastAtomicSets;
  final List<String> addOperationIds = [];
  final List<List<Map<String, Object>>> addPayloads = [];
  final List<String> reorderOperationIds = [];
  Completer<void>? addEntered;
  Completer<void>? addGate;

  @override
  Future<Workout> addExerciseWithDefaultSets({
    required String operationId,
    required String workoutId,
    required String exerciseId,
    required WorkoutMode? mode,
    required List<Map<String, Object>> sets,
  }) async {
    atomicAddCalls++;
    lastAtomicSets = sets;
    addOperationIds.add(operationId);
    addPayloads.add(sets.map((set) => Map<String, Object>.from(set)).toList());
    addEntered?.complete();
    await addGate?.future;
    if (failSetNumber != null) throw StateError('injected_set_failure');
    if (remote.exercises.any((item) => item.exerciseId == exerciseId)) {
      return remote;
    }
    final item = WorkoutExercise(
      id: 'new-exercise',
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: remote.exercises.length,
      mode: mode,
      sets: [
        for (var i = 0; i < sets.length; i++)
          WorkoutSet(
            id: 'set-${i + 1}',
            workoutExerciseId: 'new-exercise',
            setNumber: i + 1,
            reps: sets[i]['reps']! as int,
            weightKg: (sets[i]['weight_kg']! as num).toDouble(),
            durationSeconds: sets[i]['duration_seconds']! as int,
          ),
      ],
    );
    remote = remote.copyWith(exercises: [...remote.exercises, item]);
    if (loseAddAckOnce) {
      loseAddAckOnce = false;
      throw StateError('injected_lost_add_ack');
    }
    return remote;
  }

  @override
  Future<Workout> reorderWorkoutExercisesAtomically({
    required String operationId,
    required String workoutId,
    required List<String> exerciseIds,
  }) async {
    atomicReorderCalls++;
    reorderOperationIds.add(operationId);
    if (failReorderAfterFirstWrite) {
      throw StateError('injected_second_update_failure');
    }
    remote = remote.copyWith(
      exercises: [
        for (var index = 0; index < exerciseIds.length; index++)
          remote.exercises
              .firstWhere((item) => item.id == exerciseIds[index])
              .copyWith(orderIndex: index),
      ],
    );
    if (loseReorderAckOnce) {
      loseReorderAckOnce = false;
      throw StateError('injected_lost_reorder_ack');
    }
    return remote;
  }

  @override
  Future<Workout> startWorkout() async => remote;

  @override
  Future<Workout?> getActiveWorkout() async => remote;

  @override
  Future<Workout?> getWorkoutDetail(String workoutId) async {
    if (failDetailReadOnce) {
      failDetailReadOnce = false;
      throw StateError('injected_detail_unavailable');
    }
    return remote;
  }

  @override
  Future<WorkoutSet?> getLastSetForExercise(String exerciseId) async {
    lastSetLookups++;
    if (failPreviousSetLookup) throw StateError('injected_lookup_failure');
    return suggestedSet;
  }

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  ) async {
    legacyExerciseWrites++;
    final item = WorkoutExercise(
      id: 'new-exercise',
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );
    remote = remote.copyWith(exercises: [...remote.exercises, item]);
    return item;
  }

  @override
  Future<WorkoutSet> addSet(
    String workoutExerciseId,
    int setNumber,
    int reps,
    double weightKg, {
    double baselineWeightKg = 0,
    int durationSeconds = 0,
  }) async {
    legacySetWrites++;
    if (setNumber == failSetNumber) throw StateError('injected_set_failure');
    final set = WorkoutSet(
      id: 'set-$setNumber',
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      reps: reps,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
    );
    remote = remote.copyWith(
      exercises: [
        for (final item in remote.exercises)
          item.id == workoutExerciseId
              ? item.copyWith(sets: [...item.sets, set])
              : item,
      ],
    );
    return set;
  }

  @override
  Future<WorkoutSet> updateSet(
    String setId, {
    int? reps,
    double? weightKg,
    WorkoutSetType? setType,
    bool? isCompleted,
    int? restSeconds,
    int? durationSeconds,
  }) async {
    throw StateError('injected_unrelated_set_update_failure');
  }

  @override
  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {
    if (failCleanup) throw StateError('injected_cleanup_failure');
    remote = remote.copyWith(
      exercises: remote.exercises
          .where((item) => item.id != workoutExerciseId)
          .toList(),
    );
  }

  @override
  Future<void> reorderExercises(String workoutId, List<String> ids) async {
    legacyReorderWrites++;
    if (failReorderAfterFirstWrite) {
      final firstId = ids.first;
      remote = remote.copyWith(
        exercises: [
          for (final item in remote.exercises)
            item.id == firstId ? item.copyWith(orderIndex: 0) : item,
        ],
      );
      throw StateError('injected_second_update_failure');
    }
    remote = remote.copyWith(
      exercises: [
        for (var index = 0; index < ids.length; index++)
          remote.exercises
              .firstWhere((item) => item.id == ids[index])
              .copyWith(orderIndex: index),
      ],
    );
  }
}

class _LegacyOnlyRepository extends Fake implements WorkoutRepository {
  int writes = 0;

  @override
  Future<Workout> startWorkout() async => _orderedWorkout();

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  ) async {
    writes++;
    throw StateError('legacy_add_should_not_run');
  }

  @override
  Future<void> reorderExercises(String workoutId, List<String> ids) async {
    writes++;
    throw StateError('legacy_reorder_should_not_run');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FaultyWorkoutRepository repository;
  late ProviderContainer container;
  late ActiveWorkoutController controller;

  setUp(() {
    repository = _FaultyWorkoutRepository();
    container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((_) => const Stream.empty()),
        workoutRepositoryProvider.overrideWithValue(repository),
        restClockProvider.overrideWithValue(() => _started),
      ],
    );
    controller = container.read(activeWorkoutControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  test(
    'reorder failure reconciles local order to the server snapshot',
    () async {
      repository.remote = _orderedWorkout();
      repository.failReorderAfterFirstWrite = true;
      await controller.startWorkout();

      await controller.reorderExercises(0, 3);

      final local = container.read(activeWorkoutControllerProvider);
      expect(local.errorMessage, 'save_failed');
      expect(
        local.exercises.map((item) => item.id),
        repository.remote.exercises.map((item) => item.id),
      );
      expect(
        local.exercises.map((item) => item.orderIndex),
        repository.remote.exercises.map((item) => item.orderIndex),
      );
      expect(repository.atomicReorderCalls, 1);
      expect(repository.legacyReorderWrites, 0);
    },
  );

  for (final failingSet in [1, 2, 3]) {
    test(
      'failed set $failingSet with failed cleanup cannot leave a partial exercise',
      () async {
        repository.failSetNumber = failingSet;
        repository.failCleanup = true;
        await controller.startWorkout();

        await controller.addExercise(_catalogExercise);

        final local = container.read(activeWorkoutControllerProvider);
        expect(local.errorMessage, 'save_failed');
        expect(repository.remote.exercises, isEmpty);
        expect(local.exercises, isEmpty);
        expect(repository.atomicAddCalls, 1);
        expect(repository.legacyExerciseWrites, 0);
        expect(repository.legacySetWrites, 0);
      },
    );
  }

  test('failed suggestion lookup cannot leave a partial exercise', () async {
    repository.failPreviousSetLookup = true;
    repository.failCleanup = true;
    await controller.startWorkout();

    await controller.addExercise(_catalogExercise);

    final local = container.read(activeWorkoutControllerProvider);
    expect(local.errorMessage, 'save_failed');
    expect(repository.remote.exercises, isEmpty);
    expect(local.exercises, isEmpty);
    expect(repository.atomicAddCalls, 0);
    expect(repository.legacyExerciseWrites, 0);
    expect(repository.legacySetWrites, 0);
  });

  test('successful add acknowledges all default sets in one call', () async {
    await controller.startWorkout();
    await controller.addExercise(_catalogExercise);

    final local = container.read(activeWorkoutControllerProvider);
    expect(local.errorMessage, isNull);
    expect(local.exercises, hasLength(1));
    expect(local.exercises.single.sets, hasLength(3));
    expect(repository.atomicAddCalls, 1);
    expect(repository.legacyExerciseWrites, 0);
    expect(repository.legacySetWrites, 0);
    expect(repository.lastAtomicSets, hasLength(3));
    expect(repository.lastAtomicSets!.first, {
      'reps': 10,
      'weight_kg': 0.0,
      'duration_seconds': 0,
    });
  });

  test('lost add ACK is confirmed by authoritative reload', () async {
    repository.loseAddAckOnce = true;
    await controller.startWorkout();

    await controller.addExercise(_catalogExercise);

    final local = container.read(activeWorkoutControllerProvider);
    expect(local.errorMessage, isNull);
    expect(local.exercises, hasLength(1));
    expect(local.exercises.single.sets, hasLength(3));
    expect(repository.atomicAddCalls, 1);
    expect(repository.legacyExerciseWrites, 0);
    expect(repository.legacySetWrites, 0);
  });

  test('uncertain add retry preserves operation ID and frozen sets', () async {
    repository.loseAddAckOnce = true;
    repository.failDetailReadOnce = true;
    await controller.startWorkout();

    await controller.addExercise(_catalogExercise);
    expect(
      container.read(activeWorkoutControllerProvider).errorMessage,
      'save_failed',
    );
    expect(container.read(activeWorkoutControllerProvider).exercises, isEmpty);
    repository.suggestedSet = const WorkoutSet(
      id: 'later-history',
      workoutExerciseId: 'prior-exercise',
      reps: 8,
      weightKg: 80,
    );

    await controller.addExercise(_catalogExercise);

    final local = container.read(activeWorkoutControllerProvider);
    expect(local.errorMessage, isNull);
    expect(local.exercises.single.sets, hasLength(3));
    expect(repository.addOperationIds, hasLength(2));
    expect(repository.addOperationIds[1], repository.addOperationIds[0]);
    expect(repository.addPayloads[1], repository.addPayloads[0]);
    expect(repository.lastSetLookups, 1);
    expect(repository.atomicAddCalls, 2);
    expect(repository.legacyExerciseWrites, 0);
    expect(repository.legacySetWrites, 0);
    await controller.completeWorkout();
    expect(
      container.read(activeWorkoutControllerProvider).errorMessage,
      isNot('reload_required'),
    );
  });

  test('lost reorder ACK is confirmed by authoritative reload', () async {
    repository.remote = _orderedWorkout();
    repository.loseReorderAckOnce = true;
    await controller.startWorkout();

    await controller.reorderExercises(0, 3);

    final local = container.read(activeWorkoutControllerProvider);
    expect(local.errorMessage, isNull);
    expect(local.exercises.map((item) => item.id), ['we-1', 'we-2', 'we-0']);
    expect(repository.atomicReorderCalls, 1);
    expect(repository.legacyReorderWrites, 0);
  });

  test('uncertain reorder retry preserves operation ID', () async {
    repository.remote = _orderedWorkout();
    repository.loseReorderAckOnce = true;
    repository.failDetailReadOnce = true;
    await controller.startWorkout();

    await controller.reorderExercises(0, 3);
    expect(
      container.read(activeWorkoutControllerProvider).errorMessage,
      'save_failed',
    );
    expect(
      container
          .read(activeWorkoutControllerProvider)
          .exercises
          .map((item) => item.id),
      ['we-0', 'we-1', 'we-2'],
    );

    await controller.reorderExercises(0, 3);

    final local = container.read(activeWorkoutControllerProvider);
    expect(local.errorMessage, isNull);
    expect(local.exercises.map((item) => item.id), ['we-1', 'we-2', 'we-0']);
    expect(repository.reorderOperationIds, hasLength(2));
    expect(
      repository.reorderOperationIds[1],
      repository.reorderOperationIds[0],
    );
    expect(repository.legacyReorderWrites, 0);
    await controller.completeWorkout();
    expect(
      container.read(activeWorkoutControllerProvider).errorMessage,
      isNot('reload_required'),
    );
  });

  test(
    'successful atomic add cannot clear an unrelated failed set edit',
    () async {
      repository.remote = _workout(
        exercises: [
          WorkoutExercise(
            id: 'existing-exercise',
            workoutId: 'workout-a',
            exerciseId: 'existing-catalog',
            sets: [
              const WorkoutSet(
                id: 'existing-set',
                workoutExerciseId: 'existing-exercise',
                reps: 10,
                weightKg: 20,
              ),
            ],
          ),
        ],
      );
      await controller.startWorkout();

      await controller.updateSet('existing-exercise', 'existing-set', reps: 11);
      expect(
        container.read(activeWorkoutControllerProvider).errorMessage,
        'save_failed',
      );

      await controller.addExercise(_catalogExercise);
      expect(repository.atomicAddCalls, 1);
      await controller.completeWorkout();
      expect(
        container.read(activeWorkoutControllerProvider).errorMessage,
        'reload_required',
      );
    },
  );

  test(
    'missing atomic capability fails closed without legacy writes',
    () async {
      final legacy = _LegacyOnlyRepository();
      final legacyContainer = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWith((_) => const Stream.empty()),
          workoutRepositoryProvider.overrideWithValue(legacy),
          restClockProvider.overrideWithValue(() => _started),
        ],
      );
      addTearDown(legacyContainer.dispose);
      final legacyController = legacyContainer.read(
        activeWorkoutControllerProvider.notifier,
      );
      await legacyController.startWorkout();

      await legacyController.addExercise(_catalogExercise);
      expect(
        legacyContainer.read(activeWorkoutControllerProvider).errorMessage,
        'save_failed',
      );
      expect(legacy.writes, 0);

      await legacyController.reorderExercises(0, 3);
      final state = legacyContainer.read(activeWorkoutControllerProvider);
      expect(state.errorMessage, 'save_failed');
      expect(state.exercises.map((item) => item.id), ['we-0', 'we-1', 'we-2']);
      expect(legacy.writes, 0);
    },
  );

  test('account switch ignores an old in-flight atomic add response', () async {
    SharedPreferences.setMockInitialValues({});
    final authEvents = StreamController<AuthState>.broadcast();
    addTearDown(authEvents.close);
    final oldRepository = _FaultyWorkoutRepository()
      ..addEntered = Completer<void>()
      ..addGate = Completer<void>();
    final ownerContainer = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((ref) => authEvents.stream),
        workoutRepositoryProvider.overrideWithValue(oldRepository),
        restClockProvider.overrideWithValue(() => _started),
      ],
    );
    addTearDown(ownerContainer.dispose);
    ownerContainer.listen(activeWorkoutControllerProvider, (_, _) {});
    authEvents.add(_signedIn('owner-a'));
    await ownerContainer.pump();
    final ownerController = ownerContainer.read(
      activeWorkoutControllerProvider.notifier,
    );
    await ownerController.startWorkout();
    final pending = ownerController.addExercise(_catalogExercise);
    await oldRepository.addEntered!.future;

    authEvents.add(_signedIn('owner-b'));
    await ownerContainer.pump();
    oldRepository.addGate!.complete();
    await pending;

    final newOwnerState = ownerContainer.read(activeWorkoutControllerProvider);
    expect(newOwnerState.workout, isNull);
    expect(newOwnerState.exercises, isEmpty);
    expect(oldRepository.remote.exercises, hasLength(1));
  });

  test(
    'local backup cannot clear failed-write fence without server read',
    () async {
      SharedPreferences.setMockInitialValues({});
      final restoreRepository = _FaultyWorkoutRepository()
        ..remote = _workout(
          exercises: [
            WorkoutExercise(
              id: 'existing-exercise',
              workoutId: 'workout-a',
              exerciseId: 'existing-catalog',
              sets: [
                const WorkoutSet(
                  id: 'existing-set',
                  workoutExerciseId: 'existing-exercise',
                  reps: 10,
                  weightKg: 20,
                ),
              ],
            ),
          ],
        );
      final restoreContainer = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWithValue(
            AsyncValue.data(_signedIn('owner-a')),
          ),
          workoutRepositoryProvider.overrideWithValue(restoreRepository),
          restClockProvider.overrideWithValue(() => _started),
        ],
      );
      addTearDown(restoreContainer.dispose);
      final restoreController = restoreContainer.read(
        activeWorkoutControllerProvider.notifier,
      );
      await restoreController.startWorkout();
      await restoreController.updateSet(
        'existing-exercise',
        'existing-set',
        reps: 11,
      );
      expect(
        restoreContainer.read(activeWorkoutControllerProvider).errorMessage,
        'save_failed',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${ActiveWorkoutController.backupKey}:owner-a',
        jsonEncode({
          'workout': restoreRepository.remote.toJson(),
          'local_updated_at': DateTime.now().toUtc().toIso8601String(),
          'elapsed_seconds': 0,
        }),
      );
      restoreRepository.failDetailReadOnce = true;

      await restoreController.restoreFromLocalBackup();
      await restoreController.completeWorkout();

      final state = restoreContainer.read(activeWorkoutControllerProvider);
      expect(state.workout?.userId, 'owner-a');
      expect(state.errorMessage, 'reload_required');
    },
  );

  test('reorder adapter sends one authenticated atomic RPC', () async {
    final requests = <http.Request>[];
    final client = SupabaseClient(
      'https://p9.invalid',
      'synthetic-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'id': '95000000-0000-4000-8000-000000000062',
              'user_id': '95000000-0000-4000-8000-000000000001',
              'status': 'active',
              'workout_exercises': <Object>[],
            }),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'operation_id': body['p_operation_id'],
            'workout_id': '95000000-0000-4000-8000-000000000062',
            'exercise_count': 3,
          }),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);
    final session = Session(
      accessToken: 'synthetic-token',
      tokenType: 'bearer',
      user: User(
        id: '95000000-0000-4000-8000-000000000001',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: '2026-11-13T00:00:00Z',
      ),
    );
    await client.auth.setInitialSession(jsonEncode(session.toJson()));

    await SupabaseWorkoutRepository(
      client,
    ).reorderExercises('95000000-0000-4000-8000-000000000062', [
      '95000000-0000-4000-8000-000000000063',
      '95000000-0000-4000-8000-000000000064',
      '95000000-0000-4000-8000-000000000065',
    ]);

    expect(requests, hasLength(2));
    expect(requests.first.method, 'POST');
    expect(requests.last.method, 'GET');
    expect(
      requests.first.url.path,
      '/rest/v1/rpc/reorder_workout_exercises_v1',
    );
    final body = jsonDecode(requests.first.body) as Map<String, dynamic>;
    expect(
      body.keys,
      unorderedEquals(['p_operation_id', 'p_workout_id', 'p_exercise_ids']),
    );
    expect(body['p_workout_id'], '95000000-0000-4000-8000-000000000062');
    expect(body['p_exercise_ids'], hasLength(3));
    expect(body.containsKey('p_user_id'), isFalse);
  });

  test(
    'add adapter validates receipt before authoritative detail read',
    () async {
      const operationId = '95000000-0000-4000-8000-000000000071';
      const workoutId = '95000000-0000-4000-8000-000000000072';
      const exerciseId = '95000000-0000-4000-8000-000000000073';
      const workoutExerciseId = '95000000-0000-4000-8000-000000000074';
      const setIds = [
        '95000000-0000-4000-8000-000000000075',
        '95000000-0000-4000-8000-000000000076',
      ];
      const sets = <Map<String, Object>>[
        {'reps': 10, 'weight_kg': 20.0, 'duration_seconds': 0},
        {'reps': 9, 'weight_kg': 22.0, 'duration_seconds': 0},
      ];

      for (final malformed in [false, true]) {
        final requests = <http.Request>[];
        final client = SupabaseClient(
          'https://p9.invalid',
          'synthetic-public-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
          httpClient: MockClient((request) async {
            requests.add(request);
            if (request.method == 'GET') {
              return http.Response(
                jsonEncode({
                  'id': workoutId,
                  'user_id': '95000000-0000-4000-8000-000000000001',
                  'status': 'active',
                  'workout_exercises': [
                    {
                      'id': workoutExerciseId,
                      'workout_id': workoutId,
                      'exercise_id': exerciseId,
                      'order_index': 0,
                      'workout_sets': [
                        {
                          'id': setIds[0],
                          'workout_exercise_id': workoutExerciseId,
                          'set_number': 1,
                          'reps': 10,
                          'weight_kg': 20,
                        },
                        {
                          'id': setIds[1],
                          'workout_exercise_id': workoutExerciseId,
                          'set_number': 2,
                          'reps': 9,
                          'weight_kg': 22,
                        },
                      ],
                    },
                  ],
                }),
                200,
                request: request,
                headers: {'content-type': 'application/json'},
              );
            }
            return http.Response(
              jsonEncode({
                'operation_id': operationId,
                'workout_id': workoutId,
                'workout_exercise_id': workoutExerciseId,
                'set_ids': malformed ? [setIds[0]] : setIds,
              }),
              200,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        addTearDown(client.dispose);
        final session = Session(
          accessToken: 'synthetic-token',
          tokenType: 'bearer',
          user: User(
            id: '95000000-0000-4000-8000-000000000001',
            appMetadata: const {},
            userMetadata: const {},
            aud: 'authenticated',
            createdAt: '2026-11-13T00:00:00Z',
          ),
        );
        await client.auth.setInitialSession(jsonEncode(session.toJson()));
        final repository = SupabaseWorkoutRepository(client);

        if (malformed) {
          await expectLater(
            repository.addExerciseWithDefaultSets(
              operationId: operationId,
              workoutId: workoutId,
              exerciseId: exerciseId,
              mode: null,
              sets: sets,
            ),
            throwsA(isA<StateError>()),
          );
          expect(requests, hasLength(1));
        } else {
          final workout = await repository.addExerciseWithDefaultSets(
            operationId: operationId,
            workoutId: workoutId,
            exerciseId: exerciseId,
            mode: null,
            sets: sets,
          );
          expect(workout.exercises, hasLength(1));
          expect(workout.exercises.single.sets, hasLength(2));
          expect(requests, hasLength(2));
          expect(requests.last.method, 'GET');
        }
        expect(requests.first.method, 'POST');
        expect(
          requests.first.url.path,
          '/rest/v1/rpc/add_workout_exercise_with_sets_v1',
        );
        final body = jsonDecode(requests.first.body) as Map<String, dynamic>;
        expect(
          body.keys,
          unorderedEquals([
            'p_operation_id',
            'p_workout_id',
            'p_exercise_id',
            'p_mode',
            'p_sets',
          ]),
        );
        expect(body['p_operation_id'], operationId);
        expect(body['p_sets'], sets);
        expect(body.containsKey('p_user_id'), isFalse);
        expect(body.containsKey('p_order_index'), isFalse);
      }
    },
  );
}
