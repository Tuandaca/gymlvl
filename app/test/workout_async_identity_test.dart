import 'dart:async';

import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'session_isolation_test.dart' as auth_fixture;
import 'workout_controller_test.dart' as workout_fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  late Map<String, Object> disk;
  late StreamController<AuthState> events;
  late ProviderContainer container;
  late ActiveWorkoutController controller;
  late workout_fixture.FakeRepository repository;
  late Completer<void> removalEntered;
  late Completer<void> releaseRemoval;
  String? gatedKey;

  setUp(() {
    SharedPreferences.resetStatic();
    disk = {};
    gatedKey = null;
    removalEntered = Completer<void>();
    releaseRemoval = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getAll') return Map.of(disk);
          final args = call.arguments as Map;
          final key = args['key'] as String;
          if (call.method == 'remove') {
            if (key == gatedKey) {
              removalEntered.complete();
              // Hold the native removal acknowledgement, not just getInstance().
              await releaseRemoval.future;
            }
            disk.remove(key);
          } else if (call.method.startsWith('set')) {
            disk[key] = args['value'] as Object;
          } else {
            throw StateError('Unexpected preference method ${call.method}');
          }
          return true;
        });
    repository = workout_fixture.FakeRepository();
    events = StreamController<AuthState>.broadcast();
    container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((ref) => events.stream),
        workoutRepositoryProvider.overrideWithValue(repository),
      ],
    );
    container.listen(activeWorkoutControllerProvider, (_, _) {});
    controller = container.read(activeWorkoutControllerProvider.notifier);
  });

  tearDown(() async {
    if (!releaseRemoval.isCompleted) releaseRemoval.complete();
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

  Future<void> start(String owner) async {
    repository.active = workout_fixture.fixture().copyWith(
      id: '$owner-workout',
      userId: owner,
    );
    await controller.startWorkout();
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(activeWorkoutControllerProvider).workout?.userId,
      owner,
    );
  }

  Future<void> prepareRemoval() async {
    await identity('a');
    await start('a');
    expect(disk.length, 1);
    gatedKey = disk.keys.single;
  }

  for (final operation in ['cancel', 'completion', 'discard']) {
    final completion = operation == 'completion';
    Future<Object?> finish() async {
      if (completion) return controller.completeWorkout();
      if (operation == 'discard') {
        await controller.discardLocalBackup();
      } else {
        await controller.cancelWorkout();
      }
      return null;
    }

    test(
      '$operation cannot clear B after A native backup removal resumes',
      () async {
        await prepareRemoval();
        final pending = finish();
        await removalEntered.future;
        await identity('b');
        await start('b');
        final before = container.read(activeWorkoutControllerProvider);
        final bDisk = Map.of(disk)..remove(gatedKey);
        expect(bDisk.length, 1);

        releaseRemoval.complete();
        expect(await pending, isNull);
        expect(container.read(activeWorkoutControllerProvider), before);
        expect(disk, bDisk);
        expect(repository.finishes, completion ? 1 : 0);
        expect(repository.cancels, completion ? 0 : 1);
      },
    );

    test(
      '$operation reset-only while native removal is pending settles safely',
      () async {
        await prepareRemoval();
        final pending = finish();
        await removalEntered.future;
        container.invalidate(activeWorkoutControllerProvider);
        expect(container.read(activeWorkoutControllerProvider).workout, isNull);
        releaseRemoval.complete();
        expect(await pending, isNull);
        expect(container.read(activeWorkoutControllerProvider).workout, isNull);
      },
    );

    test(
      '$operation signout while native removal is pending settles safely',
      () async {
        await prepareRemoval();
        final pending = finish();
        await removalEntered.future;
        await identity(null);
        releaseRemoval.complete();
        expect(await pending, isNull);
        expect(container.read(activeWorkoutControllerProvider).workout, isNull);
      },
    );

    test('$operation same-context native removal still succeeds', () async {
      await prepareRemoval();
      final pending = finish();
      await removalEntered.future;
      releaseRemoval.complete();
      final result = await pending;
      if (completion) expect(result, isNotNull);
      expect(container.read(activeWorkoutControllerProvider).workout, isNull);
      expect(disk, isEmpty);
      expect(repository.finishes, completion ? 1 : 0);
      expect(repository.cancels, completion ? 0 : 1);
    });
  }
}
