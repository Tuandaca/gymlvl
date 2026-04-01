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
}
