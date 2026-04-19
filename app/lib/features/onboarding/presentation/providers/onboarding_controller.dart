import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/user_profile_draft.dart';
import '../../domain/class_definitions.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

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
          draft.weightKg == null ||
          draft.primaryClassId == null) {
        throw Exception('Vui lòng điền đầy đủ các thông tin quan trọng.');
      }

      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Ứng dụng mất kết nối phiên đăng nhập.');

      // Resolve class info from static definitions
      final primaryClass = kClassDefinitions[draft.primaryClassId];
      final secondaryClass = draft.secondaryClassId != null 
          ? kClassDefinitions[draft.secondaryClassId] 
          : null;

      if (primaryClass == null) throw Exception('Lớp chính không hợp lệ.');

      // 2. Chèn/Cập nhật dữ liệu vào bảng profiles
      await SupabaseConfig.client.from('profiles').upsert({
        'id': userId,
        'environment': draft.environment,
        'goals': draft.goals,
        'class_name': primaryClass.className, // Legacy field
        'experience_level': draft.experienceLevel,
        'age': draft.age,
        'gender': draft.gender,
        'height_cm': draft.heightCm,
        'weight_kg': draft.weightKg,
        'weekly_gym_days': draft.weeklyGymDays,
        'weekly_home_days': draft.weeklyHomeDays,
        'preferred_training_days': draft.preferredDays,
      });

      // 3. Chèn Primary Class vào bảng user_classes
      await SupabaseConfig.client.from('user_classes').upsert({
        'user_id': userId,
        'class_id': primaryClass.classId,
        'class_name': primaryClass.className,
        'slot': 'primary',
        'difficulty': primaryClass.difficulty,
        'current_xp': 0,
        'level': 1,
      }, onConflict: 'user_id,slot');

      // 4. Chèn Secondary Class (nếu có)
      if (secondaryClass != null) {
        await SupabaseConfig.client.from('user_classes').upsert({
          'user_id': userId,
          'class_id': secondaryClass.classId,
          'class_name': secondaryClass.className,
          'slot': 'secondary',
          'difficulty': secondaryClass.difficulty,
          'current_xp': 0,
          'level': 1,
        }, onConflict: 'user_id,slot');
      }

      // 5. Khởi tạo User record
      int initialLevel = 1;
      String initialTitle = 'Tân Sinh Phấn Tạ';

      if (draft.experienceLevel == 'intermediate') {
        initialLevel = 11;
        initialTitle = 'Kẻ Săn Cơ';
      } else if (draft.experienceLevel == 'advanced') {
        initialLevel = 21;
        initialTitle = 'Tay Tạ Sắt';
      }

      await SupabaseConfig.client.from('users').upsert({
        'id': userId,
        'email': SupabaseConfig.client.auth.currentUser?.email,
        'display_name': SupabaseConfig.client.auth.currentUser?.userMetadata?['full_name'] ?? 'User',
        'level': initialLevel,
        'current_title': initialTitle,
        'onboarding_completed': true,
      });

      // 6. Force refresh the user session so the router detects onboarding_completed = true
      ref.invalidate(currentUserProvider);
    });
  }
}

