import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_draft.freezed.dart';
part 'user_profile_draft.g.dart';

@freezed
abstract class UserProfileDraft with _$UserProfileDraft {
  const factory UserProfileDraft({
    // 1. Environment
    String? environment,
    
    // 2. Goals (max 3)
    @Default([]) List<String> goals,
    
    // 3. Class (generated after environment and goals)
    String? className,

    // 4. Experience Level
    String? experienceLevel,

    // 5. Biometrics
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,

    // 6. Scheduling & Frequency
    @Default(3) int weeklyGymDays,
    @Default(0) int weeklyHomeDays,
    @Default([]) List<String> preferredDays,
  }) = _UserProfileDraft;

  factory UserProfileDraft.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDraftFromJson(json);
}
