import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/widgets/system_button.dart';
import '../../../../ui/widgets/system_panel.dart';
import '../../../../ui/widgets/system_text_field.dart';
import '../providers/onboarding_controller.dart';
import '../../domain/user_profile_draft.dart';
import '../../domain/class_definitions.dart';
import '../../../../core/localization/localization_engine.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 8) {
      if (MediaQuery.of(context).disableAnimations) {
        _pageController.jumpToPage(_currentPage + 1);
        return;
      }
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
      if (MediaQuery.of(context).disableAnimations) {
        _pageController.jumpToPage(_currentPage - 1);
        return;
      }
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingControllerProvider, (previous, next) {
      if (next is AsyncError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('request_failed'.tr(ref)),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });

    final submitState = ref.watch(onboardingControllerProvider);
    final isSubmitting = submitState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav / Status Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentPage > 0 && !isSubmitting)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.cyanNeon,
                      ),
                      onPressed: _prevPage,
                    )
                  else
                    const SizedBox(width: 48), // Placeholder to center title

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${'step'.tr(ref)} ${_currentPage + 1}/9',
                          style: const TextStyle(
                            color: AppTheme.cyanNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_currentPage + 1) / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cyanNeon,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.cyanNeon.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder
                ],
              ),
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
                  _StepPrimaryClass(),
                  _StepSecondaryClass(),
                  _StepExperience(),
                  _StepBiometrics(),
                  _StepScheduling(),
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
                    case 0:
                      canNext = true;
                      break;
                    case 1:
                      canNext = draft.environment != null;
                      break;
                    case 2:
                      canNext = draft.goals.isNotEmpty;
                      break;
                    case 3:
                      // Primary Class - Required
                      canNext = draft.primaryClassId != null;
                      break;
                    case 4:
                      // Secondary Class - Optional
                      canNext = true;
                      break;
                    case 5:
                      canNext = draft.experienceLevel != null;
                      break;
                    case 6:
                      canNext =
                          draft.age != null &&
                          draft.age! >= 13 &&
                          draft.age! <= 100 &&
                          draft.weightKg != null &&
                          draft.weightKg! >= 25 &&
                          draft.weightKg! <= 400 &&
                          draft.heightCm != null &&
                          draft.heightCm! >= 100 &&
                          draft.heightCm! <= 250 &&
                          draft.gender != null;
                      break;
                    case 7:
                      canNext =
                          draft.preferredDays.isNotEmpty &&
                          draft.weeklyGymDays + draft.weeklyHomeDays > 0 &&
                          draft.weeklyGymDays + draft.weeklyHomeDays <= 7;
                      break;
                  }

                  return SystemButton(
                    text: (_currentPage == 8 ? 'awaken' : 'continue').tr(ref),
                    isLoading: isSubmitting,
                    onPressed: canNext ? _nextPage : null,
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
// WIDGETS CÁC BƯỚC
// ========================

class _StepLanguage extends ConsumerWidget {
  const _StepLanguage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(localizationModeProvider);
    return _buildStepContainer(
      title: translateText(ref, vi: 'NGÔN NGỮ', en: 'LANGUAGE'),
      child: Column(
        children: [
          Text(
            translateText(
              ref,
              vi: 'Chọn ngôn ngữ của bạn.',
              en: 'Choose your language.',
            ),
            style: TextStyle(color: AppTheme.textDim),
          ),
          const SizedBox(height: 32),
          _NeonChoiceTile(
            label: 'Tiếng Việt',
            isSelected: mode == AppLangMode.vi,
            onTap: () => ref
                .read(localizationModeProvider.notifier)
                .setMode(AppLangMode.vi),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: 'English',
            isSelected: mode == AppLangMode.en,
            onTap: () => ref
                .read(localizationModeProvider.notifier)
                .setMode(AppLangMode.en),
          ),
        ],
      ),
    );
  }
}

class _StepEnvironment extends ConsumerWidget {
  const _StepEnvironment();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    return _buildStepContainer(
      title: translateText(ref, vi: 'KHÔNG GIAN TẬP', en: 'TRAINING SPACE'),
      child: Column(
        children: [
          Text(
            translateText(
              ref,
              vi: 'Bạn sẽ tập ở đâu?',
              en: 'Where will you train?',
            ),
            style: TextStyle(color: AppTheme.textDim),
          ),
          const SizedBox(height: 32),
          _NeonChoiceTile(
            label: translateText(
              ref,
              vi: 'Phòng gym đầy đủ thiết bị',
              en: 'Fully equipped gym',
            ),
            isSelected: draft.environment == 'gym',
            onTap: () => ref
                .read(onboardingDraftProvider.notifier)
                .set(draft.copyWith(environment: 'gym')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: translateText(
              ref,
              vi: 'Tại nhà với tạ đơn hoặc dây kháng lực',
              en: 'At home with dumbbells or bands',
            ),
            isSelected: draft.environment == 'home',
            onTap: () => ref
                .read(onboardingDraftProvider.notifier)
                .set(draft.copyWith(environment: 'home')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: translateText(
              ref,
              vi: 'Tập với trọng lượng cơ thể',
              en: 'Bodyweight training',
            ),
            isSelected: draft.environment == 'calisthenics',
            onTap: () => ref
                .read(onboardingDraftProvider.notifier)
                .set(draft.copyWith(environment: 'calisthenics')),
          ),
        ],
      ),
    );
  }
}

class _StepGoals extends ConsumerWidget {
  const _StepGoals();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);

    return _buildStepContainer(
      title: translateText(ref, vi: 'MỤC TIÊU TẬP LUYỆN', en: 'TRAINING GOALS'),
      child: Column(
        children: [
          Text(
            translateText(
              ref,
              vi: 'Chọn tối đa 3 mục tiêu.',
              en: 'Choose up to 3 goals.',
            ),
            style: TextStyle(color: AppTheme.textDim),
          ),
          const SizedBox(height: 32),
          _buildGoalChoice(
            ref,
            draft,
            translateText(ref, vi: 'Giảm mỡ', en: 'Fat loss'),
            'fat_loss',
          ),
          const SizedBox(height: 16),
          _buildGoalChoice(
            ref,
            draft,
            translateText(ref, vi: 'Tăng cơ', en: 'Build muscle'),
            'hypertrophy',
          ),
          const SizedBox(height: 16),
          _buildGoalChoice(
            ref,
            draft,
            translateText(ref, vi: 'Tăng sức mạnh', en: 'Build strength'),
            'powerlifting',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalChoice(
    WidgetRef ref,
    UserProfileDraft draft,
    String title,
    String val,
  ) {
    final isSelected = draft.goals.contains(val);
    return _NeonChoiceTile(
      label: title,
      isSelected: isSelected,
      isCheckbox: true,
      onTap: () {
        if (!isSelected) {
          if (draft.goals.length < 3) {
            ref
                .read(onboardingDraftProvider.notifier)
                .set(draft.copyWith(goals: [...draft.goals, val]));
          }
        } else {
          ref
              .read(onboardingDraftProvider.notifier)
              .set(
                draft.copyWith(
                  goals: draft.goals.where((g) => g != val).toList(),
                ),
              );
        }
      },
    );
  }
}

class _StepPrimaryClass extends ConsumerWidget {
  const _StepPrimaryClass();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final recommended = _getRecommendedClasses(draft.goals);

    return _buildStepContainer(
      title: translateText(ref, vi: 'HỆ PHÁI CHÍNH', en: 'PRIMARY CLASS'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              translateText(
                ref,
                vi: 'Chọn hướng tập luyện chính.',
                en: 'Choose your main training path.',
              ),
              style: TextStyle(color: AppTheme.textDim),
            ),
          ),
          const SizedBox(height: 16),

          ...kClassDefinitions.values.map((classDef) {
            final isSelected = draft.primaryClassId == classDef.classId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ClassTile(
                classDef: classDef,
                isSelected: isSelected,
                isSecondary: false,
                isRecommended:
                    recommended.contains(classDef.classId) && !isSelected,
                onTap: () {
                  if (isSelected) {
                    ref
                        .read(onboardingDraftProvider.notifier)
                        .update((c) => c.copyWith(primaryClassId: null));
                  } else {
                    ref
                        .read(onboardingDraftProvider.notifier)
                        .update(
                          (c) => c.copyWith(
                            primaryClassId: classDef.classId,
                            secondaryClassId:
                                null, // Reset secondary when primary changes
                          ),
                        );
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StepSecondaryClass extends ConsumerWidget {
  const _StepSecondaryClass();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);

    // Check if synergy exists
    final synergy =
        (draft.primaryClassId != null && draft.secondaryClassId != null)
        ? getSynergyForPair(draft.primaryClassId!, draft.secondaryClassId!)
        : null;

    final primaryClassId = draft.primaryClassId;
    if (primaryClassId == null) {
      return Center(
        child: Text(
          translateText(
            ref,
            vi: 'Chọn hệ phái chính trước.',
            en: 'Choose a primary class first.',
          ),
          style: TextStyle(color: AppTheme.dangerOrange),
        ),
      );
    }

    final allowedSecondary = getRecommendedSecondary(primaryClassId);

    return _buildStepContainer(
      title: translateText(ref, vi: 'HỆ PHÁI PHỤ', en: 'SECONDARY CLASS'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              translateText(
                ref,
                vi: 'Bổ sung hệ phái phụ hoặc tiếp tục để bỏ qua.',
                en: 'Choose an optional second class, or continue to skip.',
              ),
              style: TextStyle(color: AppTheme.textDim),
            ),
          ),
          const SizedBox(height: 16),

          if (synergy != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.purpleNeon.withValues(alpha: 0.3),
                      AppTheme.cyanNeon.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.purpleNeon, width: 1),
                ),
                child: Text(
                  '⚡ ${synergy.synergyName} — Perfect Synergy! +${synergy.bonusPercent}% XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ...kClassDefinitions.values.map((classDef) {
            final isPrimary = draft.primaryClassId == classDef.classId;
            final isSecondary = draft.secondaryClassId == classDef.classId;
            bool isLocked = !allowedSecondary.contains(classDef.classId);

            if (isPrimary) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Opacity(
                opacity: isLocked ? 0.4 : 1.0,
                child: _ClassTile(
                  classDef: classDef,
                  isSelected: false,
                  isSecondary: isSecondary,
                  isRecommended: false,
                  onTap: () {
                    if (isLocked) return;
                    if (isSecondary) {
                      ref
                          .read(onboardingDraftProvider.notifier)
                          .update((c) => c.copyWith(secondaryClassId: null));
                    } else {
                      ref
                          .read(onboardingDraftProvider.notifier)
                          .update(
                            (c) =>
                                c.copyWith(secondaryClassId: classDef.classId),
                          );
                    }
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Readable, keyboard-accessible class choice at narrow phone widths.
class _ClassTile extends ConsumerWidget {
  const _ClassTile({
    required this.classDef,
    required this.isSelected,
    required this.isSecondary,
    required this.isRecommended,
    required this.onTap,
  });
  final ClassDefinition classDef;
  final bool isSelected;
  final bool isSecondary;
  final bool isRecommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(classDef.colorHex);
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: isSelected || isSecondary
            ? color.withValues(alpha: 0.12)
            : null,
        side: BorderSide(
          color: isSelected || isSecondary ? color : Colors.white24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            isSelected || isSecondary
                ? Icons.check_circle
                : Icons.shield_outlined,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolveClassName(
                    classDef,
                    ref.watch(localizationModeProvider),
                  ),
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  resolveClassFocus(
                    classDef,
                    ref.watch(localizationModeProvider),
                  ),
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
                ),
                if (isSelected || isSecondary) ...[
                  const SizedBox(height: 6),
                  Text(
                    (isSelected ? 'primary_class' : 'secondary_class').tr(ref),
                    style: const TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isRecommended)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.auto_awesome, size: 18),
            ),
        ],
      ),
    );
  }
}

class _StepExperience extends ConsumerWidget {
  const _StepExperience();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    return _buildStepContainer(
      title: translateText(ref, vi: 'KINH NGHIỆM', en: 'EXPERIENCE'),
      child: Column(
        children: [
          Text(
            translateText(
              ref,
              vi: 'Bạn đã tập luyện bao lâu?',
              en: 'How experienced are you with training?',
            ),
            style: TextStyle(color: AppTheme.textDim),
          ),
          const SizedBox(height: 32),
          _NeonChoiceTile(
            label: translateText(ref, vi: 'Mới bắt đầu', en: 'Beginner'),
            isSelected: draft.experienceLevel == 'beginner',
            onTap: () => ref
                .read(onboardingDraftProvider.notifier)
                .set(draft.copyWith(experienceLevel: 'beginner')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: translateText(
              ref,
              vi: 'Đã có kinh nghiệm',
              en: 'Intermediate',
            ),
            isSelected: draft.experienceLevel == 'intermediate',
            onTap: () => ref
                .read(onboardingDraftProvider.notifier)
                .set(draft.copyWith(experienceLevel: 'intermediate')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: translateText(ref, vi: 'Nhiều kinh nghiệm', en: 'Advanced'),
            isSelected: draft.experienceLevel == 'advanced',
            onTap: () => ref
                .read(onboardingDraftProvider.notifier)
                .set(draft.copyWith(experienceLevel: 'advanced')),
          ),
        ],
      ),
    );
  }
}

class _StepBiometrics extends ConsumerStatefulWidget {
  const _StepBiometrics();
  @override
  ConsumerState<_StepBiometrics> createState() => _StepBiometricsState();
}

class _StepBiometricsState extends ConsumerState<_StepBiometrics> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    if (draft.age != null) {
      _ageController.text = draft.age.toString();
    }
    if (draft.heightCm != null) {
      _heightController.text = draft.heightCm.toString();
    }
    if (draft.weightKg != null) {
      _weightController.text = draft.weightKg.toString();
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateDraft() {
    final draft = ref.read(onboardingDraftProvider);
    ref
        .read(onboardingDraftProvider.notifier)
        .set(
          draft.copyWith(
            age: int.tryParse(_ageController.text),
            heightCm: double.tryParse(_heightController.text),
            weightKg: double.tryParse(_weightController.text),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingDraftProvider);

    return _buildStepContainer(
      title: translateText(ref, vi: 'CHỈ SỐ CƠ THỂ', en: 'BODY METRICS'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              translateText(
                ref,
                vi: 'Thông tin giúp điều chỉnh kế hoạch tập.',
                en: 'Help us tailor your training.',
              ),
              style: TextStyle(color: AppTheme.textDim),
            ),
          ),
          const SizedBox(height: 24),

          // Giới Tính
          Text(
            translateText(ref, vi: 'Giới tính', en: 'Gender'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.cyanNeon,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _genderChip(
                ref,
                draft,
                translateText(ref, vi: 'Nam', en: 'Male'),
                'male',
                Icons.male,
              ),
              const SizedBox(width: 8),
              _genderChip(
                ref,
                draft,
                translateText(ref, vi: 'Nữ', en: 'Female'),
                'female',
                Icons.female,
              ),
              const SizedBox(width: 8),
              _genderChip(
                ref,
                draft,
                translateText(ref, vi: 'Khác', en: 'Other'),
                'other',
                Icons.transgender,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            translateText(ref, vi: 'Tuổi', en: 'Age'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.cyanNeon,
            ),
          ),
          const SizedBox(height: 8),
          SystemTextField(
            controller: _ageController,
            hintText: translateText(ref, vi: 'Nhập tuổi', en: 'Enter age'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateDraft(),
          ),
          const SizedBox(height: 24),

          Text(
            translateText(ref, vi: 'Chiều cao (cm)', en: 'Height (cm)'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.cyanNeon,
            ),
          ),
          const SizedBox(height: 8),
          SystemTextField(
            controller: _heightController,
            hintText: translateText(ref, vi: 'Ví dụ: 175', en: 'e.g. 175'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _updateDraft(),
          ),
          const SizedBox(height: 24),

          Text(
            translateText(ref, vi: 'Cân nặng (kg)', en: 'Weight (kg)'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.cyanNeon,
            ),
          ),
          const SizedBox(height: 8),
          SystemTextField(
            controller: _weightController,
            hintText: translateText(ref, vi: 'Ví dụ: 70.5', en: 'e.g. 70.5'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _updateDraft(),
          ),
        ],
      ),
    );
  }

  Widget _genderChip(
    WidgetRef ref,
    UserProfileDraft draft,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = draft.gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref
              .read(onboardingDraftProvider.notifier)
              .set(draft.copyWith(gender: value));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.cyanNeon.withValues(alpha: 0.15)
                : AppTheme.panelBackground,
            border: Border.all(
              color: isSelected ? AppTheme.cyanNeon : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.cyanNeon.withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.cyanNeon : Colors.white54,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.cyanNeon : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepScheduling extends ConsumerWidget {
  const _StepScheduling();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);

    return _buildStepContainer(
      title: translateText(ref, vi: 'LỊCH TẬP', en: 'TRAINING SCHEDULE'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              translateText(
                ref,
                vi: 'Chọn lịch tập phù hợp với bạn.',
                en: 'Choose a schedule that works for you.',
              ),
              style: TextStyle(color: AppTheme.textDim),
            ),
          ),
          const SizedBox(height: 32),

          // Gym Days
          Text(
            translateText(
              ref,
              vi: 'Số buổi gym mỗi tuần',
              en: 'Gym sessions per week',
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.cyanNeon,
            ),
          ),
          Slider(
            value: draft.weeklyGymDays.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: draft.weeklyGymDays.toString(),
            activeColor: AppTheme.cyanNeon,
            onChanged: (val) {
              ref
                  .read(onboardingDraftProvider.notifier)
                  .update(
                    (c) => c.copyWith(
                      weeklyGymDays: val.toInt(),
                      weeklyHomeDays: c.weeklyHomeDays.clamp(
                        0,
                        7 - val.toInt(),
                      ),
                    ),
                  );
            },
          ),

          const SizedBox(height: 24),

          // Home Days
          Text(
            translateText(
              ref,
              vi: 'Số buổi tập ở nhà mỗi tuần',
              en: 'Home sessions per week',
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.purpleNeon,
            ),
          ),
          Slider(
            value: draft.weeklyHomeDays.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: draft.weeklyHomeDays.toString(),
            activeColor: AppTheme.purpleNeon,
            onChanged: (val) {
              ref
                  .read(onboardingDraftProvider.notifier)
                  .update(
                    (c) => c.copyWith(
                      weeklyHomeDays: val.toInt(),
                      weeklyGymDays: c.weeklyGymDays.clamp(0, 7 - val.toInt()),
                    ),
                  );
            },
          ),

          const SizedBox(height: 32),

          Text(
            translateText(
              ref,
              vi: 'Ngày tập ưu tiên',
              en: 'Preferred training days',
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.cyanNeon,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _dayChip(
                ref,
                draft,
                translateText(ref, vi: 'T2', en: 'Mon'),
                'mon',
              ),
              _dayChip(
                ref,
                draft,
                translateText(ref, vi: 'T3', en: 'Tue'),
                'tue',
              ),
              _dayChip(
                ref,
                draft,
                translateText(ref, vi: 'T4', en: 'Wed'),
                'wed',
              ),
              _dayChip(
                ref,
                draft,
                translateText(ref, vi: 'T5', en: 'Thu'),
                'thu',
              ),
              _dayChip(
                ref,
                draft,
                translateText(ref, vi: 'T6', en: 'Fri'),
                'fri',
              ),
              _dayChip(
                ref,
                draft,
                translateText(ref, vi: 'T7', en: 'Sat'),
                'sat',
              ),
              _dayChip(
                ref,
                draft,
                translateText(ref, vi: 'CN', en: 'Sun'),
                'sun',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayChip(
    WidgetRef ref,
    UserProfileDraft draft,
    String label,
    String val,
  ) {
    final isSelected = draft.preferredDays.contains(val);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.cyanNeon.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.cyanNeon,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.cyanNeon : Colors.white54,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          ref
              .read(onboardingDraftProvider.notifier)
              .update(
                (c) => c.copyWith(preferredDays: [...c.preferredDays, val]),
              );
        } else {
          ref
              .read(onboardingDraftProvider.notifier)
              .update(
                (c) => c.copyWith(
                  preferredDays: c.preferredDays
                      .where((d) => d != val)
                      .toList(),
                ),
              );
        }
      },
    );
  }
}

class _StepClassConfirmation extends ConsumerWidget {
  const _StepClassConfirmation();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final primaryClass = kClassDefinitions[draft.primaryClassId];
    final secondaryClass = draft.secondaryClassId != null
        ? kClassDefinitions[draft.secondaryClassId]
        : null;
    final synergy =
        (draft.primaryClassId != null && draft.secondaryClassId != null)
        ? getSynergyForPair(draft.primaryClassId!, draft.secondaryClassId!)
        : null;

    return _buildStepContainer(
      title: translateText(ref, vi: 'SẴN SÀNG BẮT ĐẦU', en: 'READY TO BEGIN'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            translateText(ref, vi: 'ĐÃ THIẾT LẬP HỒ SƠ', en: 'PROFILE READY'),
            style: TextStyle(color: AppTheme.textDim, letterSpacing: 2),
          ),
          const SizedBox(height: 32),

          // Primary Class
          Text(
            translateText(ref, vi: 'Hệ phái chính:', en: 'Your primary class:'),
            style: TextStyle(fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            '${primaryClass?.iconEmoji ?? '⚔️'} ${(primaryClass == null ? '' : resolveClassName(primaryClass, ref.watch(localizationModeProvider))).toUpperCase()}',
            style: TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 26,
              color: primaryClass != null
                  ? Color(primaryClass.colorHex)
                  : AppTheme.purpleNeon,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: primaryClass != null
                      ? Color(primaryClass.colorHex)
                      : AppTheme.purpleNeon,
                  blurRadius: 20,
                ),
              ],
            ),
          ),

          // Secondary Class (if selected)
          if (secondaryClass != null) ...[
            const SizedBox(height: 24),
            Text(
              translateText(ref, vi: 'Hệ phái phụ:', en: 'Secondary class:'),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                color: AppTheme.textDim,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${secondaryClass.iconEmoji} ${resolveClassName(secondaryClass, ref.watch(localizationModeProvider)).toUpperCase()}',
              style: TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 20,
                color: Color(secondaryClass.colorHex),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: Color(secondaryClass.colorHex), blurRadius: 16),
                ],
              ),
            ),
          ],

          // Synergy Badge
          if (synergy != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.purpleNeon.withValues(alpha: 0.2),
                    AppTheme.cyanNeon.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Text(
                '⚡ ${synergy.synergyName}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],

          const SizedBox(height: 48),
          Text(
            translateText(
              ref,
              vi: 'Mỗi buổi tập là một bước tiến.\nHành trình của bạn bắt đầu hôm nay.',
              en: 'Every session is a step forward.\nYour journey starts today.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.cyanNeon,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// --- DUMMY COMMON COMPONENT FOR STEPS ---
Widget _buildStepContainer({required String title, required Widget child}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SystemPanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.cyanNeon,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}

class _NeonChoiceTile extends StatelessWidget {
  const _NeonChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCheckbox = false,
  });
  final String label;
  final bool isSelected;
  final bool isCheckbox;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(18),
        backgroundColor: isSelected
            ? AppTheme.cyanNeon.withValues(alpha: 0.1)
            : null,
        side: BorderSide(
          color: isSelected ? AppTheme.cyanNeon : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMain),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isSelected
                ? Icons.check_circle
                : (isCheckbox
                      ? Icons.check_box_outline_blank
                      : Icons.radio_button_unchecked),
            color: isSelected ? AppTheme.cyanNeon : AppTheme.textDim,
          ),
        ],
      ),
    ),
  );
}

List<String> _getRecommendedClasses(List<String> goals) => {
  if (goals.contains('fat_loss')) 'A',
  if (goals.contains('hypertrophy')) 'B',
  if (goals.contains('powerlifting')) 'C',
}.toList();
