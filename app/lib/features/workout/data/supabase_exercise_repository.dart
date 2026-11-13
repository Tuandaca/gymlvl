import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/exercise.dart';
import '../domain/exercise_repository.dart';

class SupabaseExerciseRepository implements ExerciseRepository {
  final SupabaseClient _supabase;

  SupabaseExerciseRepository(this._supabase);

  @override
  Future<List<Exercise>> getExercises() async {
    final response = await _supabase
        .from('exercises')
        .select()
        .order('name', ascending: true);

    return (response as List).map((json) => Exercise.fromJson(json)).toList();
  }

  @override
  Future<List<Exercise>> searchExercises(String query) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .ilike('name', '%$query%')
        .order('name', ascending: true);

    return (response as List).map((json) => Exercise.fromJson(json)).toList();
  }

  @override
  Future<List<Exercise>> getExercisesByCategory(String category) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .eq('category', category)
        .order('name', ascending: true);

    return (response as List).map((json) => Exercise.fromJson(json)).toList();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Custom exercises (P7 Gate 1)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  @override
  Future<List<Exercise>> getCustomExercises(String userId) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .eq('user_id', userId)
        .eq('source', 'user')
        .eq('is_archived', false)
        .order('name', ascending: true);

    return (response as List).map((json) => Exercise.fromJson(json)).toList();
  }

  @override
  Future<List<Exercise>> getArchivedCustomExercises(String userId) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .eq('user_id', userId)
        .eq('source', 'user')
        .eq('is_archived', true)
        .order('name', ascending: true);

    return (response as List).map((json) => Exercise.fromJson(json)).toList();
  }

  @override
  Future<Exercise> createCustomExercise(Exercise exercise) async {
    if (exercise.source != 'user') {
      throw ArgumentError('custom_exercise must have source == "user"');
    }
    final ownerId = exercise.userId;
    if (ownerId == null) {
      throw ArgumentError('custom_exercise must have a non-null userId');
    }

    final payload = exercise.toJson()
      ..remove('created_at')
      ..remove('updated_at');
    final response = await _supabase
        .from('exercises')
        .insert(payload)
        .select()
        .single();

    return Exercise.fromJson(response);
  }

  @override
  Future<Exercise> updateCustomExercise(Exercise exercise) async {
    if (exercise.source != 'user') {
      throw ArgumentError('custom_exercise must have source == "user"');
    }
    final ownerId = exercise.userId;
    if (ownerId == null) {
      throw ArgumentError('custom_exercise must have a non-null userId');
    }

    final payload = exercise.toJson()
      ..remove('created_at')
      ..remove('updated_at');
    final response = await _supabase
        .from('exercises')
        .update(payload)
        .eq('id', exercise.id)
        .eq('user_id', ownerId)
        .select()
        .single();

    return Exercise.fromJson(response);
  }

  @override
  Future<void> archiveCustomExercise(String exerciseId) async {
    await _supabase
        .from('exercises')
        .update({'is_archived': true})
        .eq('id', exerciseId)
        .eq('source', 'user');
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Exercise favourites (P7 Gate 2)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  @override
  Future<bool> isExerciseFavourite(String userId, String exerciseId) async {
    final response = await _supabase
        .from('exercise_favourites')
        .select('id')
        .eq('user_id', userId)
        .eq('exercise_id', exerciseId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<bool> toggleExerciseFavourite(String userId, String exerciseId) async {
    final already = await isExerciseFavourite(userId, exerciseId);
    if (already) {
      await _supabase
          .from('exercise_favourites')
          .delete()
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId);
      return false;
    }

    await _supabase.from('exercise_favourites').insert(<String, dynamic>{
      'user_id': userId,
      'exercise_id': exerciseId,
    });
    return true;
  }

  @override
  Future<List<String>> favouriteExerciseIds(String userId) async {
    final response = await _supabase
        .from('exercise_favourites')
        .select('exercise_id')
        .eq('user_id', userId);

    return (response as List)
        .map((row) => row['exercise_id'] as String)
        .toList();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Exercise aliases (P7 Gate 2)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  @override
  Future<List<ExerciseAlias>> getExerciseAliases(String userId) async {
    final response = await _supabase
        .from('exercise_aliases')
        .select()
        .eq('user_id', userId)
        .order('alias', ascending: true);

    return (response as List)
        .map((json) => ExerciseAlias.fromJson(json))
        .toList();
  }

  @override
  Future<void> setExerciseAlias(
    String userId,
    String exerciseId,
    String alias,
  ) async {
    final trimmed = alias.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('alias must not be empty');
    }

    final existing = await _supabase
        .from('exercise_aliases')
        .select('id')
        .eq('user_id', userId)
        .eq('alias', trimmed)
        .maybeSingle();

    if (existing != null) {
      // Repoint an existing alias to a (possibly) different canonical exercise.
      await _supabase
          .from('exercise_aliases')
          .update({'exercise_id': exerciseId})
          .eq('id', existing['id']);
      return;
    }

    await _supabase.from('exercise_aliases').insert(<String, dynamic>{
      'user_id': userId,
      'exercise_id': exerciseId,
      'alias': trimmed,
    });
  }

  @override
  Future<void> removeExerciseAlias(String userId, String alias) async {
    await _supabase
        .from('exercise_aliases')
        .delete()
        .eq('user_id', userId)
        .eq('alias', alias);
  }

  @override
  Future<String?> resolveExerciseAlias(String userId, String alias) async {
    final response = await _supabase
        .from('exercise_aliases')
        .select('exercise_id')
        .eq('user_id', userId)
        .eq('alias', alias)
        .maybeSingle();

    if (response == null) return null;
    return response['exercise_id'] as String?;
  }
}
