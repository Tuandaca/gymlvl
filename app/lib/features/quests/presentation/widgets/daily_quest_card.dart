import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy_badge.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_progress_bar.dart';
import '../../../workout/presentation/providers/exercise_providers.dart';
import '../../domain/quest_instance.dart';

class DailyQuestCard extends ConsumerStatefulWidget {
  const DailyQuestCard({super.key, required this.quest});
  final QuestInstance quest;

  @override
  ConsumerState<DailyQuestCard> createState() => _DailyQuestCardState();
}

class _DailyQuestCardState extends ConsumerState<DailyQuestCard> {
  bool _starting = false;

  Future<void> _start() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final started = await ref
          .read(activeWorkoutControllerProvider.notifier)
          .startQuest(widget.quest);
      if (!mounted) return;
      if (started) {
        await context.push('/workout/active');
      } else {
        _showError();
      }
    } catch (_) {
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _showError() => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('quest_start_failed'.tr(ref))));

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;
    final complete = quest.status == 'completed';
    final active =
        quest.status == 'active' && quest.expiresAt.isAfter(DateTime.now());
    final xpReward = quest.earnedXp ?? 350;

    final String statusLabel;
    final CandyBadgeVariant badgeVariant;
    final IconData statusIcon;
    if (complete) {
      statusLabel = translateText(ref, vi: 'ĐÃ HOÀN THÀNH', en: 'COMPLETED');
      badgeVariant = CandyBadgeVariant.mint;
      statusIcon = Icons.check_circle_rounded;
    } else if (active) {
      statusLabel = translateText(ref, vi: 'ĐANG THỰC HIỆN', en: 'IN PROGRESS');
      badgeVariant = CandyBadgeVariant.yellow;
      statusIcon = Icons.fitness_center_rounded;
    } else {
      statusLabel = translateText(ref, vi: 'HẾT HẠN', en: 'EXPIRED');
      badgeVariant = CandyBadgeVariant.pink;
      statusIcon = Icons.timer_off_rounded;
    }

    final double progress = complete ? 1.0 : (active ? 0.35 : 0.0);

    return CandyCard(
      shadow: CandyCardShadow.medium,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'daily_quests'.tr(ref).toUpperCase(),
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: CandyColors.charcoal,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (complete ? 'quest_complete' : 'quest_active').tr(ref),
                      style: const TextStyle(
                        fontFamily: CandyFonts.display,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: CandyColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              CandyBadge(
                label: '+$xpReward XP',
                variant: CandyBadgeVariant.mint,
                hasShadow: true,
                fontSize: 12,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: CandyBadge(
                  label: statusLabel,
                  variant: badgeVariant,
                  icon: statusIcon,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 3.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                complete
                    ? '100%'
                    : '${quest.config.length} ${translateText(ref, vi: 'BÀI', en: 'EXERCISES')}',
                style: const TextStyle(
                  fontFamily: CandyFonts.mono,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: CandyColors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CandyProgressBar(
            progress: progress,
            height: 12,
            fillColor: complete
                ? CandyColors.mintGreen
                : CandyColors.canaryYellow,
          ),
          const SizedBox(height: 16),
          const Divider(color: CandyColors.ink, thickness: 1.5),
          const SizedBox(height: 8),
          ...quest.config.map(
            (exercise) => Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CandyColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CandyColors.ink, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CandyColors.softLilac,
                      shape: BoxShape.circle,
                      border: Border.all(color: CandyColors.ink, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: CandyColors.ink,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: const TextStyle(
                            fontFamily: CandyFonts.display,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: CandyColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${exercise.sets} × ${exercise.reps} ${'reps'.tr(ref)} · ${exercise.weightKg} kg',
                          style: const TextStyle(
                            fontFamily: CandyFonts.body,
                            color: CandyColors.charcoal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (complete)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: CandyColors.mintGreen,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (active) ...[
            CandyButton(
              label: 'start_workout'.tr(ref),
              variant: CandyButtonVariant.primary,
              icon: Icons.play_arrow_rounded,
              isLoading: _starting,
              onPressed: _start,
            ),
          ] else if (complete) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CandyColors.mintGreen, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: CandyColors.ink,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ĐÃ NHẬN +$xpReward XP',
                    style: const TextStyle(
                      fontFamily: CandyFonts.display,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: CandyColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
