import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/exercise.dart';
import '../../domain/exercise_repository.dart';
import '../../domain/workout_repository.dart';
import '../../data/supabase_exercise_repository.dart';
import '../../data/supabase_workout_repository.dart';
import '../controllers/active_workout_controller.dart';

// ─── Exercise Providers ───

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return SupabaseExerciseRepository(SupabaseConfig.client);
});

final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercises();
});

// ─── Search & Filter State (Riverpod 3.x Notifier pattern) ───

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
        SelectedCategoryNotifier.new);

final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return exercisesAsync.whenData((exercises) {
    return exercises.where((ex) {
      final matchesQuery = ex.name.toLowerCase().contains(query);
      final matchesCategory = category == null || ex.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  });
});

// ─── Workout Providers ───

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return SupabaseWorkoutRepository(SupabaseConfig.client);
});

final activeWorkoutControllerProvider =
    NotifierProvider<ActiveWorkoutController, ActiveWorkoutState>(
        ActiveWorkoutController.new);
