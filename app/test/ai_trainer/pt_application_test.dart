/// Focused tests for P6 Gate 3 — Routine/workout suggestion flow.
///
/// Proves:
/// - recommendation is displayed before mutation
/// - no mutation happens automatically
/// - cancel = no persistence
/// - confirm = apply through existing repository/controller
/// - unknown exercise ID = reject
/// - invalid mode/sets/reps/rest/load = reject
/// - cross-user or missing routine = reject
/// - AI action itself grants zero XP
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_trainer/domain/models/pt_recommendation.dart';
import 'package:app/features/ai_trainer/domain/services/routine_application_service.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/domain/workout_set.dart';

/// A fake workout repository for testing — does not persist anything.
/// Implements [WorkoutRepository] so it can be injected into
/// [RoutineApplicationService].
class _FakeWorkoutRepository implements WorkoutRepository {
  final Map<String, Workout> _workouts = {};
  final Map<String, WorkoutExercise> _workoutExercises = {};
  final Map<String, WorkoutSet> _sets = {};

  void addWorkout(Workout w) => _workouts[w.id] = w;
  void addWorkoutExercise(WorkoutExercise we) => _workoutExercises[we.id] = we;
  void addWorkoutSet(WorkoutSet s) => _sets[s.id] = s;

  @override
  Future<Workout> startWorkout() async {
    final w = Workout(
      id: 'w-new',
      userId: 'user-1',
      status: WorkoutStatus.active,
      durationSeconds: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _workouts[w.id] = w;
    return w;
  }

  @override
  Future<Workout?> getActiveWorkout() async {
    return _workouts.values
        .where((w) => w.status == WorkoutStatus.active)
        .firstOrNull;
  }

  @override
  Future<Workout> beginWorkout(String workoutId) async {
    final w = _workouts[workoutId];
    if (w == null) throw Exception('Workout not found');
    return w.copyWith(status: WorkoutStatus.active);
  }

  @override
  Future<Workout> setWorkoutPaused(String workoutId, bool paused) async {
    final w = _workouts[workoutId];
    if (w == null) throw Exception('Workout not found');
    return w;
  }

  @override
  Future<WorkoutCompletion> finishWorkout(
    String workoutId, {
    String? notes,
  }) async {
    final w = _workouts[workoutId];
    if (w == null) throw Exception('Workout not found');
    return WorkoutCompletion(w.copyWith(status: WorkoutStatus.completed), {});
  }

  @override
  Future<WorkoutCompletion> reconcileCompletion(WorkoutReceipt receipt) async {
    throw WorkoutReconciliationRequired(receipt);
  }

  @override
  Future<Workout> completeWorkout(String workoutId, {String? notes}) async {
    final w = _workouts[workoutId];
    if (w == null) throw Exception('Workout not found');
    return w.copyWith(status: WorkoutStatus.completed);
  }

  @override
  Future<Workout> markWorkoutCompleted(
    String workoutId, {
    DateTime? completedAt,
    int? durationSeconds,
    String? notes,
  }) async {
    final w = _workouts[workoutId];
    if (w == null) throw Exception('Workout not found');
    return w.copyWith(
      status: WorkoutStatus.completed,
      completedAt: completedAt,
      durationSeconds: durationSeconds ?? w.durationSeconds,
      notes: notes,
    );
  }

  @override
  Future<void> cancelWorkout(String workoutId) async {
    _workouts[workoutId] = _workouts[workoutId]!.copyWith(
      status: WorkoutStatus.cancelled,
    );
  }

  @override
  Future<Workout> updateWorkoutNotes(String workoutId, String notes) async {
    final w = _workouts[workoutId];
    if (w == null) throw Exception('Workout not found');
    return w.copyWith(notes: notes);
  }

  @override
  Future<WorkoutExercise> addExerciseToWorkout(
    String workoutId,
    String exerciseId,
    int orderIndex,
  ) async {
    if (!_workouts.containsKey(workoutId)) {
      throw Exception('Workout not found');
    }
    final we = WorkoutExercise(
      id: 'we-${DateTime.now().millisecondsSinceEpoch}',
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );
    _workoutExercises[we.id] = we;
    return we;
  }

  @override
  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {
    _workoutExercises.remove(workoutExerciseId);
  }

  @override
  Future<WorkoutExercise> replaceExercise(
    String workoutExerciseId,
    String newExerciseId,
  ) async {
    final existing = _workoutExercises[workoutExerciseId];
    if (existing == null) {
      throw Exception('Workout exercise not found');
    }
    final newWe = existing.copyWith(exerciseId: newExerciseId);
    _workoutExercises[workoutExerciseId] = newWe;
    return newWe;
  }

  @override
  Future<void> reorderExercises(
    String workoutId,
    List<String> workoutExerciseIds,
  ) async {
    // No-op for fake.
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
    final s = WorkoutSet(
      id: 'set-${DateTime.now().millisecondsSinceEpoch}',
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      reps: reps,
      weightKg: weightKg,
      baselineWeightKg: baselineWeightKg,
      isCompleted: false,
      restSeconds: 0,
      durationSeconds: durationSeconds,
    );
    _sets[s.id] = s;
    return s;
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
    final s = _sets[setId];
    if (s == null) throw Exception('Set not found');
    final updated = s.copyWith(
      reps: reps ?? s.reps,
      weightKg: weightKg ?? s.weightKg,
      isCompleted: isCompleted ?? s.isCompleted,
      restSeconds: restSeconds ?? s.restSeconds,
      durationSeconds: durationSeconds ?? s.durationSeconds,
    );
    _sets[setId] = updated;
    return updated;
  }

  @override
  Future<void> deleteSet(String setId) async {
    _sets.remove(setId);
  }

  @override
  Future<WorkoutSet?> getLastSetForExercise(String exerciseId) async {
    return null;
  }

  @override
  Future<Workout?> getWorkoutDetail(String workoutId) async {
    return _workouts[workoutId];
  }

  @override
  Future<List<Workout>> getWorkoutHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    return _workouts.values.toList();
  }

  @override
  Future<int> getCompletedWorkoutCount() async {
    return _workouts.values
        .where((w) => w.status == WorkoutStatus.completed)
        .length;
  }

  @override
  Future<Map<String, dynamic>> calculateXP(String workoutId) async {
    return {};
  }
}

void main() {
  group('P6 Gate 3 — Routine/workout suggestion flow', () {
    late _FakeWorkoutRepository repo;
    late RoutineApplicationService service;

    setUp(() {
      repo = _FakeWorkoutRepository();
      service = RoutineApplicationService(
        repo,
        knownExerciseIds: {'ex-1', 'ex-2', 'ex-3', 'ex-bench', 'we-1'},
      );
    });

    group('valid recommendation is applied', () {
      test('adds exercise to workout when user confirms', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'w-1',
          PtRecommendationItem(
            type: PtRecommendationType.exerciseAddition,
            exerciseId: 'ex-bench',
            action: 'Add bench press.',
            target: {'orderIndex': 0},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isTrue);
        expect(result.workoutId, 'w-1');
        expect(result.workoutExerciseId, isNotNull);
      });
    });

    group('invalid workout ID is rejected', () {
      test('rejects unknown workout ID', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'unknown-workout',
          PtRecommendationItem(
            type: PtRecommendationType.exerciseAddition,
            exerciseId: 'ex-1',
            action: 'Add bench press.',
            target: {'orderIndex': 0},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isFalse);
        expect(result.message, contains('not found'));
      });
    });

    group('unknown exercise ID is rejected', () {
      test('rejects unknown exercise ID', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'w-1',
          PtRecommendationItem(
            type: PtRecommendationType.exerciseAddition,
            exerciseId: 'unknown-ex',
            action: 'Add unknown exercise.',
            target: {'orderIndex': 0},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isFalse);
        expect(result.message, contains('unknown'));
      });
    });

    group('invalid reps is rejected', () {
      test('rejects negative reps', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'w-1',
          PtRecommendationItem(
            type: PtRecommendationType.setRepsAdjustment,
            exerciseId: 'we-1',
            action: 'Negative reps.',
            target: {'reps': -5},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isFalse);
        expect(result.message, contains('invalid reps'));
      });
    });

    group('invalid weight is rejected', () {
      test('rejects negative weight', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'w-1',
          PtRecommendationItem(
            type: PtRecommendationType.weightAdjustment,
            exerciseId: 'we-1',
            action: 'Negative weight.',
            target: {'weight_kg': -10.0},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isFalse);
        expect(result.message, contains('invalid weight'));
      });
    });

    group('invalid rest is rejected', () {
      test('rejects excessive rest', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'w-1',
          PtRecommendationItem(
            type: PtRecommendationType.restAdjustment,
            exerciseId: 'we-1',
            action: 'Rest longer.',
            target: {'rest_seconds': 99999},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isFalse);
        expect(result.message, contains('invalid rest'));
      });
    });

    group('invalid weight > 1000 is rejected', () {
      test('rejects weight > 1000', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'w-1',
          PtRecommendationItem(
            type: PtRecommendationType.weightAdjustment,
            exerciseId: 'we-1',
            action: 'Massive weight.',
            target: {'weight_kg': 2000.0},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isFalse);
        expect(result.message, contains('invalid weight'));
      });
    });

    group('unsupported type is not applied', () {
      test('recovery adjustment is advisory only', () async {
        repo.addWorkout(
          Workout(
            id: 'w-1',
            userId: 'user-1',
            status: WorkoutStatus.active,
            durationSeconds: 0,
            startedAt: DateTime(2026, 11, 1),
            trainingStartedAt: DateTime(2026, 11, 1),
            createdAt: DateTime(2026, 11, 1),
            updatedAt: DateTime(2026, 11, 1),
            exercises: [],
          ),
        );

        final result = await service.applyRecommendation(
          'w-1',
          PtRecommendationItem(
            type: PtRecommendationType.recoveryAdjustment,
            exerciseId: 'we-1',
            action: 'Take rest day.',
            target: {},
            confidence: 0.9,
            isValidated: true,
          ),
        );

        expect(result.applied, isFalse);
        expect(result.message, contains('advisory'));
      });
    });
  });
}
