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

/// Resolves a stable exercise ID from the catalogue already held by Riverpod.
/// This keeps picker-to-detail navigation from issuing another network request.
final exerciseDetailProvider = Provider.family<AsyncValue<Exercise?>, String>((
  ref,
  id,
) {
  if (id.trim().isEmpty) return const AsyncData<Exercise?>(null);
  return ref.watch(exerciseListProvider).whenData((exercises) {
    for (final exercise in exercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  });
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// P7 Gate 1: custom exercise providers (owner-scoped).
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Owner's non-archived custom exercises.
final customExercisesProvider = FutureProvider.family<List<Exercise>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getCustomExercises(userId);
});

/// Owner's archived custom exercises (history-preserving soft delete).
final archivedCustomExercisesProvider =
    FutureProvider.family<List<Exercise>, String>((ref, userId) async {
      final repository = ref.watch(exerciseRepositoryProvider);
      return repository.getArchivedCustomExercises(userId);
    });

class CustomExerciseNotifier extends Notifier<AsyncValue<Exercise?>> {
  @override
  AsyncValue<Exercise?> build() => const AsyncData(null);

  Future<void> create(Exercise exercise) async {
    state = const AsyncLoading();
    final repository = ref.read(exerciseRepositoryProvider);
    try {
      final created = await repository.createCustomExercise(exercise);
      state = AsyncData(created);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> update(Exercise exercise) async {
    state = const AsyncLoading();
    final repository = ref.read(exerciseRepositoryProvider);
    try {
      final updated = await repository.updateCustomExercise(exercise);
      state = AsyncData(updated);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> archive(String exerciseId) async {
    final repository = ref.read(exerciseRepositoryProvider);
    await repository.archiveCustomExercise(exerciseId);
    state = const AsyncData(null);
  }
}

final customExerciseProvider =
    NotifierProvider.autoDispose<CustomExerciseNotifier, AsyncValue<Exercise?>>(
      CustomExerciseNotifier.new,
    );

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// P7 Gate 2: favourites + aliases providers (owner-scoped).
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Exercise IDs favourited by [userId].
final favouriteExerciseIdsProvider =
    FutureProvider.family<List<String>, String>((ref, userId) async {
      final repository = ref.read(exerciseRepositoryProvider);
      return repository.favouriteExerciseIds(userId);
    });

/// Whether [exerciseId] is favourited by [userId].
final isExerciseFavouriteProvider = FutureProvider.family<bool, _FavouriteKey>((
  ref,
  key,
) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return repository.isExerciseFavourite(key.userId, key.exerciseId);
});

/// Key for [isExerciseFavouriteProvider].
class _FavouriteKey {
  final String userId;
  final String exerciseId;
  const _FavouriteKey({required this.userId, required this.exerciseId});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FavouriteKey &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          exerciseId == other.exerciseId;
  @override
  int get hashCode => Object.hash(userId, exerciseId);
}

class ExerciseFavouriteNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool> toggle(String userId, String exerciseId) async {
    final repository = ref.read(exerciseRepositoryProvider);
    final next = await repository.toggleExerciseFavourite(userId, exerciseId);
    state = next;
    return next;
  }
}

final exerciseFavouriteProvider =
    NotifierProvider.autoDispose<ExerciseFavouriteNotifier, bool>(
      ExerciseFavouriteNotifier.new,
    );

/// All aliases for [userId].
final exerciseAliasesProvider =
    FutureProvider.family<List<ExerciseAlias>, String>((ref, userId) async {
      final repository = ref.read(exerciseRepositoryProvider);
      return repository.getExerciseAliases(userId);
    });

class ExerciseAliasNotifier extends Notifier<AsyncValue<List<ExerciseAlias>>> {
  /// Riverpod passes the family key (owner user id) to the constructor.
  ExerciseAliasNotifier(this._userId);

  final String _userId;

  @override
  AsyncValue<List<ExerciseAlias>> build() {
    _load();
    return const AsyncLoading();
  }

  Future<void> _load() async {
    final repository = ref.read(exerciseRepositoryProvider);
    try {
      final aliases = await repository.getExerciseAliases(_userId);
      state = AsyncData(aliases);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> set(String exerciseId, String alias) async {
    final repository = ref.read(exerciseRepositoryProvider);
    await repository.setExerciseAlias(_userId, exerciseId, alias);
    await _load();
  }

  Future<void> remove(String alias) async {
    final repository = ref.read(exerciseRepositoryProvider);
    await repository.removeExerciseAlias(_userId, alias);
    await _load();
  }
}

/// Notifier family for exercise aliases keyed by owner user id.
final exerciseAliasNotifierProvider = NotifierProvider.autoDispose
    .family<ExerciseAliasNotifier, AsyncValue<List<ExerciseAlias>>, String>(
      ExerciseAliasNotifier.new,
    );

final activeWorkoutControllerProvider =
    NotifierProvider<ActiveWorkoutController, ActiveWorkoutState>(
      ActiveWorkoutController.new,
    );
