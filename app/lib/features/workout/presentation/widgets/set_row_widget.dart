import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../workout_copy.dart';

class SetRowWidget extends ConsumerStatefulWidget {
  final int setNumber;
  final int reps;
  final double weightKg;
  final int durationSeconds;
  final bool isBodyweight;
  final bool isTimeBased;
  final bool isCompleted;
  final bool isEditable;
  final ValueChanged<int>? onRepsChanged;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<int>? onDurationChanged;
  final ValueChanged<bool>? onCompletedChanged;
  final VoidCallback? onDelete;

  const SetRowWidget({
    super.key,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.durationSeconds = 0,
    this.isBodyweight = false,
    this.isTimeBased = false,
    this.isCompleted = false,
    this.isEditable = true,
    this.onRepsChanged,
    this.onWeightChanged,
    this.onDurationChanged,
    this.onCompletedChanged,
    this.onDelete,
  });

  @override
  ConsumerState<SetRowWidget> createState() => _SetRowWidgetState();
}

class _SetRowWidgetState extends ConsumerState<SetRowWidget> {
  late final TextEditingController _weight;
  late final TextEditingController _reps;
  late final TextEditingController _duration;
  final _weightFocus = FocusNode();
  final _repsFocus = FocusNode();
  final _durationFocus = FocusNode();
  bool _customWeightExpanded = false;

  String _format(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(text: _format(widget.weightKg));
    _reps = TextEditingController(text: widget.reps.toString());
    _duration = TextEditingController(text: widget.durationSeconds.toString());
    _customWeightExpanded = widget.weightKg > 0;

    _weightFocus.addListener(() {
      if (!_weightFocus.hasFocus) _weight.text = _format(widget.weightKg);
    });
    _repsFocus.addListener(() {
      if (!_repsFocus.hasFocus) _reps.text = widget.reps.toString();
    });
    _durationFocus.addListener(() {
      if (!_durationFocus.hasFocus) {
        _duration.text = widget.durationSeconds.toString();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SetRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_weightFocus.hasFocus) _weight.text = _format(widget.weightKg);
    if (!_repsFocus.hasFocus) _reps.text = widget.reps.toString();
    if (!_durationFocus.hasFocus) {
      _duration.text = widget.durationSeconds.toString();
    }
    if (widget.weightKg > 0) {
      _customWeightExpanded = true;
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _duration.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    _durationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = !MediaQuery.disableAnimationsOf(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: motion ? 150 : 0),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isCompleted
            ? AppTheme.successGreen.withValues(alpha: .08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isCompleted
              ? AppTheme.successGreen.withValues(alpha: .4)
              : AppTheme.textDim.withValues(alpha: .12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${widget.setNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 4),

          // WEIGHT COLUMN (or Bodyweight badge)
          Expanded(
            child:
                (widget.isBodyweight &&
                    !_customWeightExpanded &&
                    widget.weightKg == 0)
                ? InkWell(
                    onTap: widget.isEditable
                        ? () {
                            setState(() => _customWeightExpanded = true);
                            _weightFocus.requestFocus();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.panelBackground.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.cyanNeon.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        workoutText(ref, 'bodyweight'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cyanNeon,
                        ),
                      ),
                    ),
                  )
                : _input(
                    _weight,
                    _weightFocus,
                    workoutText(ref, 'weight'),
                    false,
                    suffix: 'kg',
                  ),
          ),
          const SizedBox(width: 6),

          // REPS OR DURATION COLUMN
          Expanded(
            child: widget.isTimeBased
                ? _input(
                    _duration,
                    _durationFocus,
                    workoutText(ref, 'seconds_label'),
                    true,
                    suffix: workoutText(ref, 'seconds'),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed <= 7200) {
                        widget.onDurationChanged?.call(parsed);
                      }
                    },
                  )
                : _input(
                    _reps,
                    _repsFocus,
                    workoutText(ref, 'repetitions'),
                    true,
                    suffix: workoutText(ref, 'reps'),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed <= 1000) {
                        widget.onRepsChanged?.call(parsed);
                      }
                    },
                  ),
          ),

          // ACTION BUTTONS
          if (widget.isEditable) ...[
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                tooltip: workoutText(ref, 'complete_set'),
                isSelected: widget.isCompleted,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  HapticFeedback.selectionClick();
                  widget.onCompletedChanged?.call(!widget.isCompleted);
                },
                icon: Icon(
                  widget.isCompleted
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: widget.isCompleted
                      ? AppTheme.successGreen
                      : AppTheme.textDim,
                  size: 24,
                ),
              ),
            ),
            if (widget.onDelete != null)
              SizedBox(
                width: 44,
                height: 48,
                child: IconButton(
                  tooltip: workoutText(ref, 'delete_set'),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onDelete?.call();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.dangerOrange,
                    size: 20,
                  ),
                ),
              ),
          ] else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                widget.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                size: 22,
                color: widget.isCompleted
                    ? AppTheme.successGreen
                    : AppTheme.textDim,
              ),
            ),
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    FocusNode focus,
    String label,
    bool integer, {
    String? suffix,
    ValueChanged<String>? onChanged,
  }) {
    if (!widget.isEditable) {
      return Text(
        '${controller.text} ${suffix ?? (integer ? workoutText(ref, 'reps') : 'kg')}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
      );
    }
    return TextField(
      controller: controller,
      focusNode: focus,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
        ),
        LengthLimitingTextInputFormatter(integer ? 4 : 7),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final value = double.tryParse(newValue.text.replaceAll(',', '.'));
          return value != null && value <= 7200 ? newValue : oldValue;
        }),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: suffix ?? (integer ? workoutText(ref, 'reps') : 'kg'),
        semanticCounterText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      ),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged(value);
          return;
        }
        if (integer) {
          final parsed = int.tryParse(value);
          if (parsed != null && parsed <= 1000) {
            widget.onRepsChanged?.call(parsed);
          }
        } else {
          final parsed = double.tryParse(value.replaceAll(',', '.'));
          if (parsed != null && parsed.isFinite && parsed <= 1000) {
            widget.onWeightChanged?.call(parsed);
          }
        }
      },
    );
  }
}
