import 'package:flutter/material.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../domain/workout_exercise.dart';
import 'set_row_widget.dart';

class WorkoutExerciseTile extends StatelessWidget {
  final WorkoutExercise workoutExercise;
  final bool isEditable;
  final VoidCallback? onAddSet;
  final VoidCallback? onRemove;
  final VoidCallback? onStartRest;
  final Function(String setId, {int? reps, double? weightKg, bool? isCompleted})?
      onUpdateSet;
  final Function(String setId)? onDeleteSet;

  const WorkoutExerciseTile({
    super.key,
    required this.workoutExercise,
    this.isEditable = true,
    this.onAddSet,
    this.onRemove,
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
  Widget build(BuildContext context) {
    final exercise = workoutExercise.exercise;
    final sets = workoutExercise.sets;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.cyanNeon.withOpacity(0.2),
                    ),
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
                        exercise?.name ?? 'Unknown Exercise',
                        style: const TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (exercise?.category != null)
                        Text(
                          exercise!.category,
                          style: TextStyle(
                            color: AppTheme.cyanNeon.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isEditable && onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.dangerOrange, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
              ],
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const SizedBox(
                  width: 32,
                  child: Text('SET',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: isEditable ? 68 : 28),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Sets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: sets
                  .map(
                    (set) => SetRowWidget(
                      setNumber: set.setNumber,
                      reps: set.reps,
                      weightKg: set.weightKg,
                      isCompleted: set.isCompleted,
                      isEditable: isEditable,
                      onRepsChanged: isEditable
                          ? (reps) =>
                              onUpdateSet?.call(set.id, reps: reps)
                          : null,
                      onWeightChanged: isEditable
                          ? (weight) =>
                              onUpdateSet?.call(set.id, weightKg: weight)
                          : null,
                      onCompletedChanged: isEditable
                          ? (completed) =>
                              onUpdateSet?.call(set.id, isCompleted: completed)
                          : null,
                      onDelete: isEditable
                          ? () => onDeleteSet?.call(set.id)
                          : null,
                    ),
                  )
                  .toList(),
            ),
          ),

          // Bottom actions
          if (isEditable)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onAddSet,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Thêm set',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.cyanNeon,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: AppTheme.cyanNeon.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onStartRest,
                      icon: const Icon(Icons.timer_outlined, size: 16),
                      label:
                          const Text('Nghỉ', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.purpleNeon,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: AppTheme.purpleNeon.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
