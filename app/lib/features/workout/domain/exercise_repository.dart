import 'exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises();
  Future<List<Exercise>> searchExercises(String query);
  Future<List<Exercise>> getExercisesByCategory(String category);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Custom exercises (P7 Gate 1) — user-owned, source = 'user'.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Owner's custom exercises (archived excluded by default).
  Future<List<Exercise>> getCustomExercises(String userId);

  /// Owner's archived custom exercises (history-preserving soft delete).
  Future<List<Exercise>> getArchivedCustomExercises(String userId);

  /// Create a user-owned custom exercise. [exercise.source] must be 'user' and
  /// [exercise.userId] must equal the authenticated owner.
  Future<Exercise> createCustomExercise(Exercise exercise);

  /// Update an owner's custom exercise. Ownership and source cannot be
  /// retargeted through this path.
  Future<Exercise> updateCustomExercise(Exercise exercise);

  /// Soft-archive a custom exercise. Historical workout_exercises references
  /// remain valid; the row is kept so history stays readable.
  Future<void> archiveCustomExercise(String exerciseId);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Exercise favourites (P7 Gate 2) — owner-scoped, catalogue rows untouched.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Whether [exerciseId] is favourited by [userId].
  Future<bool> isExerciseFavourite(String userId, String exerciseId);

  /// Toggle the favourite state of [exerciseId] for [userId].
  /// Returns the new state.
  Future<bool> toggleExerciseFavourite(String userId, String exerciseId);

  /// Exercise IDs favourited by [userId].
  Future<List<String>> favouriteExerciseIds(String userId);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Exercise aliases (P7 Gate 2) — owner-scoped alias -> canonical exercise.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// All aliases for [userId].
  Future<List<ExerciseAlias>> getExerciseAliases(String userId);

  /// Create or update an alias pointing [alias] at canonical [exerciseId] for
  /// [userId]. Alias is unique per user.
  Future<void> setExerciseAlias(String userId, String exerciseId, String alias);

  /// Remove [alias] for [userId].
  Future<void> removeExerciseAlias(String userId, String alias);

  /// Resolve [alias] to its canonical exercise id for [userId], or null.
  Future<String?> resolveExerciseAlias(String userId, String alias);
}

/// Owner-scoped alias -> canonical exercise mapping.
///
/// The canonical exercise identity ([exerciseId]) and history are preserved;
/// the alias is a personal display name only and never creates a duplicate
/// exercise row.
class ExerciseAlias {
  const ExerciseAlias({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.alias,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String exerciseId;
  final String alias;
  final DateTime? createdAt;

  /// Build from a Supabase JSON row (snake_case keys).
  factory ExerciseAlias.fromJson(Map<String, dynamic> json) => ExerciseAlias(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        exerciseId: json['exercise_id'] as String,
        alias: json['alias'] as String,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
      );

  /// Serialize to Supabase JSON (snake_case keys).
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_id': userId,
        'exercise_id': exerciseId,
        'alias': alias,
        'created_at': createdAt?.toUtc().toIso8601String(),
      };

  ExerciseAlias copyWith({
    String? id,
    String? userId,
    String? exerciseId,
    String? alias,
    DateTime? createdAt,
  }) {
    return ExerciseAlias(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      alias: alias ?? this.alias,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAlias &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          exerciseId == other.exerciseId &&
          alias == other.alias;

  @override
  int get hashCode => Object.hash(id, userId, exerciseId, alias);

  @override
  String toString() =>
      'ExerciseAlias(id: $id, alias: $alias -> exercise_id: $exerciseId, user_id: $userId)';
}
