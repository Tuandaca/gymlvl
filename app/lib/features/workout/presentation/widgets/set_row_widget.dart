import 'package:flutter/material.dart';
import '../../../../ui/theme/app_theme.dart';

class SetRowWidget extends StatefulWidget {
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
  State<SetRowWidget> createState() => _SetRowWidgetState();
}

class _SetRowWidgetState extends State<SetRowWidget> {
  bool _isHovered = false;
  bool _isDeleteHovered = false;
  late FocusNode _weightFocus;
  late FocusNode _repsFocus;

  @override
  void initState() {
    super.initState();
    _weightFocus = FocusNode()..addListener(() => setState(() {}));
    _repsFocus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.isCompleted;
    final rowColor = isCompleted
        ? AppTheme.successGreen.withOpacity(0.08)
        : (_isHovered ? AppTheme.cyanNeon.withOpacity(0.03) : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: rowColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? AppTheme.successGreen.withOpacity(0.4)
                : (_isHovered ? AppTheme.cyanNeon.withOpacity(0.2) : AppTheme.cyanNeon.withOpacity(0.05)),
            width: 1.5,
          ),
          boxShadow: isCompleted ? [
            BoxShadow(
              color: AppTheme.successGreen.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: Row(
          children: [
            // Set# Badge
            SizedBox(
              width: 32,
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.successGreen.withOpacity(0.2) : AppTheme.panelBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCompleted ? AppTheme.successGreen : AppTheme.textDim.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.setNumber}',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: isCompleted ? AppTheme.successGreen : AppTheme.textDim,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Weight input
            Expanded(
              child: _buildNumberInput(
                value: widget.weightKg,
                suffix: 'kg',
                focusNode: _weightFocus,
                onChanged: widget.isEditable
                    ? (val) => widget.onWeightChanged?.call(double.tryParse(val) ?? 0)
                    : null,
              ),
            ),
            const SizedBox(width: 8),

            // Reps input
            Expanded(
              child: _buildNumberInput(
                value: widget.reps.toDouble(),
                suffix: 'reps',
                isInteger: true,
                focusNode: _repsFocus,
                onChanged: widget.isEditable
                    ? (val) => widget.onRepsChanged?.call(int.tryParse(val) ?? 0)
                    : null,
              ),
            ),
            const SizedBox(width: 8),

            // Completion checkbox
            if (widget.isEditable)
              GestureDetector(
                onTap: () => widget.onCompletedChanged?.call(!isCompleted),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successGreen.withOpacity(0.2)
                        : AppTheme.background.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.successGreen
                          : AppTheme.cyanNeon.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: isCompleted ? [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ] : [],
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: AppTheme.successGreen, size: 20)
                      : null,
                ),
              ),
            if (!widget.isEditable)
              Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? AppTheme.successGreen : AppTheme.textDim,
                size: 20,
              ),

            // Delete button
            if (widget.isEditable && widget.onDelete != null) ...[
              const SizedBox(width: 4),
              MouseRegion(
                onEnter: (_) => setState(() => _isDeleteHovered = true),
                onExit: (_) => setState(() => _isDeleteHovered = false),
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: AnimatedOpacity(
                    opacity: _isHovered || _isDeleteHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: _isDeleteHovered ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isDeleteHovered ? AppTheme.dangerOrange.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: const Icon(Icons.close, color: AppTheme.dangerOrange, size: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required double value,
    required String suffix,
    required FocusNode focusNode,
    bool isInteger = false,
    ValueChanged<String>? onChanged,
  }) {
    final displayValue = isInteger ? value.toInt().toString() : (value == value.toInt() ? value.toInt().toString() : value.toString());
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 36,
      decoration: BoxDecoration(
        color: isFocused ? AppTheme.background : AppTheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isFocused ? AppTheme.purpleNeon : AppTheme.cyanNeon.withOpacity(0.1),
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: AppTheme.purpleNeon.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ] : [],
      ),
      child: onChanged != null
          ? TextFormField(
              focusNode: focusNode,
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
                  color: widget.isCompleted ? AppTheme.successGreen : AppTheme.textMain,
                  fontSize: 13,
                ),
              ),
            ),
    );
  }
}
