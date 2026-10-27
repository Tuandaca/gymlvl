import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout_copy.dart';
import '../../../../ui/theme/app_theme.dart';

class RestTimerWidget extends ConsumerWidget {
  final int secondsRemaining;
  final int secondsTotal;
  final bool isPaused;
  final VoidCallback onSkip;
  final VoidCallback onPauseResume;
  final VoidCallback onReset;
  final VoidCallback onAdd30;
  final VoidCallback onSubtract15;

  const RestTimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.secondsTotal,
    this.isPaused = false,
    required this.onSkip,
    required this.onPauseResume,
    required this.onReset,
    required this.onAdd30,
    required this.onSubtract15,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = secondsTotal <= 0
        ? 0.0
        : (1 - secondsRemaining / secondsTotal).clamp(0.0, 1.0);
    final formatted =
        '${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaused
              ? AppTheme.goldWarning.withValues(alpha: 0.6)
              : AppTheme.cyanNeon.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPaused ? AppTheme.goldWarning : AppTheme.cyanNeon)
                .withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isPaused ? Icons.pause_circle_outline : Icons.timer,
                    color: isPaused ? AppTheme.goldWarning : AppTheme.cyanNeon,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    workoutText(ref, 'rest').toUpperCase(),
                    style: TextStyle(
                      color: isPaused
                          ? AppTheme.goldWarning
                          : AppTheme.cyanNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSkip();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    workoutText(ref, 'skip_rest'),
                    style: const TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Countdown Display
          Text(
            formatted,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'Space Mono',
              color: isPaused ? AppTheme.goldWarning : AppTheme.textMain,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPaused ? AppTheme.goldWarning : AppTheme.cyanNeon,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Controls: -15s, Pause/Resume, Reset, +30s
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                label: workoutText(ref, 'subtract_15s'),
                icon: Icons.remove,
                onPressed: onSubtract15,
              ),
              _buildControlButton(
                label: isPaused
                    ? workoutText(ref, 'resume_rest')
                    : workoutText(ref, 'pause_rest'),
                icon: isPaused ? Icons.play_arrow : Icons.pause,
                color: isPaused ? AppTheme.goldWarning : AppTheme.cyanNeon,
                onPressed: onPauseResume,
              ),
              _buildControlButton(
                label: workoutText(ref, 'reset_rest'),
                icon: Icons.refresh,
                onPressed: onReset,
              ),
              _buildControlButton(
                label: workoutText(ref, 'add_30s'),
                icon: Icons.add,
                onPressed: onAdd30,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    Color color = AppTheme.textDim,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: color.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestTimerQuickSelect extends ConsumerWidget {
  final ValueChanged<int> onSelect;
  const RestTimerQuickSelect({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            workoutText(ref, 'rest'),
            style: const TextStyle(
              color: AppTheme.textMain,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [30, 60, 90, 120]
                .map(
                  (seconds) => SizedBox(
                    width: 90,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppTheme.cyanNeon.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onSelect(seconds);
                      },
                      child: Text(
                        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppTheme.cyanNeon,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}
