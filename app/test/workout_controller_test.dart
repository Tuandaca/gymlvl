import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/data/supabase_workout_repository.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';

final started = DateTime.utc(2026, 10, 26, 1);
Workout fixture({bool training = true, bool completedSet = true}) => Workout(
  id: 'workout',
  userId: 'user',
  startedAt: started,
  trainingStartedAt: training ? started : null,
  exercises: [
    WorkoutExercise(
      id: 'exercise',
      workoutId: 'workout',
      exerciseId: 'catalog',
      sets: [
        WorkoutSet(
          id: 'set',
          workoutExerciseId: 'exercise',
          reps: 10,
          weightKg: 20,
          isCompleted: completedSet,
        ),
      ],
    ),
  ],
);

class FakeRepository extends Fake implements WorkoutRepository {
  Workout active = fixture();
  int starts = 0;
  int finishes = 0;
  bool failCompletion = false;
  bool failUpdate = false;
  Completer<void>? finishGate;
  Completer<void>? startGate;
  final List<int> updates = [];
  Completer<void>? updateGate;
  @override
  Future<Workout> startWorkout() async {
    starts++;
    await startGate?.future;
    return active;
  }

  @override
  Future<Workout?> getActiveWorkout() async => active;
  @override
  Future<Workout?> getWorkoutDetail(String id) async => active;
  @override
  Future<Workout> beginWorkout(String id) async {
    active = active.copyWith(trainingStartedAt: started);
    return active;
  }

  @override
  Future<Workout> setWorkoutPaused(String id, bool paused) async {
    active = active.copyWith(
      pausedAt: paused ? started.add(const Duration(seconds: 60)) : null,
      pausedSeconds: paused ? 0 : 30,
    );
    return active;
  }

  @override
  Future<WorkoutCompletion> finishWorkout(String id, {String? notes}) async {
    finishes++;
    await finishGate?.future;
    if (failCompletion) throw StateError('offline');
    return WorkoutCompletion(active.copyWith(status: WorkoutStatus.completed), {
      'earnedXP': 5,
    });
  }

  @override
  Future<WorkoutSet> updateSet(
    String id, {
    int? reps,
    int? durationSeconds,
    double? weightKg,
    bool? isCompleted,
    int? restSeconds,
  }) async {
    updates.add(reps ?? 0);
    await updateGate?.future;
    if (failUpdate) throw StateError('offline');
    return active.exercises.first.sets.first.copyWith(reps: reps ?? 10);
  }
}

void main() {
  late FakeRepository repository;
  late ProviderContainer container;
  late ActiveWorkoutController controller;
  setUp(() {
    repository = FakeRepository();
    container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((ref) => const Stream.empty()),
        workoutRepositoryProvider.overrideWithValue(repository),
      ],
    );
    controller = container.read(activeWorkoutControllerProvider.notifier);
  });
  tearDown(() => container.dispose());

  test('concurrent start requests resume the same local session', () async {
    await Future.wait([controller.startWorkout(), controller.startWorkout()]);
    expect(repository.starts, 1);
  });
  test(
    'restored draft remains setup, training is explicitly persisted',
    () async {
      repository.active = fixture(training: false);
      await controller.checkForActiveWorkout();
      expect(
        container.read(activeWorkoutControllerProvider).isSetupPhase,
        true,
      );
      await controller.beginTraining();
      expect(
        container.read(activeWorkoutControllerProvider).isSetupPhase,
        false,
      );
    },
  );
  test(
    'elapsed excludes setup and all paused time, including current pause',
    () {
      final workout = fixture().copyWith(
        pausedSeconds: 30,
        pausedAt: started.add(const Duration(seconds: 90)),
      );
      expect(
        ActiveWorkoutController.elapsedFor(
          workout,
          started.add(const Duration(hours: 1)),
        ),
        60,
      );
      expect(
        ActiveWorkoutController.elapsedFor(fixture(training: false), started),
        0,
      );
    },
  );
  test('double completion uses one request and authoritative XP', () async {
    await controller.startWorkout();
    repository.finishGate = Completer();
    final first = controller.completeWorkout();
    final second = controller.completeWorkout();
    await Future<void>.delayed(Duration.zero);
    expect(repository.finishes, 1);
    repository.finishGate!.complete();
    expect((await first)?['xpResult'], {'earnedXP': 5});
    expect(await second, isNotNull);
    expect(
      container.read(activeWorkoutControllerProvider).hasActiveWorkout,
      false,
    );
  });
  test('failed completion retains session for safe retry', () async {
    await controller.startWorkout();
    repository.failCompletion = true;
    expect(await controller.completeWorkout(), null);
    expect(
      container.read(activeWorkoutControllerProvider).hasActiveWorkout,
      true,
    );
    expect(
      container.read(activeWorkoutControllerProvider).errorMessage,
      'completion_failed',
    );
    repository.failCompletion = false;
    expect(await controller.completeWorkout(), isNotNull);
  });
  test('cannot finish with only uncompleted sets', () async {
    repository.active = fixture(completedSet: false);
    await controller.startWorkout();
    expect(await controller.completeWorkout(), null);
    expect(repository.finishes, 0);
  });
  test('set updates are serialized and completion waits for them', () async {
    await controller.startWorkout();
    repository.updateGate = Completer();
    final first = controller.updateSet('exercise', 'set', reps: 12);
    final second = controller.updateSet('exercise', 'set', reps: 15);
    final finish = controller.completeWorkout();
    await Future<void>.delayed(Duration.zero);
    expect(repository.updates, [12]);
    expect(repository.finishes, 0);
    repository.updateGate!.complete();
    await Future.wait([first, second]);
    await finish;
    expect(repository.updates, [12, 15]);
    expect(repository.finishes, 1);
  });
  test('invalid numeric input is rejected before persistence', () {
    expect(
      () => SupabaseWorkoutRepository.validateSet(reps: -1),
      throwsArgumentError,
    );
    expect(
      () => SupabaseWorkoutRepository.validateSet(weightKg: double.nan),
      throwsArgumentError,
    );
    expect(
      () => SupabaseWorkoutRepository.validateSet(weightKg: 1001),
      throwsArgumentError,
    );
    expect(
      () => SupabaseWorkoutRepository.validateSet(reps: 10, weightKg: 0),
      returnsNormally,
    );
  });
  test(
    'failed pending edit blocks completion until saved session is reloaded',
    () async {
      await controller.startWorkout();
      repository.failUpdate = true;
      repository.updateGate = Completer();
      final update = controller.updateSet('exercise', 'set', reps: 20);
      final finish = controller.completeWorkout();
      await Future<void>.delayed(Duration.zero);
      repository.updateGate!.complete();
      await update;
      expect(await finish, null);
      expect(repository.finishes, 0);
      expect(
        container.read(activeWorkoutControllerProvider).errorMessage,
        'reload_required',
      );
      controller.clearError();
      expect(await controller.completeWorkout(), null);
      expect(repository.finishes, 0);
      await controller.checkForActiveWorkout();
      expect(await controller.completeWorkout(), isNotNull);
      expect(repository.finishes, 1);
    },
  );
  test(
    'a response from a disposed identity cannot repopulate the controller',
    () async {
      repository.startGate = Completer();
      final pending = controller.startWorkout();
      await Future<void>.delayed(Duration.zero);
      container.invalidate(activeWorkoutControllerProvider);
      expect(
        container.read(activeWorkoutControllerProvider).hasActiveWorkout,
        false,
      );
      repository.startGate!.complete();
      await pending;
      expect(
        container.read(activeWorkoutControllerProvider).hasActiveWorkout,
        false,
      );
    },
  );
}
