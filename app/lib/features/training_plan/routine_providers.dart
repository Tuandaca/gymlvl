import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'routine_models.dart';
import 'routine_repository.dart';
import 'supabase_routine_repository.dart';
import 'routine_engine.dart';
import 'schedule_engine.dart';
import '../../core/config/supabase_config.dart';
import '../auth/presentation/providers/auth_providers.dart';

part 'routine_providers.freezed.dart';
part 'routine_providers.g.dart';

/// Routine engine for pure Dart operations
final routineEngineProvider = Provider<RoutineEngine>((ref) => RoutineEngine());

/// Schedule engine for pure Dart operations
final scheduleEngineProvider = Provider<ScheduleEngine>(
  (ref) => ScheduleEngine(),
);

/// Repository provider
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return SupabaseRoutineRepository(SupabaseConfig.client);
});

/// Current user ID provider (from auth)
final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.value?.session?.user.id ?? '';
});

/// All routines for current user
final routinesProvider = FutureProvider<List<Routine>>((ref) async {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getRoutines();
});

/// Single routine by ID
final routineProvider = FutureProvider.family<Routine?, String>((
  ref,
  routineId,
) async {
  if (routineId.isEmpty) return null;
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getRoutine(routineId);
});

/// Routine schedules
final routineSchedulesProvider =
    FutureProvider.family<List<RoutineSchedule>, String>((
      ref,
      routineId,
    ) async {
      if (routineId.isEmpty) return [];
      final repo = ref.watch(routineRepositoryProvider);
      return repo.getSchedules(routineId);
    });

/// Planned workouts for date range
final plannedWorkoutsProvider =
    FutureProvider.family<List<PlannedWorkout>, DateRange>((ref, range) async {
      final repo = ref.watch(routineRepositoryProvider);
      return repo.getPlannedWorkouts(
        startDate: range.start,
        endDate: range.end,
      );
    });

/// Next planned workout
final nextPlannedWorkoutProvider = FutureProvider<PlannedWorkout?>((ref) async {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getNextPlannedWorkout();
});

/// Current user's planned workouts for the next 30 days
final upcomingPlannedWorkoutsProvider = FutureProvider<List<PlannedWorkout>>((
  ref,
) async {
  final repo = ref.watch(routineRepositoryProvider);
  final now = DateTime.now();
  return repo.getPlannedWorkouts(
    startDate: now,
    endDate: DateTime.now().add(const Duration(days: 30)),
  );
});

/// Date range for filtering
@freezed
abstract class DateRange with _$DateRange {
  const factory DateRange({required DateTime start, required DateTime end}) =
      _DateRange;

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);
}
