class WorkoutTemplates {
  static const Map<String, List<String>> presets = {
    'Chest': [
      'Bench Press (Barbell)',
      'Incline Bench Press (Dumbbell)',
      'Chest Fly (Machine)',
      'Push-up',
    ],
    'Back': [
      'Deadlift (Barbell)',
      'Pull-up',
      'Lat Pulldown (Cable)',
      'Seated Cable Row',
    ],
    'Legs': [
      'Squat (Barbell)',
      'Leg Press',
      'Leg Extension',
      'Lying Leg Curl',
    ],
    'Shoulders': [
      'Overhead Press (Barbell)',
      'Lateral Raise (Dumbbell)',
      'Face Pull (Cable)',
    ],
    'Arms': [
      'Bicep Curl (Barbell)',
      'Hammer Curl (Dumbbell)',
      'Tricep Pushdown (Cable)',
      'Skull Crusher (Barbell)',
    ],
    'Core': [
      'Plank',
      'Crunch',
      'Leg Raise',
    ],
  };

  /// Gộp bài tập từ nhiều nhóm cơ, loại bỏ trùng lặp
  static List<String> getExercisesForCategories(List<String> categories) {
    final result = <String>[];
    for (final cat in categories) {
      final exercises = presets[cat] ?? [];
      for (final ex in exercises) {
        if (!result.contains(ex)) result.add(ex);
      }
    }
    return result;
  }
}
