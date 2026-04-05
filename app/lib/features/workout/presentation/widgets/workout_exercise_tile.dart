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
        color: AppTheme.panelBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanNeon.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.cyanNeon.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AppTheme.cyanNeon.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.cyanNeon.withOpacity(0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cyanNeon.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(exercise?.category),
                    color: AppTheme.cyanNeon,
                    size: 20,
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
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Thêm set',
                      icon: Icons.add,
                      color: AppTheme.cyanNeon,
                      onPressed: onAddSet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Nghỉ',
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
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
