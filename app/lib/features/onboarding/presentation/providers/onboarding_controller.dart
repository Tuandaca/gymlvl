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
// Classified onboarding failure
// ==============================
enum OnboardingFailureCode {
  validation,
  auth,
  backend,
  profileUnavailable,
  invalidClass,
  invalidProfile,
  unknown,
}

class OnboardingFailure implements Exception {
  final OnboardingFailureCode code;
  final String messageKey;
  final String? debugCode; // sanitized, no secrets

  OnboardingFailure({
    required this.code,
    required this.messageKey,
    this.debugCode,
  });

  @override
  String toString() => 'OnboardingFailure($code: $messageKey)';
}

/// Classify a raw error into a user-safe OnboardingFailure.
OnboardingFailure classifyOnboardingError(Object error, StackTrace? stack) {
  final errorString = error.toString();

  // PostgREST / Supabase error codes surface in the message.
  // PGRST202 = function not found; 42501 = auth/insufficient privilege;
  // 22023 = constraint violation / invalid parameter.
  final isMissingFunction =
      errorString.contains('PGRST202') ||
      errorString.contains('function') &&
          errorString.contains('does not exist');
  final isAuthError =
      errorString.contains('42501') ||
      errorString.contains('Authentication required');
  final isProfileUnavailable = errorString.contains(
    'Account profile unavailable',
  );
  final isInvalidClass = errorString.contains('Invalid class selection');
  final isInvalidProfile =
      errorString.contains('Invalid profile') ||
      errorString.contains('Complete the required profile information');

  // Sanitized debug code: never include JWT, keys, tokens, passwords, or user data.
  String? debugCode;
  if (isMissingFunction) {
    debugCode = 'PGRST202';
  } else if (isAuthError) {
    debugCode = '42501';
  } else if (isProfileUnavailable) {
    debugCode = '22023-profile';
  } else if (isInvalidClass) {
    debugCode = '22023-class';
  } else if (isInvalidProfile) {
    debugCode = '22023-profile';
  }

  if (isMissingFunction) {
    return OnboardingFailure(
      code: OnboardingFailureCode.backend,
      messageKey: 'onboarding_backend_error',
      debugCode: debugCode,
    );
  }
  if (isAuthError) {
    return OnboardingFailure(
      code: OnboardingFailureCode.auth,
      messageKey: 'onboarding_auth_error',
      debugCode: debugCode,
    );
  }
  if (isProfileUnavailable) {
    return OnboardingFailure(
      code: OnboardingFailureCode.profileUnavailable,
      messageKey: 'onboarding_profile_unavailable',
      debugCode: debugCode,
    );
  }
  if (isInvalidClass) {
    return OnboardingFailure(
      code: OnboardingFailureCode.invalidClass,
      messageKey: 'onboarding_invalid_class',
      debugCode: debugCode,
    );
  }
  if (isInvalidProfile) {
    return OnboardingFailure(
      code: OnboardingFailureCode.invalidProfile,
      messageKey: 'onboarding_invalid_profile',
      debugCode: debugCode,
    );
  }
  // Client-side validation errors (thrown by our own validation) are not
  // wrapped in PostgREST codes; they carry a plain message.
  if (errorString.startsWith('Vui lòng điền đầy đủ')) {
    return OnboardingFailure(
      code: OnboardingFailureCode.validation,
      messageKey: 'onboarding_validation_error',
      debugCode: 'client-validation',
    );
  }
  return OnboardingFailure(
    code: OnboardingFailureCode.unknown,
    messageKey: 'request_failed',
    debugCode: 'unknown',
  );
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

  // Gọi RPC để hoàn tất Onboarding
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
    // Classify any error so the UI can show a specific, user-safe message.
    if (result.hasError) {
      final classified = classifyOnboardingError(
        result.error as Object,
        result.stackTrace ?? StackTrace.empty,
      );
      // Sanitized debug diagnostic would go here in debug builds;
      // intentionally omitted to avoid any secret/token leakage.
      final classifiedError = AsyncValue.error(
        classified,
        result.stackTrace ?? StackTrace.empty,
      );
      if (ref.mounted && generation == _generation) state = classifiedError;
      return;
    }
    if (ref.mounted && generation == _generation) state = result;
  }
}
