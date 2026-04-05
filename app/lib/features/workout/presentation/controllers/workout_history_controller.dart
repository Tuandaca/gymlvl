import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/workout.dart';
import '../providers/exercise_providers.dart';

/// Lịch sử workout (paginated)
final workoutHistoryProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutHistory(limit: 20, offset: 0);
});

/// Workout gần đây (top 3) cho màn hình chính
final recentWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutHistory(limit: 3, offset: 0);
});

/// Chi tiết một workout cụ thể
final workoutDetailProvider =
    FutureProvider.family<Workout?, String>((ref, workoutId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutDetail(workoutId);
});

/// Tổng số workout đã hoàn thành
final completedWorkoutCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getCompletedWorkoutCount();
});
