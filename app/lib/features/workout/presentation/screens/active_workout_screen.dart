import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/theme/app_theme.dart';
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
  @override
  void initState() {
    super.initState();
    // Đảm bảo workout đã được start từ trước khi navigate vào
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(activeWorkoutControllerProvider);
      if (!state.hasActiveWorkout) {
        ref.read(activeWorkoutControllerProvider.notifier).startWorkout();
      }
    });
  }

  Future<void> _addExercise() async {
    // Navigate sang ExercisePicker (multi-select mode)
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
          ref
              .read(activeWorkoutControllerProvider.notifier)
              .startRest(seconds);
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
        title: Text(
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
            child: const Text('Xóa',
                style: TextStyle(color: AppTheme.dangerOrange)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref
          .read(activeWorkoutControllerProvider.notifier)
          .removeExercise(workoutExerciseId);
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
            child: const Text('Tiếp tục tập',
                style: TextStyle(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hoàn thành',
                style: TextStyle(color: AppTheme.successGreen)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ref
          .read(activeWorkoutControllerProvider.notifier)
          .completeWorkout();
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
            child: const Text('Tạm rời',
                style: TextStyle(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Hủy buổi tập',
                style: TextStyle(color: AppTheme.dangerOrange)),
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
        appBar: AppBar(
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
                  color: workoutState.isCompleting
                      ? AppTheme.textDim
                      : AppTheme.successGreen,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),

        body: Stack(
          children: [
            // Main content
            workoutState.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.cyanNeon))
                : workoutState.exercises.isEmpty
                    ? _buildEmptyState()
                    : _buildExerciseList(workoutState),

            // Rest timer overlay
            if (workoutState.isResting)
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
                          ref
                              .read(activeWorkoutControllerProvider.notifier)
                              .skipRest();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // FAB — Add exercise
        floatingActionButton: workoutState.hasActiveWorkout && !workoutState.isResting
            ? FloatingActionButton.extended(
                onPressed: _addExercise,
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
            'Thêm bài tập để bắt đầu!',
            style: TextStyle(
              color: AppTheme.textMain,
              fontSize: 18,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để chọn bài tập',
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildExerciseList(ActiveWorkoutState workoutState) {
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
}
