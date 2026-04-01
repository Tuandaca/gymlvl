import 'exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises();
  Future<List<Exercise>> searchExercises(String query);
  Future<List<Exercise>> getExercisesByCategory(String category);
}
