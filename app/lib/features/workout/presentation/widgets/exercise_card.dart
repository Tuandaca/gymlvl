import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanNeon.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppTheme.cyanNeon.withOpacity(0.1),
            highlightColor: AppTheme.cyanNeon.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon placeholder / Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.cyanNeon.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(exercise.category),
                        color: AppTheme.cyanNeon,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTag(exercise.category),
                            const SizedBox(width: 8),
                            _buildTag(exercise.equipment),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textDim,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.darkCyan.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppTheme.cyanNeon.withOpacity(0.2),
        ),
      ),
      child: Text(
        text,
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.cyanNeon,
          fontSize: 10,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
}
