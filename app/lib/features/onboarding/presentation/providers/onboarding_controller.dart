import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/user_profile_draft.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ==============================
// Draft Notifier (thay thế StateProvider đã bị xoá ở Riverpod 3.x)
// ==============================
final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftNotifier, UserProfileDraft>(() {
      return OnboardingDraftNotifier();
    });

class OnboardingDraftNotifier extends Notifier<UserProfileDraft> {
  @override
  UserProfileDraft build() {
    ref.watch(
      authStateStreamProvider.select((auth) => auth.value?.session?.user.id),
    );
    return const UserProfileDraft();
  }

  void set(UserProfileDraft newDraft) {
    state = newDraft;
  }

  void update(UserProfileDraft Function(UserProfileDraft current) updater) {
    state = updater(state);
  }
}

// ==============================
// Controller xử lý submit form
// ==============================
final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, void>(() {
      return OnboardingController();
    });

class OnboardingController extends AsyncNotifier<void> {
  int _generation = 0;

  @override
  FutureOr<void> build() {
    ref.watch(
      authStateStreamProvider.select((auth) => auth.value?.session?.user.id),
    );
    _generation++;
  }

  // Gọi Edge Function để hoàn tất Onboarding
  Future<void> submitOnboarding() async {
    if (state.isLoading) return;
    final generation = _generation;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final draft = ref.read(onboardingDraftProvider);

      // 1. Validate (chắc chắn draft đã đủ trường)
      if (draft.environment == null ||
          draft.goals.isEmpty ||
          draft.experienceLevel == null ||
          draft.age == null ||
          draft.gender == null ||
          draft.heightCm == null ||
          draft.weightKg == null ||
          draft.primaryClassId == null) {
        throw Exception('Vui lòng điền đầy đủ các thông tin quan trọng.');
      }

      // Identity and every progression value are assigned by the transaction.
      await SupabaseConfig.client.rpc(
        'initialize_user',
        params: {
          'p_profile': {
            'environment': draft.environment,
            'goals': draft.goals,
            'experience_level': draft.experienceLevel,
            'age': draft.age,
            'gender': draft.gender,
            'height_cm': draft.heightCm,
            'weight_kg': draft.weightKg,
            'weekly_gym_days': draft.weeklyGymDays,
            'weekly_home_days': draft.weeklyHomeDays,
            'preferred_training_days': draft.preferredDays,
            'primary_class_id': draft.primaryClassId,
            'secondary_class_id': draft.secondaryClassId,
            'timezone': 'Asia/Ho_Chi_Minh',
          },
        },
      );
      if (!ref.mounted || generation != _generation) return;
      ref.invalidate(currentUserProfileProvider);

      // 6. Force refresh the user session so the router detects onboarding_completed = true
      ref.invalidate(currentUserProvider);
    });
    if (ref.mounted && generation == _generation) state = result;
  }
}
