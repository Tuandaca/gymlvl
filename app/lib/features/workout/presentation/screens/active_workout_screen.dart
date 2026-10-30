import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../domain/exercise.dart';
import '../../domain/workout.dart';
import '../../domain/workout_exercise.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../workout_copy.dart';
import '../providers/exercise_providers.dart';
import '../widgets/workout_exercise_tile.dart';
import '../widgets/rest_timer_widget.dart';
import '../../../progression/presentation/widgets/level_up_overlay.dart';
import 'workout_summary_screen.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});
  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  bool _allowPop = false;
  final Set<String> _groups = {};
  String t(String key) => workoutText(ref, key);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(activeWorkoutControllerProvider.notifier).startWorkout();
      }
    });
  }

  Future<void> _addExercise() async {
    final result = await context.push<List<Exercise>>(
      '/exercise-picker?multiSelect=true',
    );
    if (result != null && mounted) {
      await ref
          .read(activeWorkoutControllerProvider.notifier)
          .addExercises(result);
    }
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _finish() async {
    FocusScope.of(context).unfocus();
    final controller = ref.read(activeWorkoutControllerProvider.notifier);
    final owner = ref.read(authStateStreamProvider).value?.session?.user.id;
    if (!controller.completionNeedsRecovery) {
      if (!await _confirm(t('finish_title'), t('finish_hint'), t('finish')) ||
          !mounted) {
        return;
      }
    }
    if (!mounted ||
        ref.read(authStateStreamProvider).value?.session?.user.id != owner) {
      return;
    }
    final currentState = ref.read(activeWorkoutControllerProvider);
    final currentWorkout = currentState.workout;
    final totalVolume = currentState.totalVolumeKg;
    final completedSets = currentState.completedSets;
    final totalSets = currentState.totalSets;

    final result = await controller.completeWorkout();
    if (result == null || !mounted) return;
    if (ref.read(authStateStreamProvider).value?.session?.user.id != owner) {
      return;
    }
    final completedWorkout = result['workout'] as Workout;
    if (completedWorkout.id != currentWorkout?.id ||
        completedWorkout.userId != currentWorkout?.userId ||
        completedWorkout.status != WorkoutStatus.completed) {
      return;
    }
    final exercises = result['exercises'] as List<WorkoutExercise>;
    HapticFeedback.mediumImpact();

    final xpResult = result['xpResult'] as Map<String, dynamic>;
    if (xpResult['leveledUp'] == true) {
      await LevelUpOverlay.show(context, xpResult);
      if (!mounted ||
          ref.read(authStateStreamProvider).value?.session?.user.id != owner) {
        return;
      }
    }

    if (currentWorkout != null && mounted) {
      await WorkoutSummaryScreen.show(
        context,
        workout: completedWorkout,
        xpResult: xpResult,
        totalVolumeKg: totalVolume,
        durationSeconds: completedWorkout.durationSeconds,
        completedSetsCount: completedSets,
        totalSetsCount: totalSets,
        exercises: exercises,
      );
    }
    if (mounted &&
        ref.read(authStateStreamProvider).value?.session?.user.id == owner) {
      _exit();
    }
  }

  void _exit() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/workout');
      }
    });
  }

  Future<void> _leave() async {
    if (ref
        .read(activeWorkoutControllerProvider.notifier)
        .completionNeedsRecovery) {
      _exit();
      return;
    }
    final state = ref.read(activeWorkoutControllerProvider);
    if (state.isCompleting || state.isLoading) return;
    if (!state.hasActiveWorkout || state.isSetupPhase) {
      _exit();
      return;
    }
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('leave_title')),
        content: Text(t('leave_hint')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'stay'),
            child: Text(t('stay')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text(t('cancel_session')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'pause'),
            child: Text(t('leave')),
          ),
        ],
      ),
    );
    if (!mounted || choice == null || choice == 'stay') return;
    final controller = ref.read(activeWorkoutControllerProvider.notifier);
    if (choice == 'cancel') {
      await controller.cancelWorkout();
    } else {
      await controller.pauseTimer();
    }
    if (mounted &&
        ref.read(activeWorkoutControllerProvider).errorMessage == null) {
      _exit();
    }
  }

  void _rest() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => DurationWheelPicker(
        onSelect: (seconds) => ref
            .read(activeWorkoutControllerProvider.notifier)
            .startRest(seconds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSetupPhase = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.isSetupPhase),
    );
    final hasActiveWorkout = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.hasActiveWorkout),
    );
    final busy = ref.watch(
      activeWorkoutControllerProvider.select(
        (s) => s.isLoading || s.isCompleting,
      ),
    );
    final errorMessage = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.errorMessage),
    );

    final controller = ref.read(activeWorkoutControllerProvider.notifier);

    final recovery = controller.completionNeedsRecovery;
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          leading: IconButton(
            onPressed: busy ? null : _leave,
            icon: const Icon(Icons.arrow_back),
          ),
          title: _WorkoutTimerTitle(isSetupPhase: isSetupPhase),
          actions: [
            if (!isSetupPhase) _WorkoutTimerPauseAction(busy: busy || recovery),
            if (!isSetupPhase)
              TextButton(
                onPressed: busy ? null : _finish,
                child: Text(t(recovery ? 'reload_receipt' : 'finish')),
              ),
          ],
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  if (busy) const LinearProgressIndicator(minHeight: 2),
                  if (errorMessage != null)
                    MaterialBanner(
                      content: Text(t(errorMessage)),
                      actions: [
                        if (recovery)
                          TextButton(
                            onPressed: busy ? null : _finish,
                            child: Text(t('reload_receipt')),
                          ),
                        if (!hasActiveWorkout)
                          TextButton(
                            onPressed: controller.startWorkout,
                            child: Text(t('retry')),
                          ),
                        if (hasActiveWorkout &&
                            (errorMessage == 'save_failed' ||
                                errorMessage == 'reload_required'))
                          TextButton(
                            onPressed: busy
                                ? null
                                : controller.checkForActiveWorkout,
                            child: Text(t('reload_saved')),
                          ),
                        if (!recovery)
                          TextButton(
                            onPressed: controller.clearError,
                            child: Text(t('dismiss')),
                          ),
                      ],
                    ),
                  if (!isSetupPhase) const _WorkoutStatsHeader(),
                  if (!isSetupPhase)
                    IgnorePointer(
                      ignoring: recovery,
                      child: const _ActiveRestTimerSection(),
                    ),
                  Expanded(
                    child: IgnorePointer(
                      ignoring: recovery,
                      child: isSetupPhase
                          ? _setup()
                          : _TrainingView(onConfirm: _confirm, onRest: _rest),
                    ),
                  ),
                  if (isSetupPhase)
                    _SetupBottomAction(
                      busy: busy,
                      onBegin: controller.beginTraining,
                    ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: !isSetupPhase && hasActiveWorkout
            ? FloatingActionButton.extended(
                onPressed: busy || recovery ? null : _addExercise,
                label: Text(t('add_exercise')),
                icon: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _setup() {
    final exercises = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.exercises),
    );
    final isLoading = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.isLoading),
    );
    final controller = ref.read(activeWorkoutControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(t('choose_groups'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core']
              .map(
                (group) => FilterChip(
                  label: Text(t(group)),
                  selected: _groups.contains(group),
                  onSelected: isLoading
                      ? null
                      : (selected) async {
                          setState(() {
                            selected
                                ? _groups.add(group)
                                : _groups.remove(group);
                          });
                          if (selected) {
                            await controller.loadPresetExercises([group]);
                          }
                        },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: isLoading ? null : _addExercise,
          icon: const Icon(Icons.add),
          label: Text(t('add_exercise')),
        ),
        const SizedBox(height: 24),
        Text(
          '${t('selected')} (${exercises.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (exercises.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t('choose_hint')),
          ),
        ...exercises.map(
          (exercise) => Card(
            child: ListTile(
              title: Text(exercise.exercise?.name ?? t('exercises')),
              subtitle: Text(
                '${exercise.sets.length} ${t('sets')} · ${t(exercise.exercise?.category ?? '')}',
              ),
              trailing: IconButton(
                tooltip: t('remove'),
                icon: const Icon(Icons.close),
                onPressed: isLoading
                    ? null
                    : () => controller.removeExercise(exercise.id),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(t('load_hint'), style: const TextStyle(color: AppTheme.textDim)),
      ],
    );
  }
}

class _SetupBottomAction extends ConsumerWidget {
  final bool busy;
  final VoidCallback onBegin;

  const _SetupBottomAction({required this.busy, required this.onBegin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesEmpty = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.exercises.isEmpty),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: busy || exercisesEmpty ? null : onBegin,
          icon: const Icon(Icons.play_arrow),
          label: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(workoutText(ref, 'begin')),
          ),
        ),
      ),
    );
  }
}

class _WorkoutTimerTitle extends ConsumerWidget {
  final bool isSetupPhase;
  const _WorkoutTimerTitle({required this.isSetupPhase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSetupPhase) {
      return Text(workoutText(ref, 'setup'));
    }
    final formatted = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.formattedElapsed),
    );
    return Text(formatted);
  }
}

class _WorkoutTimerPauseAction extends ConsumerWidget {
  final bool busy;
  const _WorkoutTimerPauseAction({required this.busy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTimerPaused = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.isTimerPaused),
    );
    final controller = ref.read(activeWorkoutControllerProvider.notifier);

    return IconButton(
      tooltip: workoutText(ref, isTimerPaused ? 'resume' : 'pause'),
      onPressed: busy
          ? null
          : () => isTimerPaused
                ? controller.resumeTimer()
                : controller.pauseTimer(),
      icon: Icon(isTimerPaused ? Icons.play_arrow : Icons.pause),
    );
  }
}

class _WorkoutStatsHeader extends ConsumerWidget {
  const _WorkoutStatsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedSets = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.completedSets),
    );
    final totalSets = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.totalSets),
    );
    final previewXP = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.previewXP),
    );
    final isTimerPaused = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.isTimerPaused),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          Text(
            '$completedSets/$totalSets ${workoutText(ref, 'sets')}',
            style: const TextStyle(color: AppTheme.cyanNeon),
          ),
          Text(
            '${workoutText(ref, 'estimated_xp')}: +$previewXP',
            style: const TextStyle(color: AppTheme.purpleNeon),
          ),
          if (isTimerPaused)
            Text(
              workoutText(ref, 'paused'),
              style: const TextStyle(color: AppTheme.warningYellow),
            ),
        ],
      ),
    );
  }
}

class _ActiveRestTimerSection extends ConsumerWidget {
  const _ActiveRestTimerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isResting = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.isResting),
    );
    if (!isResting) return const SizedBox.shrink();

    final remaining = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.restRemaining),
    );
    final total = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.restTotal),
    );
    final isPaused = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.isRestPaused),
    );
    final controller = ref.read(activeWorkoutControllerProvider.notifier);

    return RestTimerWidget(
      secondsRemaining: remaining,
      secondsTotal: total,
      isPaused: isPaused,
      onSkip: controller.skipRest,
      onPauseResume: () {
        if (isPaused) {
          controller.resumeRest();
        } else {
          controller.pauseRest();
        }
      },
      onReset: controller.resetRest,
      onAdd30: controller.addRest30,
      onSubtract15: controller.subtractRest15,
    );
  }
}

class _TrainingView extends ConsumerWidget {
  final Future<bool> Function(String, String, String) onConfirm;
  final VoidCallback onRest;

  const _TrainingView({required this.onConfirm, required this.onRest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.exercises),
    );
    final isCompleting = ref.watch(
      activeWorkoutControllerProvider.select((s) => s.isCompleting),
    );
    final controller = ref.read(activeWorkoutControllerProvider.notifier);

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: exercises.length,
      onReorder: (oldIndex, newIndex) {
        controller.reorderExercises(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return WorkoutExerciseTile(
          key: ValueKey(exercise.id),
          index: index,
          workoutExercise: exercise,
          isEditable: !isCompleting,
          onAddSet: () => controller.addSet(exercise.id),
          onRemove: () async {
            if (await onConfirm(
              workoutText(ref, 'remove_exercise'),
              workoutText(ref, 'remove_hint'),
              workoutText(ref, 'remove'),
            )) {
              await controller.removeExercise(exercise.id);
            }
          },
          onStartRest: onRest,
          onUpdateSet: (id, {reps, weightKg, durationSeconds, isCompleted}) =>
              controller.updateSet(
                exercise.id,
                id,
                reps: reps,
                weightKg: weightKg,
                durationSeconds: durationSeconds,
                isCompleted: isCompleted,
              ),
          onDeleteSet: (id) => controller.deleteSet(exercise.id, id),
        );
      },
    );
  }
}
