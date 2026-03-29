import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../domain/user_profile_draft.dart';

// State chứa data nháp đang điền ở Form Onboarding
final onboardingDraftProvider = StateProvider<UserProfileDraft>((ref) {
  return const UserProfileDraft();
});

// Controller xử lý submit form
final onboardingControllerProvider = AsyncNotifierProvider<OnboardingController, void>(() {
  return OnboardingController();
});

class OnboardingController extends AsyncNotifier<void> {

  @override
  FutureOr<void> build() {
    // Intentionally left empty
  }

  // Cập nhật từng mảng thông tin
  void updateDraft(UserProfileDraft Function(UserProfileDraft current) updater) {
    final current = ref.read(onboardingDraftProvider);
    ref.read(onboardingDraftProvider.notifier).state = updater(current);
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
        'class_name': draft.className ?? 'Iron Warrior', // Fallback, thực tế nên tính từ hàm update
        'experience_level': draft.experienceLevel,
        'age': draft.age,
        'gender': draft.gender,
        'height_cm': draft.heightCm,
        'weight_kg': draft.weightKg,
      });

      // 3. Gọi Supabase Edge Function `initialize-user` để cấu hình Level và Quest ban đầu
      await SupabaseConfig.client.functions.invoke(
        'initialize-user',
        // Gửi body kèm data nếu Edge Function cần (ví dụ để biết exp level)
        body: {'experience_level': draft.experienceLevel}, 
      );

      // Thêm log/event báo router check lại AuthGuard, do supabase edge-function sẽ đổi `onboarding_completed` 
      // lên database. Frontend có thể cần tự cập nhật session / stream auth state 
      // để router quét lại. GoRouter theo dõi `authStateStream`, nên khi xong có thể cần trigger nó.
    });
  }
}
