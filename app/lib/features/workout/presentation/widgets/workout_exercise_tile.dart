import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout_copy.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../domain/workout_exercise.dart';
import '../../domain/workout_mode_contract.dart';
import 'set_row_widget.dart';
import 'previous_performance_hint.dart';

class WorkoutExerciseTile extends ConsumerWidget {
  final WorkoutExercise workoutExercise;
  final int index;
  final bool isEditable;
  final bool canReorder;
  final bool isGroupLocked;
  final VoidCallback? onAddSet;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;
  final VoidCallback? onStartRest;
  final Function(
    String setId, {
    int? reps,
    double? weightKg,
    int? durationSeconds,
    bool? isCompleted,
  })?
  onUpdateSet;
  final Function(String setId)? onDeleteSet;

  const WorkoutExerciseTile({
    super.key,
    required this.workoutExercise,
    this.index = 0,
    this.isEditable = true,
    this.canReorder = true,
    this.isGroupLocked = false,
    this.onAddSet,
    this.onRemove,
    this.onReplace,
    this.onStartRest,
    this.onUpdateSet,
    this.onDeleteSet,
  });

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.reorder;
      case 'legs':
        return Icons.directions_run;
      case 'shoulders':
        return Icons.accessibility_new;
      case 'arms':
        return Icons.high_quality;
      case 'core':
        return Icons.vibration;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = workoutExercise.exercise;
    final sets = workoutExercise.sets;
    final mode = workoutExercise.mode;
    final isBodyweight = mode == WorkoutMode.bodyweight;
    final isTimeBased = mode == WorkoutMode.timed || mode == WorkoutMode.cardio;
    final modeLabel = switch (mode) {
      WorkoutMode.repsWeight => 'mode_reps_weight',
      WorkoutMode.bodyweight => 'mode_bodyweight',
      WorkoutMode.timed => 'mode_timed',
      WorkoutMode.cardio => 'mode_cardio',
      null => 'mode_unspecified',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cyanNeon.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanNeon.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Drag Handle & Remove
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.cyanNeon.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.cyanNeon.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                if (canReorder && isEditable)
                  Semantics(
                    button: true,
                    label: workoutText(ref, 'reorder'),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.drag_indicator,
                          color: AppTheme.textDim,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.cyanNeon.withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cyanNeon.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(exercise?.category),
                    color: AppTheme.cyanNeon,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise != null
                            ? exercise.localizedName()
                            : 'Exercise',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (exercise?.category != null)
                            Text(
                              workoutText(ref, exercise!.category),
                              style: TextStyle(
                                color: AppTheme.cyanNeon.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cyanNeon.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              workoutText(ref, modeLabel),
                              style: const TextStyle(
                                color: AppTheme.cyanNeon,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (workoutExercise.supersetGroupId != null)
                            Text(
                              '${workoutText(ref, 'superset')} '
                              '${(workoutExercise.supersetPosition ?? 0) + 1}',
                              style: const TextStyle(
                                color: AppTheme.purpleNeon,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (isGroupLocked)
                            Text(
                              workoutText(ref, 'superset_locked'),
                              style: const TextStyle(
                                color: AppTheme.textDim,
                                fontSize: 11,
                              ),
                            ),
                          PreviousPerformanceHint(
                            exerciseId: workoutExercise.id,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isEditable && onRemove != null)
                  IconButton(
                    tooltip: workoutText(ref, 'remove'),
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.dangerOrange,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                if (isEditable && onReplace != null && !isGroupLocked)
                  IconButton(
                    tooltip: workoutText(ref, 'replace_exercise'),
                    onPressed: onReplace,
                    icon: const Icon(
                      Icons.swap_horiz,
                      color: AppTheme.cyanNeon,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
              ],
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    workoutText(ref, 'set_label'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workoutText(ref, isBodyweight ? 'load_label' : 'kg_label'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    workoutText(ref, isTimeBased ? 'time_label' : 'reps_label'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: isEditable ? 68 : 28),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // Sets list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: sets
                  .map(
                    (set) => Column(
                      key: ValueKey(set.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SetRowWidget(
                          setNumber: set.setNumber,
                          reps: set.reps,
                          weightKg: set.weightKg,
                          durationSeconds: set.durationSeconds,
                          isBodyweight: isBodyweight,
                          isTimeBased: isTimeBased,
                          isCompleted: set.isCompleted,
                          isWarmup: set.isWarmup,
                          isEditable: isEditable,
                          onRepsChanged: isEditable
                              ? (reps) => onUpdateSet?.call(set.id, reps: reps)
                              : null,
                          onWeightChanged: isEditable
                              ? (weight) =>
                                    onUpdateSet?.call(set.id, weightKg: weight)
                              : null,
                          onDurationChanged: isEditable
                              ? (sec) => onUpdateSet?.call(
                                  set.id,
                                  durationSeconds: sec,
                                )
                              : null,
                          onCompletedChanged: isEditable
                              ? (completed) => onUpdateSet?.call(
                                  set.id,
                                  isCompleted: completed,
                                )
                              : null,
                          onDelete: isEditable
                              ? () => onDeleteSet?.call(set.id)
                              : null,
                        ),
                        if (mode == null && set.durationSeconds > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 28, bottom: 6),
                            child: Text(
                              '${workoutText(ref, 'duration')}: '
                              '${set.durationSeconds} ${workoutText(ref, 'seconds')}',
                              style: const TextStyle(
                                color: AppTheme.textDim,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),

          // Bottom actions (Add set, Rest)
          if (isEditable)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: workoutText(ref, 'add_set'),
                      icon: Icons.add,
                      color: AppTheme.cyanNeon,
                      onPressed: onAddSet,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onStartRest != null)
                    Expanded(
                      child: _buildActionButton(
                        label: workoutText(ref, 'rest'),
                        icon: Icons.timer_outlined,
                        color: AppTheme.purpleNeon,
                        onPressed: onStartRest,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: color.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
