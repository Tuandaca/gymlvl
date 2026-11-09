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
  'new_player': {'vi': 'Lần đầu đến GymLvl?', 'en': 'New to GymLvl?'},
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

  // P5: Achievements
  'achievements_title': {'vi': 'HUY HIỆU', 'en': 'ACHIEVEMENTS'},

  // P5: Unlocks
  'unlocks_title': {'vi': 'MỞ KHÓA', 'en': 'UNLOCKS'},

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

  // Account deletion
  'delete_account_title': {'vi': 'XÓA TÀI KHOẢN', 'en': 'DELETE ACCOUNT'},
  'delete_account_desc': {
    'vi':
        'Tất cả dữ liệu tập luyện, thành tựu, classes và hồ sơ của bạn sẽ bị xóa vĩnh viễn. Hành động này không thể đảo ngược.',
    'en':
        'All your workout data, achievements, classes, and profile will be permanently deleted. This action cannot be undone.',
  },
  'delete_account_confirm': {'vi': 'XÓA TÀI KHOẢN', 'en': 'DELETE ACCOUNT'},
  'account_deleted': {'vi': 'Đã xóa tài khoản.', 'en': 'Account deleted.'},
  'account_delete_deferred': {
    'vi':
        'Đã xóa dữ liệu của bạn. Xóa tài khoản xác thực đang chờ xử lý; vui lòng thử lại sau.',
    'en':
        'Your data has been deleted. Auth account cleanup is pending; please try again later.',
  },
  'account_delete_failed': {
    'vi': 'Không thể xóa tài khoản. Vui lòng thử lại sau.',
    'en': 'Could not delete account. Please try again later.',
  },
  'account_delete_sign_in_first': {
    'vi': 'Vui lòng đăng nhập trước khi xóa tài khoản.',
    'en': 'Please sign in before deleting your account.',
  },
  'account_delete_in_progress': {
    'vi': 'Đang xóa tài khoản…',
    'en': 'Deleting your account…',
  },
  'account_delete_success_desc': {
    'vi':
        'Tất cả dữ liệu của bạn đã được xóa vĩnh viễn. Tài khoản xác thực cũng đã bị xóa.',
    'en':
        'All your data has been permanently deleted. Your auth account has also been removed.',
  },
  'account_delete_deferred_title': {
    'vi': 'Xóa dữ liệu hoàn tất',
    'en': 'Data deletion complete',
  },
  'account_delete_deferred_desc': {
    'vi':
        'Dữ liệu tập luyện và hồ sơ của bạn đã bị xóa. Xóa tài khoản xác thực đang chờ xử lý; vui lòng thử lại sau để hoàn tất.',
    'en':
        'Your workout data and profile have been deleted. Auth account cleanup is pending; please try again later to finish.',
  },
  'account_delete_failed_desc': {
    'vi': 'Không thể xóa tài khoản. Vui lòng thử lại sau.',
    'en': 'Could not delete account. Please try again later.',
  },

  // Progression / RPG class bridge
  'progression_title': {'vi': 'TIẾN ĐỘ TẬP LUYỆN', 'en': 'PROGRESSION'},
  'class_progress': {'vi': 'TIẾN ĐỘ HỆ PHÁI', 'en': 'CLASS PROGRESS'},
  'xp_earned': {'vi': 'XP đã kiếm', 'en': 'XP earned'},
  'xp_to_next': {'vi': 'XP đến cấp tiếp', 'en': 'XP to next level'},
  'estimated_1rm': {'vi': 'Ước tính 1RM', 'en': 'Estimated 1RM'},
  'personal_record': {'vi': 'BẢNG KÍ NHÂN CAO', 'en': 'PERSONAL RECORD'},
  'rpe_label': {'vi': 'RPE', 'en': 'RPE'},
  'rir_label': {'vi': 'RIR', 'en': 'RIR'},
  'no_class_data': {
    'vi': 'Chưa có dữ liệu hệ phái.',
    'en': 'No class data yet.',
  },
  'no_sets_data': {
    'vi': 'Chưa có tập nào được ghi nhận.',
    'en': 'No sets recorded yet.',
  },
  'level_cap': {'vi': 'Đã đạt cấp tối đa', 'en': 'Max level reached'},
  'error_title': {'vi': 'LỖI', 'en': 'ERROR'},
  'pending': {'vi': 'ĐANG DỞ', 'en': 'PENDING'},
  'loading': {'vi': 'Đang tải...', 'en': 'Loading...'},

  // M5: Training plan / newcomer journey
  'plan_title': {'vi': 'KẾ HOẠ ĐẦU TUẦN', 'en': 'FIRST WEEK PLAN'},
  'day_1': {'vi': 'Ngày 1', 'en': 'Day 1'},
  'day_2': {'vi': 'Ngày 2', 'en': 'Day 2'},
  'day_3': {'vi': 'Ngày 3', 'en': 'Day 3'},
  'journey_no_history': {'vi': 'Chưa có hồ sơ', 'en': 'No profile yet'},
  'journey_plan_available': {'vi': 'Kế hoạch sẵn sàng', 'en': 'Plan ready'},
  'journey_plan_started': {'vi': 'Đã mở kế hoạch', 'en': 'Plan opened'},
  'journey_workout_partial': {
    'vi': 'Buổi tập đang dở',
    'en': 'Workout in progress',
  },
  'journey_workout_complete': {
    'vi': 'Đã hoàn thành buổi tập',
    'en': 'Workout complete',
  },
  'journey_progression_available': {
    'vi': 'Đã mở khóa tiến độ',
    'en': 'Progression unlocked',
  },
  'journey_returning_user': {'vi': 'Người dùng cũ', 'en': 'Returning user'},
  'plan_empty': {'vi': 'Chưa có kế hoạch tập.', 'en': 'No plan yet.'},
  'added_load': {'vi': 'Tạ thêm', 'en': 'Added load'},
  'bodyweight_note': {
    'vi': 'Trọng lượng trên một tập là tải thêm, không phải khối cơ thể.',
    'en': 'Weight on a set is added load, not body mass.',
  },
  'mode_bodyweight': {'vi': 'Tự trọng', 'en': 'Bodyweight'},
  'mode_reps_weight': {'vi': 'Trọng lượng', 'en': 'Reps x Weight'},
  'sets': {'vi': 'Số set', 'en': 'Sets'},
  'plan_open': {'vi': 'Mở kế hoạch', 'en': 'Open plan'},
  'workouts': {'vi': 'buổi tập', 'en': 'workouts'},

  // M5: Analytics
  'analytics_title': {'vi': 'PHÂN TÍCH', 'en': 'ANALYTICS'},
  'analytics_heatmap': {'vi': 'TẦN SUẤT TẬP', 'en': 'WORKOUT FREQUENCY'},
  'analytics_volume_trend': {'vi': 'XU HƯỚNG TỔNG TẠ', 'en': 'VOLUME TREND'},
  'analytics_pr_chart': {'vi': 'BẢNG KÍ NHÂN CAO', 'en': 'PERSONAL RECORDS'},
  'analytics_empty': {
    'vi': 'Chưa có dữ liệu tập luyện để hiển thị.',
    'en': 'No workout data to display yet.',
  },

  // M5: Bodyweight
  'bodyweight_title': {'vi': 'TRỌNG LƯỢNG CƠ THỂ', 'en': 'BODYWEIGHT'},
  'bodyweight_body_mass': {'vi': 'Khối cơ thể', 'en': 'Body mass'},
  'bodyweight_weigh_in': {'vi': 'Lần cân gần nhất', 'en': 'Last weigh-in'},
  'bodyweight_no_data': {
    'vi': 'Chưa có dữ liệu trọng lượng cơ thể.',
    'en': 'No bodyweight data yet.',
  },
  'bodyweight_trend': {
    'vi': 'Xu hướng trọng lượng cơ thể',
    'en': 'Bodyweight trend',
  },

  // P4: Progress / Analytics / Utility
  'exercise_progress_title': {
    'vi': 'TIẾN ĐỘ BÀI TẬP',
    'en': 'EXERCISE PROGRESS',
  },
  'exercise_progress_empty': {
    'vi': 'Chưa có lịch sử tập cho bài tập này.',
    'en': 'No workout history for this exercise yet.',
  },
  'exercise_history_sessions': {
    'vi': 'Buổi tập đã hoàn thành',
    'en': 'Completed sessions',
  },
  'working_sets': {'vi': 'Tập làm việc', 'en': 'Working sets'},
  'recent_trend': {'vi': 'Xu hướng gần đây', 'en': 'Recent trend'},
  'warmup_excluded': {
    'vi': 'Không tính tập khôi phục',
    'en': 'Warm-up sets excluded',
  },
  'measurements_title': {'vi': 'CHI SỐ CƠ THỂ', 'en': 'BODY MEASUREMENTS'},
  'add_measurement': {'vi': 'THÊM CHI SỐ', 'en': 'ADD MEASUREMENT'},
  'measurement_type': {'vi': 'Loại chỉ số', 'en': 'Measurement type'},
  'measurement_value': {'vi': 'Giá trị', 'en': 'Value'},
  'measurement_unit': {'vi': 'Đơn vị', 'en': 'Unit'},
  'measured_at': {'vi': 'Ngày đo', 'en': 'Measured at'},
  'measurement_notes': {'vi': 'Ghi chú', 'en': 'Notes'},
  'body_weight': {'vi': 'Cân nặng cơ thể', 'en': 'Body weight'},
  'body_fat_percentage': {'vi': 'Tỉ lệ mỡ cơ thể', 'en': 'Body fat percentage'},
  'chest': {'vi': 'Ngực', 'en': 'Chest'},
  'waist': {'vi': 'Eo', 'en': 'Waist'},
  'hips': {'vi': 'Mông', 'en': 'Hips'},
  'upper_arm': {'vi': 'Tay trên', 'en': 'Upper arm'},
  'thigh': {'vi': 'Đùi', 'en': 'Thigh'},
  'unit_kg': {'vi': 'kg', 'en': 'kg'},
  'unit_cm': {'vi': 'cm', 'en': 'cm'},
  'unit_percent': {'vi': '%', 'en': '%'},
  'structural_balance_title': {
    'vi': 'CÂN BẰNG CƠ THỂ',
    'en': 'STRUCTURAL BALANCE',
  },
  'push_pull': {'vi': 'Đẩy / Kéo', 'en': 'Push / Pull'},
  'upper_lower': {'vi': 'Thân trên / Thân dưới', 'en': 'Upper / Lower'},
  'anterior_posterior': {'vi': 'Trước / Sau', 'en': 'Anterior / Posterior'},
  'muscle_group_distribution': {
    'vi': 'Phân bố nhóm cơ',
    'en': 'Muscle group distribution',
  },
  'readiness_title': {
    'vi': 'PHỤC HỒI / SẴN SÀNG',
    'en': 'RECOVERY / READINESS',
  },
  'readiness_recently_trained': {
    'vi': 'Gần đây đã tập',
    'en': 'Recently trained',
  },
  'readiness_moderately_recovered': {
    'vi': 'Đang phục hồi',
    'en': 'Moderately recovered',
  },
  'readiness_long_since_trained': {
    'vi': 'Lâu rồi chưa tập',
    'en': 'Long time since trained',
  },
  'readiness_no_history': {
    'vi': 'Chưa có lịch sử tập.',
    'en': 'No training history yet.',
  },
  'readiness_days_since': {
    'vi': 'Ngày kể từ lần tập',
    'en': 'Days since last trained',
  },
  'frequency_title': {'vi': 'TẦN SUẤT TẬP', 'en': 'TRAINING FREQUENCY'},
  'strength_trend_title': {'vi': 'XU HƯỚNG SỨC MẠNH', 'en': 'STRENGTH TREND'},
  'one_rm_trend': {'vi': 'Xu hướng 1RM', 'en': '1RM trend'},
  'export_title': {'vi': 'XUẤT DỮ LIỆU', 'en': 'DATA EXPORT'},
  'export_csv': {'vi': 'Xuất CSV', 'en': 'Export CSV'},
  'export_backup': {
    'vi': 'Sao lưu GymLvl (JSON)',
    'en': 'GymLvl backup (JSON)',
  },
  'export_copied': {
    'vi': 'Đã sao chép vào clipboard',
    'en': 'Copied to clipboard',
  },
  'export_empty': {
    'vi': 'Chưa có dữ liệu để xuất.',
    'en': 'No data to export yet.',
  },
  'export_no_data': {'vi': 'Chưa có dữ liệu.', 'en': 'No data yet.'},

  // P4: Analytics time ranges
  'range_4_weeks': {'vi': '4 tuần', 'en': '4 weeks'},
  'range_12_weeks': {'vi': '12 tuần', 'en': '12 weeks'},
  'range_6_months': {'vi': '6 tháng', 'en': '6 months'},
  'range_1_year': {'vi': '1 năm', 'en': '1 year'},
  'range_all_time': {'vi': 'Tất cả', 'en': 'All time'},

  // P4: Structural balance
  'range_push_pull': {'vi': 'Đẩy / Kéo', 'en': 'Push / Pull'},
  'range_upper_lower': {'vi': 'Thân trên / Thân dưới', 'en': 'Upper / Lower'},
  'range_anterior_posterior': {
    'vi': 'Trước / Sau',
    'en': 'Anterior / Posterior',
  },
  'range_muscle_group': {'vi': 'Nhóm cơ chính', 'en': 'Muscle group'},

  // P6: AI Personal Trainer
  'ai_coach_title': {'vi': 'AI COACH', 'en': 'AI COACH'},
  'ai_coach_subtitle': {
    'vi': 'Gợi ý tập luyện từ AI',
    'en': 'AI training suggestions',
  },
  'ai_coach_placeholder': {
    'vi': 'Hỏi về kỹ thuật, phục hồi hoặc tiến độ...',
    'en': 'Ask about technique, recovery, or progress...',
  },
  'ai_coach_send': {'vi': 'GỬI CÂU HỎI', 'en': 'SEND QUESTION'},
  'ai_coach_sending': {'vi': 'Đang gửi...', 'en': 'Sending...'},
  'ai_coach_error_unconfigured': {
    'vi': 'AI Coach chưa được cấu hình. Bạn vẫn có thể ghi lại buổi tập.',
    'en': 'AI Coach is not configured yet. Workout tracking remains available.',
  },
  'ai_coach_error_daily_limit': {
    'vi': 'Đã dùng hết lượt hôm nay. Hãy quay lại mai.',
    'en': 'Daily limit reached. Come back tomorrow.',
  },
  'ai_coach_error_unauthorized': {
    'vi': 'Phiên đăng nhập hết hạn. Hãy đăng nhập lại.',
    'en': 'Session expired. Please sign in again.',
  },
  'ai_coach_error_unavailable': {
    'vi': 'Coach hiện chưa phản hồi. Hãy thử lại sau.',
    'en': 'Coach is unavailable. Please try again later.',
  },
  'ai_coach_disclaimer': {
    'vi':
        'Gợi ý từ AI không thay đổi dữ liệu tập luyện. Ngừng bài tập gây đau và tìm tư vấn chuyên môn khi cần.',
    'en':
        'AI suggestions do not change workout records. Stop painful activity and seek qualified guidance when needed.',
  },
  'pt_recommendation_title': {
    'vi': 'GỢI Ý TẬP LUYỆN',
    'en': 'TRAINING RECOMMENDATION',
  },
  'pt_recommendation_summary': {'vi': 'Tóm gọn', 'en': 'Summary'},
  'pt_recommendation_reasoning': {'vi': 'Lý do', 'en': 'Reasoning'},
  'pt_recommendation_warnings': {'vi': 'Cảnh báo', 'en': 'Warnings'},
  'pt_recommendation_confidence': {'vi': 'Độ tin cậy', 'en': 'Confidence'},
  'pt_recommendation_apply': {
    'vi': 'ÁP DỤNG VÀO KẾ HOẠCH',
    'en': 'APPLY TO ROUTINE',
  },
  'pt_recommendation_dismiss': {'vi': 'BỎ QUA', 'en': 'DISMISS'},
  'pt_recovery_title': {
    'vi': 'PHỤC HỒI / SẴN SÀNG',
    'en': 'RECOVERY / READINESS',
  },
  'pt_recovery_recently_trained': {
    'vi': 'Gần đây đã tập',
    'en': 'Recently trained',
  },
  'pt_recovery_moderately_recovered': {
    'vi': 'Đang phục hồi',
    'en': 'Moderately recovered',
  },
  'pt_recovery_long_since_trained': {
    'vi': 'Lâu rồi chưa tập',
    'en': 'Long time since trained',
  },
  'pt_recovery_no_history': {
    'vi': 'Chưa có lịch sử tập.',
    'en': 'No training history yet.',
  },
  'pt_progressive_overload_title': {
    'vi': 'TĂNG DÀN SỨC MẠNH',
    'en': 'PROGRESSIVE OVERLOAD',
  },
  'pt_progressive_overload_increase_load': {
    'vi': 'Tăng tải',
    'en': 'Increase load',
  },
  'pt_progressive_overload_increase_reps': {
    'vi': 'Tăng số lần',
    'en': 'Increase reps',
  },
  'pt_progressive_overload_maintain': {'vi': 'Giữ tải', 'en': 'Maintain load'},
  'pt_progressive_overload_reduce': {'vi': 'Giảm tải', 'en': 'Reduce load'},
  'pt_progressive_overload_deload': {
    'vi': 'Đề nghị nghỉ ngosu (deload)',
    'en': 'Deload suggestion',
  },
  'pt_in_workout_title': {
    'vi': 'COACH TRONG BUỔI TẬP',
    'en': 'IN-WORKOUT COACH',
  },
  'pt_in_workout_increase_next_set': {
    'vi': 'Tăng tập tiếp theo?',
    'en': 'Increase next set?',
  },
  'pt_in_workout_rest_time': {'vi': 'Nghỉ bao lâu?', 'en': 'How much rest?'},
  'pt_in_workout_stop_exercise': {
    'vi': 'Ngừng bài tập này?',
    'en': 'Stop this exercise?',
  },
  'pt_in_workout_after_set': {
    'vi': 'Làm gì sau tập này?',
    'en': 'What after this set?',
  },
  'pt_safety_severe_pain': {'vi': 'Đau dữ dội?', 'en': 'Severe pain?'},
  'pt_safety_medical_attention': {
    'vi': 'Tìm sự chăm sóc y tế chuyên môn.',
    'en': 'Seek qualified medical attention.',
  },
  'pt_safety_not_diagnosis': {
    'vi': 'AI không chẩn đoán y tế.',
    'en': 'AI does not provide medical diagnosis.',
  },
  'pt_fallback_unavailable': {
    'vi': 'AI Coach chưa được cấu hình.',
    'en': 'AI Coach is not configured.',
  },
  'pt_fallback_timeout': {
    'vi': 'Yêu cầu hết thời gian. Hãy thử lại sau.',
    'en': 'Request timed out. Please try again later.',
  },
  'pt_fallback_malformed': {
    'vi': 'Phản hồi từ AI không hợp lệ.',
    'en': 'Invalid response from AI.',
  },
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
