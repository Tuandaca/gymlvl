import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../ui/widgets/system_button.dart';
import '../../../../ui/widgets/system_panel.dart';
import '../../../../ui/widgets/system_text_field.dart';
import '../providers/onboarding_controller.dart';
import '../../domain/user_profile_draft.dart';
import '../../domain/class_definitions.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 7) {
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
    ref.listen(onboardingControllerProvider, (previous, next) {
      if (next is AsyncError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${next.error}'),
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
                      icon: const Icon(Icons.arrow_back, color: AppTheme.cyanNeon),
                      onPressed: _prevPage,
                    )
                  else
                    const SizedBox(width: 48), // Placeholder to center title

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '[ STEP ${_currentPage + 1}/8 - INITIALIZING ]',
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
                            widthFactor: (_currentPage + 1) / 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cyanNeon,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.cyanNeon.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
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
                  _StepClassSelection(),
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
                    case 1:
                      canNext = draft.environment != null;
                      break;
                    case 2:
                      canNext = draft.goals.isNotEmpty;
                      break;
                    case 3:
                      // Class Selection — must have primary class
                      canNext = draft.primaryClassId != null;
                      break;
                    case 4:
                      canNext = draft.experienceLevel != null;
                      break;
                    case 5:
                      // Biometrics checks
                      canNext = draft.age != null && draft.weightKg != null && draft.heightCm != null && draft.gender != null;
                      break;
                    case 6:
                      // Scheduling checks
                      canNext = draft.preferredDays.isNotEmpty;
                      break;
                  }

                  return SystemButton(
                    text: _currentPage == 7 ? 'AWAKEN' : 'CONTINUE',
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
    return _buildStepContainer(
      title: '[ SYSTEM LANGUAGE ]',
      child: Column(
        children: [
          const Text('Select Regional Settings for the System.', style: TextStyle(color: AppTheme.textDim)),
          const SizedBox(height: 32),
          _NeonChoiceTile(label: 'Tiếng Việt', isSelected: true, onTap: () {}),
          const SizedBox(height: 16),
          _NeonChoiceTile(label: 'English', isSelected: false, onTap: () {}),
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
      title: '[ TRAINING DOMAIN ]',
      child: Column(
        children: [
          const Text('Where will you hunt?', style: TextStyle(color: AppTheme.textDim)),
          const SizedBox(height: 32),
          _NeonChoiceTile(
            label: 'Phòng Gym (Full Equipment)', 
            isSelected: draft.environment == 'gym', 
            onTap: () => ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(environment: 'gym')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: 'Tại Nhà (Dumbbells/Bands)', 
            isSelected: draft.environment == 'home', 
            onTap: () => ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(environment: 'home')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: 'Tập Chay (Calisthenics)', 
            isSelected: draft.environment == 'calisthenics', 
            onTap: () => ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(environment: 'calisthenics')),
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
      title: '[ SELECT QUEST OBJECTIVES ]',
      child: Column(
        children: [
          const Text('Select up to 3 primary goals.', style: TextStyle(color: AppTheme.textDim)),
          const SizedBox(height: 32),
          _buildGoalChoice(ref, draft, 'Giảm Mỡ (Fat Loss)', 'fat_loss'),
          const SizedBox(height: 16),
          _buildGoalChoice(ref, draft, 'Tăng Cơ (Hypertrophy)', 'hypertrophy'),
          const SizedBox(height: 16),
          _buildGoalChoice(ref, draft, 'Sức Mạnh (Powerlifting)', 'powerlifting'),
        ],
      ),
    );
  }

  Widget _buildGoalChoice(WidgetRef ref, UserProfileDraft draft, String title, String val) {
    final isSelected = draft.goals.contains(val);
    return _NeonChoiceTile(
      label: title,
      isSelected: isSelected,
      isCheckbox: true,
      onTap: () {
        if (!isSelected) {
          if (draft.goals.length < 3) {
            ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(goals: [...draft.goals, val]));
          }
        } else {
          ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(
            goals: draft.goals.where((g) => g != val).toList()
          ));
        }
      },
    );
  }
}

class _StepClassSelection extends ConsumerWidget {
  const _StepClassSelection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final recommended = draft.primaryClassId != null 
        ? getRecommendedSecondary(draft.primaryClassId!)
        : <String>[];
    final synergy = (draft.primaryClassId != null && draft.secondaryClassId != null)
        ? getSynergyForPair(draft.primaryClassId!, draft.secondaryClassId!)
        : null;

    return _buildStepContainer(
      title: '[ CLASS SELECTION ]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Choose your path. Select up to 2 Classes.', style: TextStyle(color: AppTheme.textDim))),
          const SizedBox(height: 8),
          
          // Synergy Badge
          if (synergy != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.purpleNeon.withOpacity(0.3), AppTheme.cyanNeon.withOpacity(0.3)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.purpleNeon, width: 1),
                ),
                child: Text(
                  '⚡ ${synergy.synergyName} — Perfect Synergy! +${synergy.bonusPercent}% XP',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          const Text('PRIMARY CLASS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.cyanNeon, letterSpacing: 2)),
          const SizedBox(height: 8),
          ...kClassDefinitions.values.map((classDef) {
            final isSelected = draft.primaryClassId == classDef.classId;
            final isSecondary = draft.secondaryClassId == classDef.classId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ClassTile(
                classDef: classDef,
                isSelected: isSelected,
                isSecondary: isSecondary,
                isRecommended: recommended.contains(classDef.classId) && !isSelected,
                onTap: () {
                  if (isSelected) {
                    ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(primaryClassId: null));
                  } else {
                    // If tapping on the current secondary, swap
                    if (isSecondary) {
                      ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(
                        primaryClassId: classDef.classId,
                        secondaryClassId: null,
                      ));
                    } else {
                      ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(primaryClassId: classDef.classId));
                    }
                  }
                },
                onSecondaryTap: draft.primaryClassId != null && !isSelected ? () {
                  if (isSecondary) {
                    ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(secondaryClassId: null));
                  } else {
                    ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(secondaryClassId: classDef.classId));
                  }
                } : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Single class selection tile with RPG styling
class _ClassTile extends StatelessWidget {
  final ClassDefinition classDef;
  final bool isSelected;
  final bool isSecondary;
  final bool isRecommended;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;

  const _ClassTile({
    required this.classDef,
    required this.isSelected,
    required this.isSecondary,
    required this.isRecommended,
    required this.onTap,
    this.onSecondaryTap,
  });

  Color get _classColor => Color(classDef.colorHex);

  String get _difficultyLabel {
    switch (classDef.difficulty) {
      case 'easy': return '⬛ Dễ';
      case 'medium': return '🟨 Trung Bình';
      case 'hard': return '🟧 Khó';
      case 'hardcore': return '🟥 Cực Khó';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? _classColor : (isSecondary ? AppTheme.purpleNeon : (isRecommended ? Colors.amber.withOpacity(0.5) : Colors.white12));
    final bgColor = isSelected 
        ? _classColor.withOpacity(0.15) 
        : (isSecondary ? AppTheme.purpleNeon.withOpacity(0.1) : Colors.black26);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: (isSelected || isSecondary) ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: (isSelected || isSecondary) ? [
            BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 12)
          ] : [],
        ),
        child: Row(
          children: [
            Text(classDef.iconEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        classDef.className,
                        style: TextStyle(
                          color: isSelected ? _classColor : (isSecondary ? AppTheme.purpleNeon : Colors.white),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_difficultyLabel, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(classDef.focus, style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
                ],
              ),
            ),
            // Slot Badges
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _classColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _classColor, width: 1),
                ),
                child: Text('PRIMARY', style: TextStyle(color: _classColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              )
            else if (isSecondary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.purpleNeon.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.purpleNeon, width: 1),
                ),
                child: const Text('SECONDARY', style: TextStyle(color: AppTheme.purpleNeon, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              )
            else if (isRecommended)
              const Text('✨', style: TextStyle(fontSize: 16))
            else if (onSecondaryTap != null)
              GestureDetector(
                onTap: onSecondaryTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('+2nd', style: TextStyle(color: AppTheme.textDim, fontSize: 9)),
                ),
              ),
          ],
        ),
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
      title: '[ PLAYER LEVEL ]',
      child: Column(
        children: [
          const Text('Scan your current combat experience.', style: TextStyle(color: AppTheme.textDim)),
          const SizedBox(height: 32),
          _NeonChoiceTile(
            label: 'Tân Binh (Beginner)', 
            isSelected: draft.experienceLevel == 'beginner', 
            onTap: () => ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(experienceLevel: 'beginner')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: 'Tầm Trung (Intermediate)', 
            isSelected: draft.experienceLevel == 'intermediate', 
            onTap: () => ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(experienceLevel: 'intermediate')),
          ),
          const SizedBox(height: 16),
          _NeonChoiceTile(
            label: 'Chuyên Gia (Advanced)', 
            isSelected: draft.experienceLevel == 'advanced', 
            onTap: () => ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(experienceLevel: 'advanced')),
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
    if (draft.age != null) _ageController.text = draft.age.toString();
    if (draft.heightCm != null) _heightController.text = draft.heightCm.toString();
    if (draft.weightKg != null) _weightController.text = draft.weightKg.toString();
  }

  void _updateDraft() {
    final draft = ref.read(onboardingDraftProvider);
    ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(
      age: int.tryParse(_ageController.text),
      heightCm: double.tryParse(_heightController.text),
      weightKg: double.tryParse(_weightController.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingDraftProvider);

    return _buildStepContainer(
      title: '[ SYSTEM SCAN: BODY METRICS ]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Calibrating physical stats...', style: TextStyle(color: AppTheme.textDim))),
          const SizedBox(height: 24),

          // Giới Tính
          const Text('GENDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.cyanNeon)),
          const SizedBox(height: 8),
          Row(
            children: [
              _genderChip(ref, draft, 'Nam', 'male', Icons.male),
              const SizedBox(width: 8),
              _genderChip(ref, draft, 'Nữ', 'female', Icons.female),
              const SizedBox(width: 8),
              _genderChip(ref, draft, 'Khác', 'other', Icons.transgender),
            ],
          ),
          const SizedBox(height: 24),

          const Text('AGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.cyanNeon)),
          const SizedBox(height: 8),
          SystemTextField(
            controller: _ageController,
            hintText: 'Enter age',
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateDraft(),
          ),
          const SizedBox(height: 24),

          const Text('HEIGHT (cm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.cyanNeon)),
          const SizedBox(height: 8),
          SystemTextField(
            controller: _heightController,
            hintText: 'e.g. 175',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _updateDraft(),
          ),
          const SizedBox(height: 24),

          const Text('WEIGHT (kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.cyanNeon)),
          const SizedBox(height: 8),
          SystemTextField(
            controller: _weightController,
            hintText: 'e.g. 70.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _updateDraft(),
          ),
        ],
      ),
    );
  }

  Widget _genderChip(WidgetRef ref, UserProfileDraft draft, String label, String value, IconData icon) {
    final isSelected = draft.gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(onboardingDraftProvider.notifier).set(draft.copyWith(gender: value));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cyanNeon.withOpacity(0.15) : AppTheme.panelBackground,
            border: Border.all(
              color: isSelected ? AppTheme.cyanNeon : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.cyanNeon.withOpacity(0.2),
                blurRadius: 12,
              )
            ] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppTheme.cyanNeon : Colors.white54, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(
                color: isSelected ? AppTheme.cyanNeon : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              )),
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
      title: '[ DEPLOYMENT SCHEDULE ]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('When and where will you train?', style: TextStyle(color: AppTheme.textDim))),
          const SizedBox(height: 32),
          
          // Gym Days
          const Text('GYM DAYS PER WEEK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.cyanNeon)),
          Slider(
            value: draft.weeklyGymDays.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: draft.weeklyGymDays.toString(),
            activeColor: AppTheme.cyanNeon,
            onChanged: (val) {
              ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(weeklyGymDays: val.toInt()));
            },
          ),
          
          const SizedBox(height: 24),
          
          // Home Days
          const Text('HOME DAYS PER WEEK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.purpleNeon)),
          Slider(
            value: draft.weeklyHomeDays.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: draft.weeklyHomeDays.toString(),
            activeColor: AppTheme.purpleNeon,
            onChanged: (val) {
              ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(weeklyHomeDays: val.toInt()));
            },
          ),
          
          const SizedBox(height: 32),
          
          const Text('PREFERRED DAYS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.cyanNeon)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _dayChip(ref, draft, 'Thứ 2', 'mon'),
              _dayChip(ref, draft, 'Thứ 3', 'tue'),
              _dayChip(ref, draft, 'Thứ 4', 'wed'),
              _dayChip(ref, draft, 'Thứ 5', 'thu'),
              _dayChip(ref, draft, 'Thứ 6', 'fri'),
              _dayChip(ref, draft, 'Thứ 7', 'sat'),
              _dayChip(ref, draft, 'CN', 'sun'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayChip(WidgetRef ref, UserProfileDraft draft, String label, String val) {
    final isSelected = draft.preferredDays.contains(val);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.cyanNeon.withOpacity(0.2),
      checkmarkColor: AppTheme.cyanNeon,
      labelStyle: TextStyle(color: isSelected ? AppTheme.cyanNeon : Colors.white54, fontSize: 12),
      onSelected: (selected) {
        if (selected) {
          ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(
            preferredDays: [...c.preferredDays, val]
          ));
        } else {
          ref.read(onboardingDraftProvider.notifier).update((c) => c.copyWith(
            preferredDays: c.preferredDays.where((d) => d != val).toList()
          ));
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
    final secondaryClass = draft.secondaryClassId != null ? kClassDefinitions[draft.secondaryClassId] : null;
    final synergy = (draft.primaryClassId != null && draft.secondaryClassId != null)
        ? getSynergyForPair(draft.primaryClassId!, draft.secondaryClassId!)
        : null;

    return _buildStepContainer(
      title: '[ PLAYER AWAKENING ]',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text('EVALUATION COMPLETE', style: TextStyle(color: AppTheme.textDim, letterSpacing: 2)),
          const SizedBox(height: 32),
          
          // Primary Class
          const Text('YOUR PRIMARY CLASS:', style: TextStyle(fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(
            '${primaryClass?.iconEmoji ?? '⚔️'} ${(primaryClass?.className ?? 'WARRIOR').toUpperCase()}', 
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 26, 
              color: primaryClass != null ? Color(primaryClass.colorHex) : AppTheme.purpleNeon, 
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(color: primaryClass != null ? Color(primaryClass.colorHex) : AppTheme.purpleNeon, blurRadius: 20)
              ]
            )
          ),
          
          // Secondary Class (if selected)
          if (secondaryClass != null) ...[
            const SizedBox(height: 24),
            const Text('SECONDARY CLASS:', style: TextStyle(fontSize: 12, letterSpacing: 1, color: AppTheme.textDim)),
            const SizedBox(height: 8),
            Text(
              '${secondaryClass.iconEmoji} ${secondaryClass.className.toUpperCase()}', 
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 20, 
                color: Color(secondaryClass.colorHex), 
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: Color(secondaryClass.colorHex), blurRadius: 16)
                ]
              )
            ),
          ],

          // Synergy Badge
          if (synergy != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.purpleNeon.withOpacity(0.2), AppTheme.cyanNeon.withOpacity(0.2)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Text(
                '⚡ ${synergy.synergyName}',
                style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],

          const SizedBox(height: 48),
          const Text(
            'The system is ready.\nYour journey begins now.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.cyanNeon, fontStyle: FontStyle.italic),
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
  );
}

class _NeonChoiceTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCheckbox;
  final VoidCallback onTap;

  const _NeonChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cyanNeon.withOpacity(0.1) : Colors.black26,
          border: Border.all(
            color: isSelected ? AppTheme.cyanNeon : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.1), blurRadius: 8)
          ] : [],
        ),
        child: Row(
          children: [
            if (isCheckbox) ...[
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? AppTheme.cyanNeon : Colors.white38,
              ),
              const SizedBox(width: 16),
            ] else ...[
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.cyanNeon : Colors.white38,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
