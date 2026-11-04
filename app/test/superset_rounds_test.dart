import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/workout/domain/superset_rounds.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

const _groupId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

WorkoutSet _set(String exerciseId, int number, {bool completed = false}) =>
    WorkoutSet(
      id: '$exerciseId-set-$number',
      workoutExerciseId: exerciseId,
      setNumber: number,
      isCompleted: completed,
    );

WorkoutExercise _exercise(
  String id,
  int? position,
  List<WorkoutSet> sets, {
  String? groupId = _groupId,
  bool? locked,
}) => WorkoutExercise(
  id: id,
  workoutId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  exerciseId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
  supersetGroupId: groupId,
  supersetPosition: position,
  supersetLocked: locked,
  sets: sets,
);

void main() {
  test('round N keeps set N and skips members without that set', () {
    final exercises = [
      _exercise('third', 2, [_set('third', 1, completed: true)]),
      _exercise('first', 0, [
        _set('first', 1, completed: true),
        _set('first', 3, completed: true),
      ]),
      _exercise('second', 1, [
        _set('second', 1, completed: true),
        _set('second', 2, completed: true),
      ]),
    ];

    final rounds = supersetRoundsForGroup(exercises, _groupId);
    expect(rounds.map((round) => round.number), [1, 2, 3]);
    expect(rounds[0].members.map((member) => member.exercise.id), [
      'first',
      'second',
      'third',
    ]);
    expect(rounds[1].members.map((member) => member.exercise.id), ['second']);
    expect(rounds[2].members.map((member) => member.exercise.id), ['first']);
    expect(rounds[1].members.single.set.setNumber, 2);
    expect(rounds[2].members.single.set.setNumber, 3);
  });

  test('automatic rest waits for final participating member of round', () {
    final pending = [
      _exercise('first', 0, [_set('first', 1, completed: true)]),
      _exercise('second', 1, [_set('second', 1)]),
      _exercise('third', 2, []),
    ];
    expect(shouldStartRestAfterSetCompletion(pending, 'first', 1), isFalse);
    expect(shouldStartRestAfterSetCompletion(pending, 'second', 1), isFalse);

    final complete = [
      pending[0],
      pending[1].copyWith(sets: [_set('second', 1, completed: true)]),
      pending[2],
    ];
    expect(
      supersetRoundsForGroup(complete, _groupId).single.isComplete,
      isTrue,
    );
    expect(shouldStartRestAfterSetCompletion(complete, 'second', 1), isTrue);
  });

  test('ungrouped set keeps existing automatic rest behavior', () {
    final exercise = _exercise('solo', null, [_set('solo', 1)], groupId: null);
    expect(shouldStartRestAfterSetCompletion([exercise], 'solo', 1), isTrue);
  });

  test('out-of-order completion rests after final outstanding member', () {
    final before = [
      _exercise('first', 0, [_set('first', 2)]),
      _exercise('second', 1, [_set('second', 2, completed: true)]),
    ];
    expect(shouldStartRestAfterSetCompletion(before, 'second', 2), isFalse);
    final after = [
      before[0].copyWith(sets: [_set('first', 2, completed: true)]),
      before[1],
    ];
    expect(shouldStartRestAfterSetCompletion(after, 'first', 2), isTrue);
  });

  test('malformed or dissolved group never starts automatic rest', () {
    final one = _exercise('only', 0, [_set('only', 1, completed: true)]);
    expect(supersetRoundsForGroup([one], _groupId), isEmpty);
    expect(shouldStartRestAfterSetCompletion([one], 'only', 1), isFalse);

    final gap = _exercise('other', 2, [_set('other', 1, completed: true)]);
    expect(supersetRoundsForGroup([one, gap], _groupId), isEmpty);
    expect(shouldStartRestAfterSetCompletion([one, gap], 'other', 1), isFalse);
  });

  test('UI lock state follows durable mirror and treats unknown as locked', () {
    final unlocked = [
      _exercise('first', 0, [], locked: false),
      _exercise('second', 1, [], locked: false),
    ];
    expect(isSupersetGroupLocked(unlocked, _groupId), isFalse);
    expect(
      isSupersetGroupLocked([
        unlocked[0].copyWith(supersetLocked: true),
        unlocked[1],
      ], _groupId),
      isTrue,
    );
    expect(
      isSupersetGroupLocked([
        unlocked[0].copyWith(supersetLocked: null),
        unlocked[1],
      ], _groupId),
      isTrue,
    );
    expect(
      isSupersetGroupLocked([
        unlocked[0].copyWith(sets: [_set('first', 1, completed: true)]),
        unlocked[1],
      ], _groupId),
      isTrue,
    );
  });
}
