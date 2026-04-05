import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/theme/app_theme.dart';
import '../../../../ui/widgets/system_button.dart';
import '../../domain/exercise.dart';
import '../providers/exercise_providers.dart';
import '../controllers/active_workout_controller.dart';
import '../widgets/workout_exercise_tile.dart';
import '../widgets/rest_timer_widget.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final Set<String> _selectedCategories = {};

  final List<Map<String, dynamic>> _muscleGroups = [
    {'name': 'Chest', 'icon': Icons.fitness_center},
    {'name': 'Back', 'icon': Icons.reorder},
    {'name': 'Legs', 'icon': Icons.directions_run},
    {'name': 'Shoulders', 'icon': Icons.accessibility_new},
    {'name': 'Arms', 'icon': Icons.high_quality},
    {'name': 'Core', 'icon': Icons.vibration},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(activeWorkoutControllerProvider);
      if (!state.hasActiveWorkout) {
        ref.read(activeWorkoutControllerProvider.notifier).startWorkout();
      }
    });
  }

  void _toggleCategory(String category) async {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });

    // Auto-load preset exercises when category changes
    final controller = ref.read(activeWorkoutControllerProvider.notifier);
    await controller.loadPresetExercises(_selectedCategories.toList());
  }

  Future<void> _addCustomExercise() async {
    final result = await context.push<List<Exercise>>('/exercise-picker?multiSelect=true');
    if (result != null && result.isNotEmpty) {
      final controller = ref.read(activeWorkoutControllerProvider.notifier);
      await controller.addExercises(result);
    }
  }

  void _showRestTimerQuickSelect() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => RestTimerQuickSelect(
        onSelect: (seconds) {
          ref.read(activeWorkoutControllerProvider.notifier).startRest(seconds);
        },
      ),
    );
  }

  Future<void> _confirmRemoveExercise(String workoutExerciseId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.cyanNeon.withOpacity(0.2)),
        ),
        title: const Text(
          'Xóa bài tập?',
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: AppTheme.dangerOrange,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "$name" khỏi buổi tập?\nTất cả sets đã log sẽ bị xóa.',
          style: const TextStyle(color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: AppTheme.dangerOrange)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(activeWorkoutControllerProvider.notifier).removeExercise(workoutExerciseId);
    }
  }

  Future<void> _completeWorkout() async {
    final state = ref.read(activeWorkoutControllerProvider);
    if (state.totalSets == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hãy log ít nhất 1 set trước khi kết thúc!'),
          backgroundColor: AppTheme.dangerOrange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.cyanNeon.withOpacity(0.2)),
        ),
        title: const Text(
          'Kết thúc buổi tập?',
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: AppTheme.cyanNeon,
            fontSize: 16,
          ),
        ),
        content: Text(
          '${state.exercises.length} bài tập · ${state.totalSets} sets · ${state.formattedElapsed}',
          style: const TextStyle(color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tiếp tục tập', style: TextStyle(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hoàn thành', style: TextStyle(color: AppTheme.successGreen)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ref.read(activeWorkoutControllerProvider.notifier).completeWorkout();
      if (result != null && mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Buổi tập hoàn thành! XP sẽ sớm được tính...'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.pop();
      }
    }
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(activeWorkoutControllerProvider);
    if (!state.hasActiveWorkout) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.cyanNeon.withOpacity(0.2)),
        ),
        title: const Text(
          'Đang tập dở!',
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: AppTheme.dangerOrange,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Buổi tập đang được lưu tự động.\nBạn có thể tiếp tục bất cứ lúc nào.',
          style: TextStyle(color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('stay'),
            child: const Text('Ở lại', style: TextStyle(color: AppTheme.cyanNeon)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('leave'),
            child: const Text('Tạm rời', style: TextStyle(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.dangerOrange)),
          ),
        ],
      ),
    );

    if (result == 'cancel') {
      await ref.read(activeWorkoutControllerProvider.notifier).cancelWorkout();
      return true;
    }
    return result == 'leave';
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: workoutState.isSetupPhase ? _buildSetupAppBar() : _buildTrainingAppBar(workoutState),
        body: Stack(
          children: [
            if (workoutState.isSetupPhase)
              _buildSetupPhase(workoutState)
            else if (workoutState.isLoading && workoutState.exercises.isEmpty)
              const Center(child: CircularProgressIndicator(color: AppTheme.cyanNeon))
            else if (workoutState.exercises.isEmpty)
              _buildEmptyState()
            else
              _buildTrainingPhase(workoutState),

            // Rest timer overlay
            if (!workoutState.isSetupPhase && workoutState.isResting)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // Prevent tap-through
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: RestTimerWidget(
                        secondsRemaining: workoutState.restSecondsRemaining,
                        secondsTotal: workoutState.restSecondsTotal,
                        onSkip: () {
                          ref.read(activeWorkoutControllerProvider.notifier).skipRest();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // FAB — Add exercise (only in training phase)
        floatingActionButton: (!workoutState.isSetupPhase && workoutState.hasActiveWorkout && !workoutState.isResting)
            ? FloatingActionButton.extended(
                onPressed: _addCustomExercise,
                backgroundColor: AppTheme.cyanNeon,
                foregroundColor: AppTheme.background,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'THÊM BÀI TẬP',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ).animate().slideY(begin: 1, end: 0, duration: 300.ms)
            : null,
      ),
    );
  }

  AppBar _buildSetupAppBar() {
    return AppBar(
      title: const Text(
        'THIẾT LẬP BUỔI TẬP',
        style: TextStyle(
          fontFamily: 'Orbitron',
          color: AppTheme.cyanNeon,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  AppBar _buildTrainingAppBar(ActiveWorkoutState workoutState) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  workoutState.formattedElapsed,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    color: AppTheme.successGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: workoutState.isCompleting ? null : _completeWorkout,
          child: Text(
            'XONG',
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: workoutState.isCompleting ? AppTheme.textDim : AppTheme.successGreen,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetupPhase(ActiveWorkoutState workoutState) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection Grid
                const Text(
                  '1. CHỌN NHÓM CƠ',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: AppTheme.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _muscleGroups.map((group) {
                    final name = group['name'] as String;
                    final isSelected = _selectedCategories.contains(name);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _toggleCategory(name);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: (MediaQuery.of(context).size.width - 44) / 3, // 3 columns
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.cyanNeon.withOpacity(0.15) : AppTheme.panelBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.cyanNeon : AppTheme.cyanNeon.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppTheme.cyanNeon.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              group['icon'] as IconData,
                              color: isSelected ? AppTheme.cyanNeon : AppTheme.textDim,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              name,
                              style: TextStyle(
                                color: isSelected ? AppTheme.textMain : AppTheme.textDim,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _addCustomExercise,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('CUSTOM (Tự chọn bài)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.purpleNeon,
                      side: BorderSide(color: AppTheme.purpleNeon.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                
                // Selected Exercises
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. BÀI TẬP ĐÃ CHỌN (${workoutState.exercises.length})',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        color: AppTheme.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (workoutState.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: AppTheme.cyanNeon, strokeWidth: 2),
                      )
                  ],
                ),
                const SizedBox(height: 16),
                
                if (workoutState.exercises.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.panelBackground.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.textDim.withOpacity(0.2), style: BorderStyle.dash),
                    ),
                    child: const Text(
                      'Hãy chọn nhóm cơ ở trên hoặc tự thêm bài tập.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textDim),
                    ),
                  ),

                ...workoutState.exercises.map((we) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.panelBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(we.exercise?.name ?? 'Unknown', style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
                    subtitle: Text(we.exercise?.category ?? '', style: TextStyle(color: AppTheme.cyanNeon.withOpacity(0.7), fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.dangerOrange),
                      onPressed: () => ref.read(activeWorkoutControllerProvider.notifier).removeExercise(we.id),
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
        ),

        // Begin Training Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.background.withOpacity(0.9),
            border: Border(top: BorderSide(color: AppTheme.cyanNeon.withOpacity(0.2))),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cyanNeon.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SystemButton(
            text: '⚔️ CHIẾN ĐẤU',
            onPressed: workoutState.exercises.isNotEmpty ? () {
              HapticFeedback.heavyImpact();
              ref.read(activeWorkoutControllerProvider.notifier).beginTraining();
            } : null,
          ),
        ).animate().slideY(begin: 1, end: 0, duration: 400.ms),
      ],
    );
  }

  Widget _buildTrainingPhase(ActiveWorkoutState workoutState) {
    final controller = ref.read(activeWorkoutControllerProvider.notifier);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: workoutState.exercises.length,
      itemBuilder: (context, index) {
        final we = workoutState.exercises[index];
        return WorkoutExerciseTile(
          workoutExercise: we,
          isEditable: true,
          onAddSet: () => controller.addSet(we.id),
          onRemove: () => _confirmRemoveExercise(
            we.id,
            we.exercise?.name ?? 'Bài tập',
          ),
          onStartRest: _showRestTimerQuickSelect,
          onUpdateSet: (setId, {reps, weightKg, isCompleted}) {
            controller.updateSet(
              we.id,
              setId,
              reps: reps,
              weightKg: weightKg,
              isCompleted: isCompleted,
            );
          },
          onDeleteSet: (setId) => controller.deleteSet(we.id, setId),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline_rounded,
                  size: 80, color: AppTheme.cyanNeon.withOpacity(0.5))
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          const SizedBox(height: 20),
          const Text(
            'Thêm một số bài tập!',
            style: TextStyle(
              color: AppTheme.textMain,
              fontSize: 18,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn nút bên dưới để chọn thêm',
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
