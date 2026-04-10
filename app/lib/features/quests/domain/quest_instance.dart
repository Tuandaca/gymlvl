import 'package:freezed_annotation/freezed_annotation.dart';

part 'quest_instance.freezed.dart';
part 'quest_instance.g.dart';

@freezed
abstract class QuestInstance with _$QuestInstance {
  const factory QuestInstance({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'quest_id') required String questId,
    @JsonKey(name: 'prescribed_config') required List<PrescribedExercise> config,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'earned_xp') int? earnedXp,
  }) = _QuestInstance;

  factory QuestInstance.fromJson(Map<String, dynamic> json) =>
      _$QuestInstanceFromJson(json);
}

@freezed
abstract class PrescribedExercise with _$PrescribedExercise {
  const factory PrescribedExercise({
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'exercise_name') required String exerciseName,
    required int sets,
    required int reps,
    @JsonKey(name: 'weight_kg') required double weightKg,
  }) = _PrescribedExercise;

  factory PrescribedExercise.fromJson(Map<String, dynamic> json) =>
      _$PrescribedExerciseFromJson(json);
}
