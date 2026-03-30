import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/user_profile_draft.dart';

// ==============================
// Draft Notifier (thay thế StateProvider đã bị xoá ở Riverpod 3.x)
// ==============================
final onboardingDraftProvider = NotifierProvider<OnboardingDraftNotifier, UserProfileDraft>(() {
  return OnboardingDraftNotifier();
});

class OnboardingDraftNotifier extends Notifier<UserProfileDraft> {
  @override
  UserProfileDraft build() => const UserProfileDraft();

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
final onboardingControllerProvider = AsyncNotifierProvider<OnboardingController, void>(() {
  return OnboardingController();
});

class OnboardingController extends AsyncNotifier<void> {

  @override
  FutureOr<void> build() {
    // Intentionally left empty
  }

  // Gọi Edge Function để hoàn tất Onboarding
  Future<void> submitOnboarding() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final draft = ref.read(onboardingDraftProvider);
      
      // 1. Validate (chắc chắn draft đã đủ trường)
      if (draft.environment == null || 
          draft.goals.isEmpty || 
          draft.experienceLevel == null || 
          draft.age == null || 
          draft.gender == null || 
          draft.heightCm == null || 
          draft.weightKg == null) {
        throw Exception('Vui lòng điền đầy đủ các thông tin quan trọng.');
      }

      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Ứng dụng mất kết nối phiên đăng nhập.');

      // 2. Chèn dữ liệu vào bảng profiles
      await SupabaseConfig.client.from('profiles').insert({
        'id': userId,
        'environment': draft.environment,
        'goals': draft.goals,
        'class_name': draft.className ?? 'Iron Warrior',
        'experience_level': draft.experienceLevel,
        'age': draft.age,
        'gender': draft.gender,
        'height_cm': draft.heightCm,
        'weight_kg': draft.weightKg,
      });

      // 3. Gọi Supabase Edge Function `initialize-user`
      await SupabaseConfig.client.functions.invoke(
        'initialize-user',
        body: {'experience_level': draft.experienceLevel}, 
      );
    });
  }
}
