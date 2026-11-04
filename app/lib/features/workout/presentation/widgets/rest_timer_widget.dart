import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout_copy.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';

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

    return CandyCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      backgroundColor: isPaused
          ? CandyColors.softLilac
          : CandyColors.canaryYellow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPaused ? Icons.pause_circle_outline : Icons.timer,
                    color: CandyColors.ink,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      workoutText(ref, 'rest').toUpperCase(),
                      softWrap: true,
                      style: const TextStyle(
                        color: CandyColors.ink,
                        fontFamily: CandyFonts.body,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              CandyButton(
                label: workoutText(ref, 'skip_rest'),
                variant: CandyButtonVariant.neutral,
                size: CandyButtonSize.small,
                isFullWidth: false,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onSkip();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Countdown Display
          Semantics(
            label: '${workoutText(ref, 'rest')}: $formatted',
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: CandyFonts.mono,
                    color: CandyColors.ink,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: CandyColors.card,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPaused ? CandyColors.coral : CandyColors.hotPink,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Controls: -15s, Pause/Resume, Reset, +30s
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
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
                variant: CandyButtonVariant.lilac,
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
                variant: CandyButtonVariant.mint,
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
    CandyButtonVariant variant = CandyButtonVariant.neutral,
    required VoidCallback onPressed,
  }) {
    return CandyButton(
      label: label,
      icon: icon,
      variant: variant,
      size: CandyButtonSize.small,
      isFullWidth: false,
      onPressed: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
    );
  }
}

class DurationWheelPicker extends ConsumerWidget {
  final ValueChanged<int> onSelect;
  const DurationWheelPicker({super.key, required this.onSelect});

  static const int _maxMinutes = 10;
  static const int _secondsStep = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = ValueNotifier<int>(0);
    final seconds = ValueNotifier<int>(_secondsStep);

    int totalSeconds() => minutes.value * 60 + seconds.value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              workoutText(ref, 'set_rest_time'),
              style: const TextStyle(
                color: CandyColors.ink,
                fontFamily: CandyFonts.display,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 104,
                      height: 136,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 34,
                        diameterRatio: 1.4,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) {
                            final m = i;
                            final selected = m == minutes.value;
                            return Center(
                              child: Text(
                                '$m',
                                style: TextStyle(
                                  fontSize: selected ? 24 : 17,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.normal,
                                  color: selected
                                      ? CandyColors.ink
                                      : CandyColors.charcoal,
                                ),
                              ),
                            );
                          },
                          childCount: _maxMinutes + 1,
                        ),
                        onSelectedItemChanged: (i) => minutes.value = i,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workoutText(ref, 'minutes'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: CandyColors.charcoal,
                        fontFamily: CandyFonts.body,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 104,
                      height: 136,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 34,
                        diameterRatio: 1.4,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) {
                            final s = i * _secondsStep;
                            final selected = s == seconds.value;
                            return Center(
                              child: Text(
                                '$s',
                                style: TextStyle(
                                  fontSize: selected ? 24 : 17,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.normal,
                                  color: selected
                                      ? CandyColors.ink
                                      : CandyColors.charcoal,
                                ),
                              ),
                            );
                          },
                          childCount: 60 ~/ _secondsStep,
                        ),
                        onSelectedItemChanged: (i) =>
                            seconds.value = i * _secondsStep,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workoutText(ref, 'seconds_short'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: CandyColors.charcoal,
                        fontFamily: CandyFonts.body,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${totalSeconds() ~/ 60}:${(totalSeconds() % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: CandyFonts.mono,
                color: CandyColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: CandyButton(
                    label: workoutText(ref, 'cancel'),
                    variant: CandyButtonVariant.neutral,
                    onPressed: () => Navigator.of(context).pop(),
                    isFullWidth: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CandyButton(
                    label: workoutText(ref, 'confirm'),
                    variant: CandyButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onSelect(totalSeconds());
                    },
                    isFullWidth: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
