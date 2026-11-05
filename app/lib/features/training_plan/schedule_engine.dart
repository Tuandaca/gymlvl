import 'routine_models.dart';

/// Pure Dart engine for schedule operations.
/// No I/O, no randomness, no clock. Deterministic and testable.
class ScheduleEngine {
  const ScheduleEngine();

  /// Gets all planned workouts for a date range.
  List<PlannedWorkout> getPlannedWorkouts({
    required List<Routine> routines,
    required List<RoutineSchedule> schedules,
    required DateTime startDate,
    required DateTime endDate,
    required String userTimezone,
  }) {
    final planned = <PlannedWorkout>[];
    final normalizedStart = _normalizeDate(startDate, userTimezone);
    final normalizedEnd = _normalizeDate(endDate, userTimezone);

    for (final routine in routines) {
      if (routine.isArchived) continue;

      final routineSchedules = schedules
          .where((s) => s.routineId == routine.id)
          .toList();

      for (final schedule in routineSchedules) {
        final occurrences = _getOccurrences(
          schedule: schedule,
          startDate: normalizedStart,
          endDate: normalizedEnd,
          userTimezone: userTimezone,
        );

        for (final date in occurrences) {
          final plannedWorkout = PlannedWorkout(
            id: _generateId(),
            userId: '', // Will be set by caller
            routineId: routine.id,
            routineName: routine.name,
            routineSnapshot: _buildRoutineSnapshot(routine),
            scheduledDate: date,
            status: PlannedWorkoutStatus.planned,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          planned.add(plannedWorkout);
        }
      }
    }

    // Sort by date
    planned.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return planned;
  }

  /// Gets the next upcoming workout for a user.
  PlannedWorkout? getNextWorkout({
    required List<Routine> routines,
    required List<RoutineSchedule> schedules,
    required DateTime now,
    required String userTimezone,
  }) {
    final today = _normalizeDate(now, userTimezone);
    final planned = getPlannedWorkouts(
      routines: routines,
      schedules: schedules,
      startDate: today,
      endDate: today.add(const Duration(days: 30)),
      userTimezone: userTimezone,
    );

    return planned
        .where((p) => p.status == PlannedWorkoutStatus.planned)
        .firstOrNull;
  }

  /// Assigns a routine to a weekday (fixed week mode).
  List<RoutineSchedule> assignToWeekday({
    required List<RoutineSchedule> current,
    required String routineId,
    required int weekday, // 1=Monday ... 7=Sunday
  }) {
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError('weekday must be 1-7');
    }

    // Remove existing schedule for this routine in fixed_week mode
    final filtered = current
        .where((s) => s.routineId != routineId || s is! FixedWeekSchedule)
        .toList();

    // Add new schedule
    filtered.add(
      RoutineSchedule.fixedWeek(
        id: _generateId(),
        routineId: routineId,
        weekday: weekday,
      ),
    );

    return filtered;
  }

  /// Assigns a routine to a rotation position.
  List<RoutineSchedule> assignToRotation({
    required List<RoutineSchedule> current,
    required String routineId,
    required int position,
    String? supersetGroupId,
  }) {
    if (position < 0) {
      throw ArgumentError('position must be >= 0');
    }

    // Remove existing schedule for this routine in rotation mode
    final filtered = current
        .where((s) => s.routineId != routineId || s is! RotationSchedule)
        .toList();

    // Add new schedule
    filtered.add(
      RoutineSchedule.rotation(
        id: _generateId(),
        routineId: routineId,
        position: position,
        supersetGroupId: supersetGroupId,
      ),
    );

    return filtered;
  }

  /// Removes a schedule for a routine.
  List<RoutineSchedule> removeSchedule({
    required List<RoutineSchedule> current,
    required String scheduleId,
  }) {
    return current.where((s) => s.id != scheduleId).toList();
  }

  /// Reschedules a planned workout to a new date.
  List<PlannedWorkout> reschedule({
    required List<PlannedWorkout> planned,
    required String plannedWorkoutId,
    required DateTime newDate,
  }) {
    return planned.map((p) {
      if (p.id == plannedWorkoutId) {
        return p.copyWith(scheduledDate: newDate, updatedAt: DateTime.now());
      }
      return p;
    }).toList();
  }

  /// Gets all occurrences of a routine schedule within a date range.
  List<DateTime> _getOccurrences({
    required RoutineSchedule schedule,
    required DateTime startDate,
    required DateTime endDate,
    required String userTimezone,
  }) {
    final occurrences = <DateTime>[];

    if (schedule is FixedWeekSchedule) {
      final targetWeekday = schedule.weekday; // 1=Monday ... 7=Sunday
      var current = startDate;
      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        if (current.weekday == targetWeekday) {
          occurrences.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
    } else if (schedule is RotationSchedule) {
      // For rotation, we'd need more context about the rotation state
      // For now, return empty - rotation scheduling requires more context
    }

    return occurrences;
  }

  /// Builds an immutable snapshot of a routine for planned workout.
  Map<String, dynamic> _buildRoutineSnapshot(Routine routine) {
    return {
      'routine': {
        'id': routine.id,
        'name': routine.name,
        'emoji': routine.emoji,
        'exercises': routine.exercises
            .map(
              (e) => {
                'exercise_id': e.exerciseId,
                'order_index': e.orderIndex,
                'sets': e.sets,
                'reps': e.reps,
                'reps_min': e.repsMin,
                'weight_kg': e.weightKg,
                'duration_seconds': e.durationSeconds,
                'rest_seconds': e.restSeconds,
                'rpe_target': e.rpeTarget,
                'rir_target': e.rirTarget,
                'warmup_sets': e.warmupSets,
                'mode': e.mode.wireValue,
                'notes': e.notes,
                'superset_group_id': e.supersetGroupId,
                'superset_position': e.supersetPosition,
              },
            )
            .toList(),
      },
    };
  }

  DateTime _normalizeDate(DateTime date, String userTimezone) {
    // In a real implementation, this would use the user's timezone
    // For now, assume UTC
    return DateTime(date.year, date.month, date.day);
  }

  static int _idSequence = 0;

  String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}';
}
