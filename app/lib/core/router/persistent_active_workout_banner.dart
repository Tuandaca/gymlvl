import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../localization/localization_engine.dart';
import '../theme/candy_colors.dart';
import '../../ui/candy/candy_button.dart';
import '../../features/workout/presentation/providers/exercise_providers.dart';

/// Persistent, sticky Neubrutalist banner displayed directly above the bottom
/// navigation bar across all tabs whenever an active workout session is ongoing.
class PersistentActiveWorkoutBanner extends ConsumerWidget {
  const PersistentActiveWorkoutBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutControllerProvider);
    if (!workoutState.hasActiveWorkout) {
      return const SizedBox.shrink();
    }

    final isEn = ref.watch(localizationModeProvider) == AppLangMode.en;
    final exercises = workoutState.exercises;

    String subtitle;
    if (exercises.isNotEmpty) {
      final currentExerciseName =
          exercises.first.exercise?.name ?? (isEn ? 'Exercise' : 'Bài tập');
      final setsInfo = isEn
          ? '${workoutState.completedSets}/${workoutState.totalSets} sets'
          : '${workoutState.completedSets}/${workoutState.totalSets} hiệp';
      subtitle = '$currentExerciseName · $setsInfo';
    } else {
      subtitle = isEn ? 'Session setup in progress' : 'Đang thiết lập buổi tập';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 6.0),
      decoration: BoxDecoration(
        color: CandyColors.canaryYellow,
        borderRadius: BorderRadius.circular(16.0),
        border: CandyColors.standardBorder(width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: CandyColors.ink,
            offset: Offset(4.0, 4.0),
            blurRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () => context.push('/workout/active'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // Pulsing Active Indicator
                Container(
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: CandyColors.mintGreen,
                    shape: BoxShape.circle,
                    border: CandyColors.standardBorder(width: 1.5),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 16.0,
                    color: CandyColors.ink,
                  ),
                ),
                const SizedBox(width: 10.0),

                // Live timer & exercise info
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: workoutState.isTimerPaused
                                  ? CandyColors.card
                                  : CandyColors.hotPink,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: CandyColors.ink,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              workoutState.isTimerPaused
                                  ? (isEn ? 'PAUSED' : 'TẠM DỪNG')
                                  : (isEn ? 'LIVE' : 'ĐANG TẬP'),
                              style: TextStyle(
                                fontFamily: CandyFonts.mono,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: workoutState.isTimerPaused
                                    ? CandyColors.ink
                                    : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            workoutState.formattedElapsed,
                            style: const TextStyle(
                              fontFamily: CandyFonts.mono,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w900,
                              color: CandyColors.ink,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: CandyFonts.body,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: CandyColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8.0),

                // 1-Tap Tactile Resume Button
                CandyButton(
                  label: isEn ? 'Resume' : 'Tiếp tục',
                  icon: Icons.play_arrow_rounded,
                  variant: CandyButtonVariant.primary,
                  size: CandyButtonSize.small,
                  isFullWidth: false,
                  onPressed: () => context.push('/workout/active'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
