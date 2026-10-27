import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../../../workout/domain/workout.dart';

/// Recent workouts feed displaying tactile Neubrutalist workout cards
/// or a CandyEmptyState if no workouts have been logged.
class RecentWorkoutsSection extends ConsumerWidget {
  final AsyncValue<List<Workout>> recentWorkoutsAsync;

  const RecentWorkoutsSection({super.key, required this.recentWorkoutsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = translateText(
      ref,
      vi: 'BUỔI TẬP GẦN ĐÂY',
      en: 'RECENT WORKOUTS',
    );
    final viewAllLabel = translateText(ref, vi: 'Xem tất cả', en: 'View all');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CandyColors.mintGreen,
                      shape: BoxShape.circle,
                      border: CandyColors.standardBorder(width: 1.5),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: CandyColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: CandyFonts.display,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: CandyColors.ink,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/workout'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewAllLabel,
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CandyColors.hotPink,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: CandyColors.hotPink,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Content
        recentWorkoutsAsync.when(
          data: (workouts) {
            if (workouts.isEmpty) {
              return CandyEmptyState(
                icon: Icons.fitness_center_rounded,
                iconBackgroundColor: CandyColors.softLilac,
                title: translateText(
                  ref,
                  vi: 'Chưa có buổi tập nào',
                  en: 'No workouts yet',
                ),
                message: translateText(
                  ref,
                  vi: 'Hãy bắt đầu buổi tập đầu tiên để nhận XP và xây dựng chuỗi ngày rèn luyện!',
                  en: 'Start your first workout to earn XP and build your training streak!',
                ),
                actionLabel: translateText(
                  ref,
                  vi: 'Bắt đầu ngay',
                  en: 'Start now',
                ),
                actionVariant: CandyButtonVariant.primary,
                onAction: () => context.go('/workout'),
              );
            }

            return Column(
              children: workouts.map((workout) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _buildWorkoutCard(context, ref, workout),
                );
              }).toList(),
            );
          },
          loading: () => Column(
            children: const [
              CandySkeleton(height: 80, borderRadius: 18),
              SizedBox(height: 10),
              CandySkeleton(height: 80, borderRadius: 18),
            ],
          ),
          error: (error, _) => CandyCard(
            backgroundColor: const Color(0xFFFFF1F0),
            borderColor: CandyColors.coral,
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: CandyColors.coral,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    translateText(
                      ref,
                      vi: 'Không thể tải lịch sử buổi tập.',
                      en: 'Could not load workout history.',
                    ),
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) {
    final completedAt =
        workout.completedAt ?? workout.createdAt ?? DateTime.now();
    final dateStr =
        '${completedAt.day.toString().padLeft(2, '0')}/${completedAt.month.toString().padLeft(2, '0')}';

    int totalSets = 0;
    double totalVolume = 0;
    for (final exercise in workout.exercises) {
      totalSets += exercise.sets.length;
      for (final s in exercise.sets) {
        if (s.isCompleted) {
          totalVolume += s.weightKg * s.reps;
        }
      }
    }

    final durationMinutes = (workout.durationSeconds / 60).round();
    final durationText = durationMinutes > 0
        ? '$durationMinutes ${translateText(ref, vi: 'phút', en: 'min')}'
        : '${workout.durationSeconds}s';

    final workoutTitle = workout.notes?.trim().isNotEmpty == true
        ? workout.notes!
        : (workout.exercises.isNotEmpty
              ? workout.exercises.first.exercise?.name ??
                    translateText(ref, vi: 'Buổi tập', en: 'Workout')
              : translateText(ref, vi: 'Buổi tập', en: 'Workout'));

    final volumeText = totalVolume >= 1000
        ? '${(totalVolume / 1000).toStringAsFixed(1)}t'
        : '${totalVolume.toStringAsFixed(0)} kg';

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(14.0),
      backgroundColor: CandyColors.card,
      onTap: () => context.push('/workout'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  workoutTitle,
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              CandyBadge(
                label: dateStr,
                variant: CandyBadgeVariant.card,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stat Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildStatChip(
                icon: Icons.repeat_rounded,
                label:
                    '$totalSets ${translateText(ref, vi: 'hiệp', en: 'sets')}',
                color: CandyColors.mintGreen,
              ),
              _buildStatChip(
                icon: Icons.timer_outlined,
                label: durationText,
                color: CandyColors.canaryYellow,
              ),
              _buildStatChip(
                icon: Icons.fitness_center_rounded,
                label: volumeText,
                color: CandyColors.softLilac,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CandyColors.ink, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: CandyColors.ink),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: CandyFonts.mono,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: CandyColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
