import 'workout_exercise.dart';
import 'workout_set.dart';

/// A missing lock mirror is treated as locked. PostgreSQL's append-only lock
/// remains authoritative after a completed set is uncompleted or deleted.
bool isSupersetGroupLocked(List<WorkoutExercise> exercises, String groupId) {
  final members = exercises
      .where((exercise) => exercise.supersetGroupId == groupId)
      .toList();
  if (members.length < 2) return true;
  return members.any(
    (exercise) =>
        exercise.supersetLocked != false ||
        exercise.sets.any((set) => set.isCompleted),
  );
}

/// A member keeps its original workout-exercise and set identity.
final class SupersetRoundMember {
  const SupersetRoundMember(this.exercise, this.set);

  final WorkoutExercise exercise;
  final WorkoutSet set;
}

/// Round N uses set number N. Missing member sets are omitted, never renumbered.
final class SupersetRound {
  const SupersetRound({
    required this.groupId,
    required this.number,
    required this.members,
  });

  final String groupId;
  final int number;
  final List<SupersetRoundMember> members;

  bool get isComplete =>
      members.isNotEmpty && members.every((member) => member.set.isCompleted);

  String? get finalMemberId =>
      members.isEmpty ? null : members.last.exercise.id;
}

/// Returns no rounds for a malformed or dissolved group, keeping timer behavior
/// conservative until the server layout is reloaded.
List<SupersetRound> supersetRoundsForGroup(
  List<WorkoutExercise> exercises,
  String groupId,
) {
  final members =
      exercises
          .where((exercise) => exercise.supersetGroupId == groupId)
          .toList()
        ..sort((a, b) {
          final position = (a.supersetPosition ?? -1).compareTo(
            b.supersetPosition ?? -1,
          );
          return position != 0 ? position : a.id.compareTo(b.id);
        });
  if (members.length < 2) return const [];
  for (var index = 0; index < members.length; index++) {
    if (members[index].supersetPosition != index) return const [];
  }

  final numbers = <int>{};
  for (final member in members) {
    for (final set in member.sets) {
      if (set.setNumber > 0) numbers.add(set.setNumber);
    }
  }
  final orderedNumbers = numbers.toList()..sort();
  return [
    for (final number in orderedNumbers)
      SupersetRound(
        groupId: groupId,
        number: number,
        members: [
          for (final member in members)
            if (member.sets.where((set) => set.setNumber == number).isNotEmpty)
              SupersetRoundMember(
                member,
                member.sets.where((set) => set.setNumber == number).first,
              ),
        ],
      ),
  ];
}

/// A grouped round rests when the final outstanding member completes,
/// independent of the order in which members were performed. Ungrouped sets keep the existing
/// automatic-rest behavior. Manual timer controls are independent of this.
bool shouldStartRestAfterSetCompletion(
  List<WorkoutExercise> exercises,
  String workoutExerciseId,
  int setNumber,
) {
  final matching = exercises.where(
    (exercise) => exercise.id == workoutExerciseId,
  );
  if (matching.isEmpty) return false;
  final exercise = matching.first;
  final groupId = exercise.supersetGroupId;
  if (groupId == null) return true;
  for (final round in supersetRoundsForGroup(exercises, groupId)) {
    if (round.number == setNumber) {
      return round.members.any(
            (member) => member.exercise.id == workoutExerciseId,
          ) &&
          round.isComplete;
    }
  }
  return false;
}
