import 'package:flutter/material.dart';
import '../../../../ui/theme/app_theme.dart';

class SetRowWidget extends StatelessWidget {
  final int setNumber;
  final int reps;
  final double weightKg;
  final bool isCompleted;
  final bool isEditable;
  final ValueChanged<int>? onRepsChanged;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<bool>? onCompletedChanged;
  final VoidCallback? onDelete;

  const SetRowWidget({
    super.key,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.isCompleted = false,
    this.isEditable = true,
    this.onRepsChanged,
    this.onWeightChanged,
    this.onCompletedChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final rowColor = isCompleted
        ? AppTheme.successGreen.withOpacity(0.08)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? AppTheme.successGreen.withOpacity(0.3)
              : AppTheme.cyanNeon.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Set#
          SizedBox(
            width: 32,
            child: Text(
              '$setNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCompleted ? AppTheme.successGreen : AppTheme.textDim,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Weight input
          Expanded(
            child: _buildNumberInput(
              value: weightKg,
              suffix: 'kg',
              onChanged: isEditable
                  ? (val) => onWeightChanged?.call(double.tryParse(val) ?? 0)
                  : null,
            ),
          ),
          const SizedBox(width: 8),

          // Reps input
          Expanded(
            child: _buildNumberInput(
              value: reps.toDouble(),
              suffix: 'reps',
              isInteger: true,
              onChanged: isEditable
                  ? (val) => onRepsChanged?.call(int.tryParse(val) ?? 0)
                  : null,
            ),
          ),
          const SizedBox(width: 8),

          // Completion checkbox
          if (isEditable)
            GestureDetector(
              onTap: () => onCompletedChanged?.call(!isCompleted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successGreen.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.cyanNeon.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: AppTheme.successGreen, size: 20)
                    : null,
              ),
            ),
          if (!isEditable)
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? AppTheme.successGreen : AppTheme.textDim,
              size: 20,
            ),

          // Delete button
          if (isEditable && onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Icon(Icons.close, color: AppTheme.dangerOrange, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required double value,
    required String suffix,
    bool isInteger = false,
    ValueChanged<String>? onChanged,
  }) {
    final displayValue = isInteger ? value.toInt().toString() : value.toString();

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.1)),
      ),
      child: onChanged != null
          ? TextFormField(
              initialValue: value == 0 ? '' : displayValue,
              keyboardType: isInteger
                  ? TextInputType.number
                  : const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                hintText: suffix,
                hintStyle: TextStyle(
                  color: AppTheme.textDim.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              onChanged: onChanged,
            )
          : Center(
              child: Text(
                '$displayValue $suffix',
                style: TextStyle(
                  color: isCompleted ? AppTheme.successGreen : AppTheme.textMain,
                  fontSize: 13,
                ),
              ),
            ),
    );
  }
}
