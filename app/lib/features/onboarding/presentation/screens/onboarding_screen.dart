import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/widgets/gymlvl_button.dart';
import '../providers/onboarding_controller.dart';
import '../domain/user_profile_draft.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit
      ref.read(onboardingControllerProvider.notifier).submitOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy state Controller để xem đang loading hay không
    final submitState = ref.watch(onboardingControllerProvider);
    final isSubmitting = submitState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: _currentPage > 0 && !isSubmitting
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevPage,
              )
            : null,
        title: Text('Hồ Sơ Nhập Môn (${_currentPage + 1}/6)'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh Progress
            LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
              backgroundColor: Colors.white12,
              color: Theme.of(context).primaryColor,
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Khóa vuốt tay
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: const [
                  _StepLanguage(),
                  _StepEnvironment(),
                  _StepGoals(),
                  _StepExperience(),
                  _StepBiometrics(),
                  _StepClassConfirmation(),
                ],
              ),
            ),

            // Nút điều hướng vùng dưới
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final draft = ref.watch(onboardingDraftProvider);
                  bool canNext = true;

                  switch (_currentPage) {
                    case 1:
                      canNext = draft.environment != null;
                      break;
                    case 2:
                      canNext = draft.goals.isNotEmpty;
                      break;
                    case 3:
                      canNext = draft.experienceLevel != null;
                      break;
                    case 4:
                      // Biometrics checks
                      canNext = draft.age != null && draft.weightKg != null && draft.heightCm != null && draft.gender != null;
                      break;
                  }

                  return GymlvlButton(
                    text: _currentPage == 5 ? 'HOÀN TẤT VÀ VÀO GYM' : 'TIẾP TỤC',
                    isLoading: isSubmitting,
                    onPressed: canNext ? _nextPage : () {
                      // Show snackbar yêu cầu nhập đủ nếu cần
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn hoặc nhập đủ thông tin!')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================
// WIDGETS CÁC BƯỚC (DUMMY/DRAFT)
// Cần tách ra file riêng để gọn code, ở đây tạm demo UI cấu trúc

class _StepLanguage extends ConsumerWidget {
  const _StepLanguage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Chọn Ngôn Ngữ / Select Language', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {}, child: const Text('Tiếng Việt')),
        ElevatedButton(onPressed: () {}, child: const Text('English')),
      ],
    );
  }
}

class _StepEnvironment extends ConsumerWidget {
  const _StepEnvironment();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Bạn tập ở đâu?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildChoice(ref, 'Phòng Gym (Đầy đủ máy móc)', 'gym'),
        _buildChoice(ref, 'Tại Nhà (Tạ đơn/Dây)', 'home'),
        _buildChoice(ref, 'Tập Chay (Calisthenics)', 'calisthenics'),
      ],
    );
  }

  Widget _buildChoice(WidgetRef ref, String title, String val) {
    final draft = ref.watch(onboardingDraftProvider);
    final isSelected = draft.environment == val;
    return ListTile(
      title: Text(title),
      tileColor: isSelected ? Colors.green.withOpacity(0.3) : null,
      onTap: () {
        ref.read(onboardingDraftProvider.notifier).state = draft.copyWith(environment: val);
      },
    );
  }
}

class _StepGoals extends ConsumerWidget {
  const _StepGoals();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Chọn tối đa 3 mục tiêu:', style: TextStyle(fontSize: 24)),
        _buildGoalChoice(ref, draft, 'Giảm Mỡ (Fat Loss)', 'fat_loss'),
        _buildGoalChoice(ref, draft, 'Tăng Cơ (Hypertrophy)', 'hypertrophy'),
        _buildGoalChoice(ref, draft, 'Sức Mạnh (Powerlifting)', 'powerlifting'),
      ],
    );
  }

  Widget _buildGoalChoice(WidgetRef ref, UserProfileDraft draft, String title, String val) {
    final isSelected = draft.goals.contains(val);
    return CheckboxListTile(
      title: Text(title),
      value: isSelected,
      onChanged: (checked) {
        if (checked == true) {
          if (draft.goals.length < 3) {
            ref.read(onboardingDraftProvider.notifier).state = draft.copyWith(goals: [...draft.goals, val]);
          }
        } else {
          ref.read(onboardingDraftProvider.notifier).state = draft.copyWith(
            goals: draft.goals.where((g) => g != val).toList()
          );
        }
      },
    );
  }
}

class _StepExperience extends ConsumerWidget {
  const _StepExperience();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Trình độ của bạn?', style: TextStyle(fontSize: 24)),
        _buildChoice(ref, 'Mới bắt đầu (Tân Binh)', 'beginner'),
        _buildChoice(ref, 'Đã từng tập (Tầm Trung)', 'intermediate'),
        _buildChoice(ref, 'Nâng cao (Chuyên Gia)', 'advanced'),
      ],
    );
  }

  Widget _buildChoice(WidgetRef ref, String title, String val) {
    final draft = ref.watch(onboardingDraftProvider);
    final isSelected = draft.experienceLevel == val;
    return RadioListTile(
      title: Text(title),
      value: val,
      groupValue: draft.experienceLevel,
      onChanged: (value) {
        ref.read(onboardingDraftProvider.notifier).state = draft.copyWith(experienceLevel: val.toString());
      },
    );
  }
}

class _StepBiometrics extends ConsumerWidget {
  const _StepBiometrics();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sinh trắc học', style: TextStyle(fontSize: 24)),
        Text('Tạm thời để demo. Các input Age, Weight, Height...'),
      ],
    );
  }
}

class _StepClassConfirmation extends ConsumerWidget {
  const _StepClassConfirmation();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('HỆ PHÁI CỦA BẠN:', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        Text(draft.className ?? 'Iron Warrior', style: const TextStyle(fontSize: 40, color: Colors.green, fontWeight: FontWeight.bold)),
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Kế hoạch của bạn đã được lập ra. Bấm hoàn tất để bắt đầu hành trình!', textAlign: TextAlign.center,),
        ),
      ],
    );
  }
}
