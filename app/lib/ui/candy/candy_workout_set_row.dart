import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

/// Workout set row item rendering set index in Space Mono,
/// weight/reps/duration values, and a tactile completion toggle button.
class CandyWorkoutSetRow extends StatelessWidget {
  final int setIndex;
  final String? previous;
  final String weightText;
  final String repsOrTimeText;
  final bool isCompleted;
  final ValueChanged<bool>? onToggleCompleted;
  final VoidCallback? onWeightTap;
  final VoidCallback? onRepsTap;
  final VoidCallback? onDelete;
  final bool isDurationBased;

  const CandyWorkoutSetRow({
    super.key,
    required this.setIndex,
    this.previous,
    required this.weightText,
    required this.repsOrTimeText,
    required this.isCompleted,
    this.onToggleCompleted,
    this.onWeightTap,
    this.onRepsTap,
    this.onDelete,
    this.isDurationBased = false,
  });

  @override
  Widget build(BuildContext context) {
    final rowBg = isCompleted ? const Color(0xFFF0FDF4) : CandyColors.card;

    return Dismissible(
      key: ValueKey('set_row_$setIndex'),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: CandyColors.coral,
          borderRadius: BorderRadius.circular(12),
          border: CandyColors.standardBorder(),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: AnimatedContainer(
        duration: CandyTimings.press,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: rowBg,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isCompleted ? CandyColors.mintGreen : CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
          boxShadow: isCompleted
              ? CandyColors.shadowPressed()
              : CandyColors.shadowSmall(),
        ),
        child: Row(
          children: [
            // Set index badge
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCompleted
                    ? CandyColors.mintGreen
                    : CandyColors.canaryYellow,
                shape: BoxShape.circle,
                border: CandyColors.standardBorder(width: 1.5),
              ),
              child: Text(
                '$setIndex',
                style: const TextStyle(
                  fontFamily: CandyFonts.mono,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: CandyColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Previous performance reference (if any)
            if (previous != null) ...[
              Expanded(
                flex: 2,
                child: Text(
                  previous!,
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 12,
                    color: CandyColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Weight input button / display
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: onWeightTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CandyColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CandyColors.ink, width: 1.2),
                  ),
                  child: Text(
                    weightText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: CandyFonts.mono,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CandyColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Reps or duration button / display
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: onRepsTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CandyColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CandyColors.ink, width: 1.2),
                  ),
                  child: Text(
                    repsOrTimeText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: CandyFonts.mono,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CandyColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Tactile Completion Checkbox (Min 48px touch target)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggleCompleted != null
                  ? () => onToggleCompleted!(!isCompleted)
                  : null,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCompleted ? CandyColors.mintGreen : CandyColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: CandyColors.standardBorder(),
                  boxShadow: isCompleted
                      ? CandyColors.shadowPressed()
                      : CandyColors.shadowSmall(),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.check_box_outline_blank,
                  size: 24,
                  color: isCompleted ? CandyColors.ink : CandyColors.charcoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
