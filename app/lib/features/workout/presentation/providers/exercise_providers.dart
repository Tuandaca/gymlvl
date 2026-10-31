import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/exercise.dart';
import '../../domain/exercise_repository.dart';
import '../../domain/workout_repository.dart';
import '../../data/supabase_exercise_repository.dart';
import '../../data/supabase_workout_repository.dart';
import '../controllers/active_workout_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ─── Exercise Providers ───

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return SupabaseExerciseRepository(SupabaseConfig.client);
});

final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercises();
});

// ─── Search text normalization ───

/// Strips Vietnamese diacritics (e.g. á→a, đ→d) and lowercases so search is
/// accent-insensitive: "squat" matches "Squat" and Vietnamese names with or
/// without diacritics. Applied to both the query and the exercise name.
String normalizeSearchText(String text) {
  const diacritics = <String, String>{
    'à': 'a',
    'á': 'a',
    'ả': 'a',
    'ã': 'a',
    'ạ': 'a',
    'ă': 'a',
    'ằ': 'a',
    'ắ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'ặ': 'a',
    'â': 'a',
    'ầ': 'a',
    'ấ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ậ': 'a',
    'đ': 'd',
    'è': 'e',
    'é': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ẹ': 'e',
    'ê': 'e',
    'ề': 'e',
    'ế': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ệ': 'e',
    'ì': 'i',
    'í': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ị': 'i',
    'ò': 'o',
    'ó': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ọ': 'o',
    'ô': 'o',
    'ồ': 'o',
    'ố': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ộ': 'o',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ợ': 'o',
    'ù': 'u',
    'ú': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ụ': 'u',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ự': 'u',
    'ỳ': 'y',
    'ý': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'ỵ': 'y',
  };

  var result = text.toLowerCase();
  for (final entry in diacritics.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  return result;
}

// ─── Search & Filter State (Riverpod 3.x Notifier pattern) ───

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  /// Debounced setter (~300 ms) so the catalogue does not rebuild on every
  /// keystroke. Empty values are applied immediately so clearing feels instant.
  void set(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      state = value;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = value;
    });
  }

  void clear() {
    _debounce?.cancel();
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

class SelectedEquipmentNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final selectedEquipmentProvider =
    NotifierProvider<SelectedEquipmentNotifier, String?>(
      SelectedEquipmentNotifier.new,
    );

class SelectedMuscleNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final selectedMuscleProvider =
    NotifierProvider<SelectedMuscleNotifier, String?>(
      SelectedMuscleNotifier.new,
    );

final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  final query = normalizeSearchText(ref.watch(searchQueryProvider));
  final category = ref.watch(selectedCategoryProvider);
  final equipment = ref.watch(selectedEquipmentProvider);
  final muscle = ref.watch(selectedMuscleProvider);

  return exercisesAsync.whenData((exercises) {
    return exercises.where((ex) {
      final name = normalizeSearchText(ex.name);
      final matchesQuery = query.isEmpty || name.contains(query);
      final matchesCategory = category == null || ex.category == category;
      final matchesEquipment = equipment == null || ex.equipment == equipment;
      final matchesMuscle =
          muscle == null || ex.secondaryMuscles.contains(muscle);
      return matchesQuery &&
          matchesCategory &&
          matchesEquipment &&
          matchesMuscle;
    }).toList();
  });
});

// ─── Derived filter options from actual exercise data ───

/// Distinct categories present in the exercise catalogue.
final exerciseCategoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  return exercisesAsync.whenData((exercises) {
    final categories = exercises.map((e) => e.category).toSet().toList()
      ..sort();
    return categories;
  });
});

/// Distinct equipment values present in the exercise catalogue.
final exerciseEquipmentsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  return exercisesAsync.whenData((exercises) {
    final equipments = exercises.map((e) => e.equipment).toSet().toList()
      ..sort();
    return equipments;
  });
});

/// Distinct secondary muscle groups present in the exercise catalogue.
final exerciseMusclesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  return exercisesAsync.whenData((exercises) {
    final muscles = <String>{};
    for (final ex in exercises) {
      muscles.addAll(ex.secondaryMuscles);
    }
    return muscles.toList()..sort();
  });
});

// ─── Workout Providers ───

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  ref.watch(
    authStateStreamProvider.select((state) => state.value?.session?.user.id),
  );
  return SupabaseWorkoutRepository(SupabaseConfig.client);
});

final activeWorkoutControllerProvider =
    NotifierProvider<ActiveWorkoutController, ActiveWorkoutState>(
      ActiveWorkoutController.new,
    );
