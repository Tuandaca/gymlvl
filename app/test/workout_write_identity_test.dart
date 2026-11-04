import 'dart:convert';

import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fields = {
    'owner_id': 'owner-a',
    'workout_id': 'workout-1',
    'operation_id': 'operation-1',
  };

  test('round-trips with deterministic snake_case field order', () {
    final identity = WorkoutWriteIdentity.fromJson({
      'operation_id': 'operation-1',
      'owner_id': 'owner-a',
      'workout_id': 'workout-1',
    });

    expect(identity.toJson(), fields);
    expect(
      jsonEncode(identity.toJson()),
      '{"owner_id":"owner-a","workout_id":"workout-1",'
      '"operation_id":"operation-1"}',
    );
    expect(
      WorkoutWriteIdentity.fromJson(
        jsonDecode(jsonEncode(identity.toJson())) as Map<String, dynamic>,
      ),
      identity,
    );
  });

  test('rejects missing, extra, and incorrectly typed JSON fields', () {
    expect(
      () => WorkoutWriteIdentity.fromJson({
        'owner_id': 'owner-a',
        'workout_id': 'workout-1',
      }),
      throwsFormatException,
    );
    expect(
      () => WorkoutWriteIdentity.fromJson({...fields, 'payload': {}}),
      throwsFormatException,
    );
    expect(
      () => WorkoutWriteIdentity.fromJson({...fields, 'operation_id': 7}),
      throwsFormatException,
    );
  });

  test('rejects blank and untrimmed IDs from constructors and JSON', () {
    expect(
      () => WorkoutWriteIdentity(
        ownerId: ' ',
        workoutId: 'workout-1',
        operationId: 'operation-1',
      ),
      throwsArgumentError,
    );
    expect(
      () => WorkoutWriteIdentity(
        ownerId: 'owner-a',
        workoutId: '',
        operationId: 'operation-1',
      ),
      throwsArgumentError,
    );
    expect(
      () => WorkoutWriteIdentity.fromJson({
        ...fields,
        'operation_id': ' operation-1',
      }),
      throwsFormatException,
    );
  });

  test('binds an identity to its exact owner and workout', () {
    final identity = WorkoutWriteIdentity.fromJson(fields);

    expect(identity.belongsTo('owner-a', 'workout-1'), isTrue);
    expect(identity.belongsTo('owner-b', 'workout-1'), isFalse);
    expect(identity.belongsTo('owner-a', 'workout-2'), isFalse);
  });

  test(
    'dedup key is equal only for matching owner, workout, and operation',
    () {
      final original = WorkoutWriteIdentity.fromJson(fields);
      final same = WorkoutWriteIdentity.fromJson({...fields});
      final otherOwner = WorkoutWriteIdentity.fromJson({
        ...fields,
        'owner_id': 'owner-b',
      });
      final otherWorkout = WorkoutWriteIdentity.fromJson({
        ...fields,
        'workout_id': 'workout-2',
      });
      final otherOperation = WorkoutWriteIdentity.fromJson({
        ...fields,
        'operation_id': 'operation-2',
      });

      expect(original, same);
      expect(original.hashCode, same.hashCode);
      expect(original.dedupKey, same.dedupKey);
      expect({
        original.dedupKey,
        same.dedupKey,
        otherOwner.dedupKey,
        otherWorkout.dedupKey,
        otherOperation.dedupKey,
      }, hasLength(4));
      expect(otherOwner, isNot(original));
      expect(otherWorkout, isNot(original));
      expect(otherOperation, isNot(original));
    },
  );

  test('delimiters inside IDs cannot collide in the dedup key', () {
    final first = WorkoutWriteIdentity(
      ownerId: 'a:b',
      workoutId: 'c',
      operationId: 'd',
    );
    final second = WorkoutWriteIdentity(
      ownerId: 'a',
      workoutId: 'b:c',
      operationId: 'd',
    );
    expect(first.dedupKey, isNot(second.dedupKey));
  });

  test('mutating source or exported maps does not change the identity', () {
    final source = <String, dynamic>{...fields};
    final identity = WorkoutWriteIdentity.fromJson(source);
    source['owner_id'] = 'owner-b';
    final exported = identity.toJson();
    exported['operation_id'] = 'operation-2';

    expect(identity.toJson(), fields);
    expect(identity.belongsTo('owner-a', 'workout-1'), isTrue);
    expect(
      identity.dedupKey,
      jsonEncode(['owner-a', 'workout-1', 'operation-1']),
    );
  });
}
