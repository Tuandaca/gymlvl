import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/onboarding/domain/class_definitions.dart';

enum AppLangMode { vi, en, bilingual }

String translateText(WidgetRef ref, {required String vi, required String en}) {
  final mode = ref.watch(localizationModeProvider);
  return switch (mode) {
    AppLangMode.vi => vi,
    AppLangMode.en => en,
    AppLangMode.bilingual => '$vi\n[$en]',
  };
}

/// Quản lý state của Language Mode
final localizationModeProvider =
    NotifierProvider<LocalizationModeNotifier, AppLangMode>(() {
      return LocalizationModeNotifier();
    });

class LocalizationModeNotifier extends Notifier<AppLangMode> {
  @override
  AppLangMode build() {
    _loadFromPrefs();
    return AppLangMode.vi; // Initial synchronous state
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('lang_mode');
    if (modeStr != null) {
      if (modeStr == 'en') state = AppLangMode.en;
      if (modeStr == 'bilingual') state = AppLangMode.bilingual;
    }
  }

  Future<void> setMode(AppLangMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_mode', mode.name);
  }
}

/// Dữ liệu từ vựng (Dictionary)
const Map<String, Map<String, String>> _dictionary = {
  'retry': {'vi': 'Thử lại', 'en': 'Retry'},
  'load_failed': {
    'vi': 'Chưa tải được dữ liệu. Kiểm tra kết nối rồi thử lại.',
    'en': 'Could not load your data. Check your connection and try again.',
  },
  'request_failed': {
    'vi': 'Không thể hoàn tất yêu cầu. Vui lòng thử lại.',
    'en': 'Could not complete your request. Please try again.',
  },
  'login': {'vi': 'Đăng nhập', 'en': 'Sign in'},
  'register': {'vi': 'Tạo tài khoản', 'en': 'Create account'},
  'auth_intro': {
    'vi': 'Tập luyện hôm nay. Mạnh hơn mỗi ngày.',
    'en': 'Train today. Grow stronger every day.',
  },
  'auth_email': {'vi': 'Email', 'en': 'Email'},
  'auth_password': {'vi': 'Mật khẩu', 'en': 'Password'},
  'auth_confirm_password': {
    'vi': 'Nhập lại mật khẩu',
    'en': 'Confirm password',
  },
  'invalid_email': {
    'vi': 'Nhập địa chỉ email hợp lệ.',
    'en': 'Enter a valid email address.',
  },
  'password_required': {
    'vi': 'Nhập mật khẩu của bạn.',
    'en': 'Enter your password.',
  },
  'password_min': {
    'vi': 'Mật khẩu cần ít nhất 8 ký tự.',
    'en': 'Use at least 8 characters.',
  },
  'password_mismatch': {
    'vi': 'Hai mật khẩu chưa khớp.',
    'en': 'Passwords do not match.',
  },
  'auth_failed': {
    'vi': 'Không thể đăng nhập. Kiểm tra email, mật khẩu và kết nối.',
    'en': 'Could not sign in. Check your email, password, and connection.',
  },
  'register_failed': {
    'vi': 'Không thể tạo tài khoản. Kiểm tra thông tin và thử lại.',
    'en': 'Could not create your account. Check your details and try again.',
  },
  'check_email': {
    'vi': 'Kiểm tra email để xác nhận tài khoản, sau đó quay lại đăng nhập.',
    'en': 'Check your email to confirm your account, then return to sign in.',
  },
  'forgot_password': {'vi': 'Quên mật khẩu?', 'en': 'Forgot password?'},
  'reset_email_sent': {
    'vi':
        'Nếu email này đã đăng ký, bạn sẽ nhận được liên kết đặt lại mật khẩu.',
    'en':
        'If this email is registered, you will receive a password reset link.',
  },
  'new_player': {'vi': 'Lần đầu đến GymLevel?', 'en': 'New to GymLevel?'},
  'already_registered': {
    'vi': 'Đã có tài khoản?',
    'en': 'Already have an account?',
  },
  'continue': {'vi': 'Tiếp tục', 'en': 'Continue'},
  'awaken': {'vi': 'Bắt đầu hành trình', 'en': 'Begin your journey'},
  'step': {'vi': 'Bước', 'en': 'Step'},
  'level': {'vi': 'Cấp độ', 'en': 'Level'},
  'level_up': {'vi': 'THĂNG CẤP!', 'en': 'LEVEL UP!'},
  'workout_complete': {'vi': 'HOÀN THÀNH BUỔI TẬP', 'en': 'WORKOUT COMPLETE'},
  'total_xp': {'vi': 'Tổng XP', 'en': 'Total XP'},
  'quest_active': {'vi': 'Lịch tập hôm nay', 'en': 'Today’s routine'},
  'quest_complete': {
    'vi': 'Đã hoàn thành mục tiêu',
    'en': 'Objective complete',
  },
  'quest_reward_hint': {
    'vi': 'Phần thưởng được xác nhận sau khi hoàn thành đủ bài tập.',
    'en': 'Rewards are confirmed when the prescribed exercises are complete.',
  },
  'quest_start_failed': {
    'vi':
        'Chưa thể bắt đầu nhiệm vụ. Hoàn thành buổi tập đang dở hoặc thử lại.',
    'en':
        'Could not start this quest. Finish your active workout or try again.',
  },
  'rest_day': {
    'vi': 'Hôm nay chưa có nhiệm vụ. Bạn vẫn có thể bắt đầu buổi tập riêng.',
    'en': 'No quest today. You can still start your own workout.',
  },
  'primary_class': {'vi': 'Chính', 'en': 'Primary'},
  'secondary_class': {'vi': 'Phụ', 'en': 'Secondary'},
  'weekly_volume': {
    'vi': 'TỔNG TẠ TRONG TUẦN (kg)',
    'en': 'WEEKLY VOLUME (kg)',
  },
  'muscle_balance': {'vi': 'PHÂN BỐ NHÓM CƠ', 'en': 'MUSCLE BALANCE'},
  'profile_saved': {'vi': 'Đã lưu hồ sơ.', 'en': 'Profile saved.'},
  'profile_invalid': {
    'vi':
        'Kiểm tra tên, tuổi (13–100), chiều cao (100–250 cm), cân nặng (25–400 kg) và lịch tập tối đa 7 buổi/tuần.',
    'en':
        'Check your name, age (13–100), height (100–250 cm), weight (25–400 kg), and schedule (at most 7 sessions/week).',
  },
  'edit_profile': {'vi': 'Chỉnh sửa hồ sơ', 'en': 'Edit profile'},
  'class_switched': {'vi': 'Đã đổi hệ phái.', 'en': 'Class updated.'},
  // Common
  'save': {'vi': 'LƯU', 'en': 'SAVE'},
  'cancel': {'vi': 'HỦY', 'en': 'CANCEL'},
  'start': {'vi': 'BẮT ĐẦU', 'en': 'START'},
  'logout': {'vi': 'ĐĂNG XUẤT', 'en': 'LOGOUT'},

  // Dashboard
  'system_hub': {'vi': 'TRUNG TÂM HỆ THỐNG', 'en': 'SYSTEM HUB'},
  'todays_objective': {'vi': 'MỤC TIÊU HÔM NAY', 'en': 'TODAY\'S OBJECTIVE'},
  'biometric_analysis': {'vi': 'PHÂN TÍCH CHỈ SỐ', 'en': 'BIOMETRIC ANALYSIS'},
  'no_class_selected': {
    'vi': 'Chưa kích hoạt Môn phái nào.',
    'en': 'No class selected yet.',
  },
  'no_data_recorded': {
    'vi': 'Chưa có hồ sơ dữ liệu.',
    'en': 'No data recorded yet.',
  },

  // Main Shell / Navigation
  'dashboard_tab': {'vi': 'TỔNG QUAN', 'en': 'DASHBOARD'},
  'training_tab': {'vi': 'TẬP LUYỆN', 'en': 'TRAINING'},
  'quests_tab': {'vi': 'NHIỆM VỤ', 'en': 'QUESTS'},
  'profile_tab': {'vi': 'HỒ SƠ', 'en': 'PROFILE'},

  // Profile
  'system_character': {'vi': 'HỆ THỐNG NHÂN VẬT', 'en': 'CHARACTER SYSTEM'},
  'biometrics_board': {'vi': 'CHỈ SỐ CƠ THỂ', 'en': 'BIOMETRICS BOARD'},
  'battle_schedule': {'vi': 'LỊCH TRÌNH TẬP LUYỆN', 'en': 'BATTLE SCHEDULE'},
  'active_classes': {'vi': 'HỆ PHÁI KÍCH HOẠT', 'en': 'ACTIVE CLASSES'},
  'age': {'vi': 'TUỔI', 'en': 'AGE'},
  'height': {'vi': 'CAO', 'en': 'HEIGHT'},
  'weight': {'vi': 'NẶNG', 'en': 'WEIGHT'},
  'gym_home_ratio': {'vi': 'TỈ LỆ GYM/NHÀ', 'en': 'GYM/HOME RATIO'},
  'preferred_protocols': {'vi': 'NGÀY ƯU TIÊN', 'en': 'PREFERRED PROTOCOLS'},
  'days': {'vi': 'NGÀY', 'en': 'DAYS'},

  // Classes
  'choose_class': {'vi': 'CHỌN CLASS', 'en': 'SELECT CLASS'},
  'retro_leveling_desc': {
    'vi':
        'RETROSPECTIVE LEVELING: Hệ thống sẽ đánh giá lại lịch sử tập luyện của bạn để tính toán Level phù hợp cho Class mới thay vì quay về Level 1.',
    'en':
        'RETRO LEVELING: The system scans your battle history to calculate an appropriate Level for the new Class instead of resetting to Lv 1.',
  },
  'confirm_switch': {
    'vi': 'Xác nhận Đổi Class?',
    'en': 'Confirm Class Switch?',
  },
  'confirm_switch_desc': {
    'vi':
        'Hệ thống sẽ đồng bộ lịch sử tập luyện chuyên biệt của bạn vào Class mới.',
    'en':
        'The system will synchronize your specialized training history into the new Class.',
  },
  'class_locked_synergy': {
    'vi': 'CHỈ ĐƯỢC CHỌN CLASS TƯƠNG THÍCH (SYNERGY)',
    'en': 'MUST SELECT SYNERGISTIC CLASS',
  },

  // Workout / Training
  'start_workout': {'vi': 'BẮT ĐẦU TẬP', 'en': 'START WORKOUT'},
  'workout_history': {'vi': 'LỊCH SỬ TẬP', 'en': 'WORKOUT HISTORY'},
  'exercises': {'vi': 'BÀI TẬP', 'en': 'EXERCISES'},
  'duration': {'vi': 'THỜI GIAN', 'en': 'DURATION'},
  'volume': {'vi': 'TỔNG TẠ', 'en': 'VOLUME'},
  'finish_workout': {'vi': 'KẾT THÚC', 'en': 'FINISH WORKOUT'},
  'cancel_workout': {'vi': 'HỦY LƯỢT TẬP', 'en': 'ABORT MISSION'},
  'add_exercise': {'vi': 'THÊM BÀI TẬP', 'en': 'ADD EXERCISE'},
  'add_set': {'vi': 'THÊM SET', 'en': 'ADD SET'},
  'reps': {'vi': 'Số Rep', 'en': 'Reps'},
  'weight_kg': {'vi': 'Trọng lượng (kg)', 'en': 'Weight (kg)'},
  'training_title': {'vi': 'LUYỆN TẬP', 'en': 'TRAINING'},
  'ready_to_level_up': {
    'vi': 'Sẵn sàng để thăng cấp?',
    'en': 'Ready to level up?',
  },
  'start_workout_desc': {
    'vi': 'Bắt đầu buổi tập để kiếm XP và thăng cấp!',
    'en': 'Start a workout to earn XP and level up!',
  },
  'start_session': {'vi': 'BẮT ĐẦU BUỔI TẬP', 'en': 'START SESSION'},
  'recent': {'vi': 'GẦN ĐÂY', 'en': 'RECENT'},
  'view_all': {'vi': 'Xem tất cả →', 'en': 'View all →'},
  'no_workouts_yet': {'vi': 'Chưa có buổi tập nào', 'en': 'No workouts yet'},
  'active_workout': {'vi': 'BUỔI TẬP ĐANG DỞ', 'en': 'ACTIVE WORKOUT'},
  'continue_workout': {'vi': 'TIẾP TỤC TẬP', 'en': 'CONTINUE'},

  // Quests
  'quests_title': {'vi': 'NHIỆM VỤ', 'en': 'QUESTS'},
  'mainframe_objectives': {
    'vi': 'MỤC TIÊU CHÍNH',
    'en': 'MAINFRAME OBJECTIVES',
  },
  'no_missions': {'vi': 'CHƯA CÓ NHIỆM VỤ', 'en': 'NO MISSIONS ASSIGNED'},
  'no_missions_desc': {
    'vi': 'Quay lại sau để nhận nhiệm vụ mới hoặc đồng bộ lại.',
    'en': 'Check back later for new objectives or force sync manually.',
  },
  'main_quest': {'vi': 'QUEST CHÍNH TUYẾN', 'en': 'MAIN QUEST'},
  'hidden_quest': {'vi': 'NHIỆM VỤ ẨN', 'en': 'HIDDEN QUEST'},
  'locked': {'vi': 'KHÓA', 'en': 'LOCKED'},
  'daily_quests': {'vi': 'NHIỆM VỤ NGÀY', 'en': 'DAILY QUESTS'},
  'weekly_quests': {'vi': 'NHIỆM VỤ TUẦN', 'en': 'WEEKLY QUESTS'},
  'lifetime_quests': {'vi': 'THÀNH TỰU', 'en': 'ACHIEVEMENTS'},
  'claim_reward': {'vi': 'NHẬN THƯỞNG', 'en': 'CLAIM REWARD'},
  'completed': {'vi': 'HOÀN THÀNH', 'en': 'COMPLETED'},
  'progress': {'vi': 'TIẾN ĐỘ', 'en': 'PROGRESS'},

  // Confirm dialogs
  'confirm_logout': {'vi': 'Đăng xuất?', 'en': 'Logout?'},
  'confirm_logout_desc': {
    'vi': 'Bạn có chắc muốn thoát tài khoản hiện tại?',
    'en': 'Are you sure you want to sign out of this account?',
  },
  'confirm': {'vi': 'Đồng ý', 'en': 'Confirm'},
};

extension StringL10n on String {
  /// Hàm extension để dịch string. Ví dụ: 'save'.tr(ref)
  String tr(WidgetRef ref) {
    final mode = ref.watch(localizationModeProvider);
    final keyDict = _dictionary[this];

    if (keyDict == null) return this; // Return original if not translated

    final viStr = keyDict['vi'] ?? this;
    final enStr = keyDict['en'] ?? this;

    if (mode == AppLangMode.vi) return viStr;
    if (mode == AppLangMode.en) return enStr;

    // Bilingual mode
    return '$viStr\n[$enStr]';
  }

  /// Inline bilingual for tight spaces (e.g., "TUỔI / AGE")
  String trInline(WidgetRef ref) {
    final mode = ref.watch(localizationModeProvider);
    final keyDict = _dictionary[this];

    if (keyDict == null) return this;

    final viStr = keyDict['vi'] ?? this;
    final enStr = keyDict['en'] ?? this;

    if (mode == AppLangMode.vi) return viStr;
    if (mode == AppLangMode.en) return enStr;

    return '$viStr / $enStr';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// Helpers cho ClassDefinition - resolve bilingual fields
/// ═══════════════════════════════════════════════════════════════
/// ═══════════════════════════════════════════════════════════════

String resolveClassName(ClassDefinition cls, AppLangMode mode) {
  if (mode == AppLangMode.vi) return cls.classNameVI;
  if (mode == AppLangMode.en) return cls.classNameEN;
  return '${cls.classNameVI} / ${cls.classNameEN}';
}

String resolveClassFocus(ClassDefinition cls, AppLangMode mode) {
  if (mode == AppLangMode.vi) return cls.focusVI;
  if (mode == AppLangMode.en) return cls.focusEN;
  return '${cls.focusVI}\n[${cls.focusEN}]';
}

String resolveClassDesc(ClassDefinition cls, AppLangMode mode) {
  if (mode == AppLangMode.vi) return cls.descriptionVI;
  if (mode == AppLangMode.en) return cls.descriptionEN;
  return '${cls.descriptionVI}\n[${cls.descriptionEN}]';
}
