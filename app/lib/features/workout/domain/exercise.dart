// Freezed forwards factory parameter JsonKey annotations to generated fields.
// See https://pub.dev/packages/freezed#disabling-invalid_annotation_target-warning-and-warning-in-generates-files
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
abstract class Exercise with _$Exercise {
  const Exercise._();

  const factory Exercise({
    required String id,
    required String name,
    required String category,
    required String equipment,
    @JsonKey(name: 'force_type') String? forceType,
    String? mechanic,
    @Default([]) List<String> instructions,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'slug') String? slug,
    @JsonKey(name: 'name_vi') @Default('') String nameVi,
    @JsonKey(name: 'name_en') @Default('') String nameEn,
    @JsonKey(name: 'movement_pattern') String? movementPattern,
    @JsonKey(name: 'secondary_muscles')
    @Default([])
    List<String> secondaryMuscles,
    String? difficulty,
    @JsonKey(name: 'form_cues') @Default([]) List<String> formCues,
    @JsonKey(name: 'common_mistakes') @Default([]) List<String> commonMistakes,
    @JsonKey(name: 'alternative_exercise_slugs')
    @Default([])
    List<String> alternativeExerciseSlugs,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  String localizedName([String locale = 'en']) {
    if (locale.toLowerCase().startsWith('vi') && nameVi.isNotEmpty) {
      return nameVi;
    }
    if (nameEn.isNotEmpty) {
      return nameEn;
    }
    return name;
  }

  bool get isBodyweight => equipment.toLowerCase().contains('body');

  bool get isTimeBased =>
      forceType?.toLowerCase() == 'static' ||
      movementPattern == 'carry' ||
      category.toLowerCase() == 'cardio' ||
      (slug?.contains('plank') ?? false);
}
