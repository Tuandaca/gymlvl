import 'dart:async';
import 'dart:convert';

import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'session_isolation_test.dart' as auth_fixture;
import 'workout_controller_test.dart' as workout_fixture;

class SnapshotRepository extends Fake implements WorkoutRepository {
  bool offline = false;
  int reads = 0;
  Workout? remote;
  Workout draft = workout_fixture
      .fixture(training: false)
      .copyWith(userId: 'b');

  Future<Workout?> fetch() async {
    reads++;
    if (offline) throw StateError('offline');
    return remote;
  }

  @override
  Future<Workout?> getActiveWorkout() => fetch();
  @override
  Future<Workout?> getWorkoutDetail(String id) => fetch();
  @override
  Future<Workout> startWorkout() async => draft;
  @override
  Future<void> cancelWorkout(String id) async {}
}

String snapshot(String owner) => jsonEncode({
  'workout': workout_fixture.fixture().copyWith(userId: owner).toJson(),
  'local_updated_at': '2026-10-26T00:00:00Z',
  'elapsed_seconds': 123,
});

String snapshotWithRest(
  String owner, {
  String workoutId = 'workout',
  int remaining = 90,
  int total = 120,
  bool paused = false,
  DateTime? deadline,
}) {
  final value = jsonDecode(snapshot(owner)) as Map<String, dynamic>;
  value['rest_timer'] = {
    'workout_id': workoutId,
    'remaining_seconds': remaining,
    'total_seconds': total,
    'paused': paused,
    'target_end_at': paused
        ? null
        : (deadline ?? DateTime.now().toUtc().add(Duration(seconds: remaining)))
              .toIso8601String(),
  };
  return jsonEncode(value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  const key = ActiveWorkoutController.backupKey;
  late Map<String, Object> disk;
  late StreamController<AuthState> events;
  late ProviderContainer container;
  late ActiveWorkoutController controller;
  late SnapshotRepository repository;
  late List<ActiveWorkoutState> observed;
  DateTime Function()? restClockOverride;
  Completer<Map<String, Object>>? readGate;
  Completer<void>? readEntered;

  setUp(() {
    SharedPreferences.resetStatic();
    disk = {};
    readGate = null;
    readEntered = null;
    restClockOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getAll') {
            readEntered?.complete();
            return readGate == null ? Map.of(disk) : await readGate!.future;
          }
          final args = call.arguments as Map;
          if (call.method == 'remove') {
            disk.remove(args['key']);
          } else if (call.method.startsWith('set')) {
            disk[args['key'] as String] = args['value'] as Object;
          } else {
            throw StateError('Unexpected preference method ${call.method}');
          }
          return true;
        });
    events = StreamController<AuthState>.broadcast();
    repository = SnapshotRepository();
    container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((ref) => events.stream),
        workoutRepositoryProvider.overrideWithValue(repository),
        restClockProvider.overrideWithValue(
          () => restClockOverride?.call() ?? DateTime.now(),
        ),
      ],
    );
    observed = [];
    container.listen(activeWorkoutControllerProvider, (_, next) {
      observed.add(next);
    });
    controller = container.read(activeWorkoutControllerProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await events.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    SharedPreferences.resetStatic();
  });

  Future<void> identity(String? id) async {
    events.add(
      AuthState(
        id == null ? AuthChangeEvent.signedOut : AuthChangeEvent.signedIn,
        id == null ? null : auth_fixture.session(id),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await container.pump();
  }

  Future<void> restore(bool explicit) => explicit
      ? controller.restoreFromLocalBackup()
      : controller.checkForActiveWorkout();

  void expectNoSnapshot() {
    expect(container.read(activeWorkoutControllerProvider).workout, isNull);
    expect(observed.where((state) => state.workout != null), isEmpty);
    expect(observed.every((state) => state.exercises.isEmpty), isTrue);
    expect(observed.every((state) => state.elapsedSeconds == 0), isTrue);
    expect(observed.every((state) => state.previewXP == 0), isTrue);
  }

  for (final explicit in [false, true]) {
    final path = explicit ? 'explicit recovery' : 'automatic recovery';
    for (final offline in [false, true]) {
      test(
        '$path rejects A under B with remote ${offline ? 'error' : 'null'}',
        () async {
          final raw = snapshot('a');
          disk['flutter.$key'] = raw;
          repository.offline = offline;
          await identity('b');
          await restore(explicit);
          expectNoSnapshot();
          expect(disk['flutter.$key'], raw);
        },
      );
    }

    for (final raw in [
      '{"workout":{"id":"legacy","started_at":"2026-10-26T00:00:00Z"}}',
      '{"workout":{"user_id":"b","started_at":false}}',
      '{not-json',
      '{"workout":42}',
      jsonEncode({
        'workout': workout_fixture.fixture().copyWith(userId: 'b').toJson(),
        'local_updated_at': 'not-a-date',
        'elapsed_seconds': 'not-a-number',
      }),
    ]) {
      test('$path preserves ownerless/malformed raw $raw', () async {
        disk['flutter.$key'] = raw;
        await identity('b');
        await restore(explicit);
        expectNoSnapshot();
        expect(disk['flutter.$key'], raw);
      });
    }

    test('$path exposes no local data without authentication', () async {
      final raw = snapshot('a');
      disk['flutter.$key'] = raw;
      await identity(null);
      await restore(explicit);
      expectNoSnapshot();
      expect(disk['flutter.$key'], raw);
    });

    test('$path restores same-owner offline data', () async {
      disk['flutter.$key'] = snapshot('a');
      repository.offline = true;
      await identity('a');
      await restore(explicit);
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.workout?.userId, 'a');
      expect(state.exercises, isNotEmpty);
      expect(state.hasActiveWorkout, isTrue);
    });

    test('$path restores a running rest countdown while offline', () async {
      disk['flutter.$key'] = snapshotWithRest('a');
      repository.offline = true;
      await identity('a');
      await restore(explicit);
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.workout?.id, 'workout');
      expect(state.isResting, isTrue);
      expect(state.isRestPaused, isFalse);
      expect(state.restSecondsRemaining, inInclusiveRange(88, 90));
      expect(state.restTargetEndTime, isNotNull);
    });

    test('$path keeps a paused rest fixed while offline', () async {
      disk['flutter.$key'] = snapshotWithRest('a', remaining: 42, paused: true);
      repository.offline = true;
      await identity('a');
      await restore(explicit);
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.isResting, isTrue);
      expect(state.isRestPaused, isTrue);
      expect(state.restSecondsRemaining, 42);
      expect(state.restTargetEndTime, isNull);
    });

    test('$path does not revive expired or wrong-workout rest', () async {
      await identity('a');
      repository.offline = true;
      disk['flutter.$key'] = snapshotWithRest(
        'a',
        deadline: DateTime.utc(2020),
      );
      await restore(explicit);
      expect(
        container.read(activeWorkoutControllerProvider).isResting,
        isFalse,
      );
      container.invalidate(activeWorkoutControllerProvider);
      controller = container.read(activeWorkoutControllerProvider.notifier);
      disk['flutter.$key'] = snapshotWithRest('a', workoutId: 'other');
      await restore(explicit);
      expect(
        container.read(activeWorkoutControllerProvider).isResting,
        isFalse,
      );
    });

    test('$path clears rest when the remote workout is absent', () async {
      await identity('a');
      disk['flutter.$key'] = snapshotWithRest('a');
      repository.remote = null;
      await restore(explicit);
      expect(
        container.read(activeWorkoutControllerProvider).isResting,
        isFalse,
      );
    });

    test('$path clears rest when the remote workout differs', () async {
      await identity('a');
      disk['flutter.$key'] = snapshotWithRest('a');
      repository.remote = workout_fixture.fixture().copyWith(
        id: 'other',
        userId: 'a',
      );
      await restore(explicit);
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.workout?.id, 'other');
      expect(state.isResting, isFalse);
    });

    test('$path ignores a foreign remote workout and clears rest', () async {
      await identity('a');
      disk['flutter.$key'] = snapshotWithRest('a');
      repository.remote = workout_fixture.fixture().copyWith(userId: 'b');
      await restore(explicit);
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.workout?.userId, 'a');
      expect(state.isResting, isFalse);
    });

    test('$path preserves rest when the remote workout matches', () async {
      await identity('a');
      disk['flutter.$key'] = snapshotWithRest('a');
      repository.remote = workout_fixture.fixture().copyWith(userId: 'a');
      await restore(explicit);
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.workout?.id, 'workout');
      expect(state.isResting, isTrue);
    });

    for (final nextOwner in <String?>[null, 'b']) {
      test(
        '$path aborts when identity changes during preference read to $nextOwner',
        () async {
          final raw = snapshot('a');
          disk['flutter.$key'] = raw;
          await identity('a');
          readEntered = Completer<void>();
          readGate = Completer<Map<String, Object>>();
          final pending = restore(explicit);
          await readEntered!.future;
          await identity(nextOwner);
          readGate!.complete(Map.of(disk));
          await pending;
          expectNoSnapshot();
          expect(disk['flutter.$key'], raw);
        },
      );
    }
  }

  test(
    'timer transitions persist only in the authenticated owner backup',
    () async {
      await identity('a');
      repository.draft = workout_fixture.fixture().copyWith(userId: 'a');
      await controller.startWorkout();
      controller.startRest(90);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final ownerKey = 'flutter.$key:a';
      final running =
          jsonDecode(disk[ownerKey]! as String) as Map<String, dynamic>;
      expect((running['rest_timer'] as Map)['workout_id'], 'workout');
      expect((running['rest_timer'] as Map)['paused'], false);
      expect(disk['flutter.$key'], isNull);

      controller.pauseRest();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final paused =
          jsonDecode(disk[ownerKey]! as String) as Map<String, dynamic>;
      expect((paused['rest_timer'] as Map)['paused'], true);
      expect((paused['rest_timer'] as Map)['target_end_at'], isNull);

      controller.resumeRest();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final resumed =
          jsonDecode(disk[ownerKey]! as String) as Map<String, dynamic>;
      expect((resumed['rest_timer'] as Map)['paused'], false);
      expect((resumed['rest_timer'] as Map)['target_end_at'], isNotNull);

      controller.skipRest();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final skipped =
          jsonDecode(disk[ownerKey]! as String) as Map<String, dynamic>;
      expect(skipped['rest_timer'], isNull);
    },
  );

  test(
    'completed remote workout clears restored rest and its backup',
    () async {
      await identity('a');
      disk['flutter.$key'] = snapshotWithRest('a');
      repository.remote = workout_fixture.fixture().copyWith(
        userId: 'a',
        status: WorkoutStatus.completed,
        completedAt: DateTime.utc(2026, 10, 26, 2),
      );
      await controller.restoreFromLocalBackup();
      expect(
        container.read(activeWorkoutControllerProvider).isResting,
        isFalse,
      );
      expect(container.read(activeWorkoutControllerProvider).workout, isNull);
      expect(disk['flutter.$key'], isNull);
    },
  );

  test(
    'running rest retains its exact deadline across offline restores',
    () async {
      var now = DateTime.utc(2026, 11, 1, 1);
      restClockOverride = () => now;
      final deadline = now.add(const Duration(milliseconds: 90500));
      await identity('a');
      disk['flutter.$key'] = snapshotWithRest(
        'a',
        remaining: 91,
        deadline: deadline,
      );
      repository.offline = true;

      await controller.restoreFromLocalBackup();
      expect(
        container.read(activeWorkoutControllerProvider).restTargetEndTime,
        deadline,
      );

      now = now.add(const Duration(milliseconds: 400));
      container.invalidate(activeWorkoutControllerProvider);
      controller = container.read(activeWorkoutControllerProvider.notifier);
      await controller.restoreFromLocalBackup();
      expect(
        container.read(activeWorkoutControllerProvider).restTargetEndTime,
        deadline,
      );
    },
  );

  test(
    'automatic recovery clears a completed remote and stale backup',
    () async {
      await identity('a');
      disk['flutter.$key'] = snapshotWithRest('a');
      repository.remote = workout_fixture.fixture().copyWith(
        userId: 'a',
        status: WorkoutStatus.completed,
        completedAt: DateTime.utc(2026, 10, 26, 2),
      );
      await controller.checkForActiveWorkout();
      final state = container.read(activeWorkoutControllerProvider);
      expect(state.workout, isNull);
      expect(state.isResting, isFalse);
      expect(disk['flutter.$key'], isNull);
    },
  );

  for (final raw in [
    snapshot('a'),
    '{"workout":{"id":"ownerless"}}',
    '{broken',
  ]) {
    test('B save and discard preserve the unrelated legacy bytes $raw', () async {
      disk['flutter.$key'] = raw;
      await identity('b');
      await controller.startWorkout();
      await Future<void>.delayed(Duration.zero);
      expect(disk['flutter.$key'], raw);
      // Use the empty-state discard path; active-session queue behavior is R1-02.
      container.invalidate(activeWorkoutControllerProvider);
      controller = container.read(activeWorkoutControllerProvider.notifier);
      await controller.discardLocalBackup();
      expect(disk['flutter.$key'], raw);
    });
  }

  test(
    'B save remains recoverable without modifying A legacy snapshot',
    () async {
      final raw = snapshot('a');
      disk['flutter.$key'] = raw;
      await identity('b');
      await controller.startWorkout();
      await Future<void>.delayed(Duration.zero);
      expect(disk['flutter.$key'], raw);
      container.invalidate(activeWorkoutControllerProvider);
      controller = container.read(activeWorkoutControllerProvider.notifier);
      repository.offline = true;
      await controller.checkForActiveWorkout();
      expect(
        container.read(activeWorkoutControllerProvider).workout?.userId,
        'b',
      );
      expect(disk['flutter.$key'], raw);
    },
  );

  for (final nextOwner in <String?>[null, 'b']) {
    test(
      'pending A backup save stops after identity changes to $nextOwner',
      () async {
        await identity('a');
        repository.draft = repository.draft.copyWith(userId: 'a');
        readEntered = Completer<void>();
        readGate = Completer<Map<String, Object>>();
        await controller.startWorkout();
        await readEntered!.future;
        await identity(nextOwner);
        observed.clear();
        readGate!.complete({});
        await Future<void>.delayed(Duration.zero);
        expect(disk, isEmpty);
        expectNoSnapshot();
      },
    );

    test(
      'pending A backup clear preserves bytes after identity changes to $nextOwner',
      () async {
        final raw = snapshot('a');
        disk['flutter.$key'] = raw;
        await identity('a');
        readEntered = Completer<void>();
        readGate = Completer<Map<String, Object>>();
        final pending = controller.discardLocalBackup();
        await readEntered!.future;
        await identity(nextOwner);
        readGate!.complete(Map.of(disk));
        await pending;
        expect(disk['flutter.$key'], raw);
        expectNoSnapshot();
      },
    );
  }

  test(
    'A can recover its unchanged legacy backup after B saves a separate draft',
    () async {
      final raw = snapshot('a');
      disk['flutter.$key'] = raw;
      await identity('b');
      await controller.startWorkout();
      await Future<void>.delayed(Duration.zero);
      await identity('a');
      repository.offline = true;
      await controller.restoreFromLocalBackup();
      expect(
        container.read(activeWorkoutControllerProvider).workout?.userId,
        'a',
      );
      expect(disk['flutter.$key'], raw);
    },
  );
}
