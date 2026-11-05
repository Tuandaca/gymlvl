import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../providers/achievement_providers.dart';
import '../widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAchievements = ref.watch(achievementsControllerProvider);

    return CandyScaffold(
      gridBackground: true,
      appBar: AppBar(
        title: Text(
          'achievements_title'.tr(ref),
          style: const TextStyle(
            fontFamily: CandyFonts.display,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: CandyColors.ink,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: CandyColors.ink, height: 2.0),
        ),
      ),
      body: RefreshIndicator(
        color: CandyColors.hotPink,
        onRefresh: () =>
            ref.read(achievementsControllerProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 920
                ? (constraints.maxWidth - 880) / 2
                : (constraints.maxWidth < 360 ? 12.0 : 16.0);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              children: [
                asyncAchievements.when(
                  data: (achievements) {
                    final earned = achievements.where((a) => a.isEarned).length;
                    final total = achievements.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary stat tiles
                        Row(
                          children: [
                            Expanded(
                              child: CandyStatTile(
                                label: translateText(
                                  ref,
                                  vi: 'Tổng huy hiệu',
                                  en: 'Total badges',
                                ),
                                value: total.toString(),
                                icon: Icons.emoji_events_rounded,
                                accentColor: CandyColors.canaryYellow,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CandyStatTile(
                                label: translateText(
                                  ref,
                                  vi: 'Đã nhận',
                                  en: 'Earned',
                                ),
                                value: earned.toString(),
                                icon: Icons.check_circle_rounded,
                                accentColor: CandyColors.mintGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: CandyColors.softLilac,
                                shape: BoxShape.circle,
                                border: CandyColors.standardBorder(width: 1.5),
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                size: 14,
                                color: CandyColors.ink,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                translateText(
                                  ref,
                                  vi: 'Huy hiệu',
                                  en: 'Achievements',
                                ),
                                style: const TextStyle(
                                  fontFamily: CandyFonts.display,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: CandyColors.ink,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (achievements.isEmpty)
                          CandyEmptyState(
                            icon: Icons.emoji_events_outlined,
                            title: translateText(
                              ref,
                              vi: 'Chưa có huy hiệu nào.',
                              en: 'No achievements yet.',
                            ),
                            message: translateText(
                              ref,
                              vi: 'Hoàn thành buổi tập đầu tiên để bắt đầu kiếm huy hiệu.',
                              en: 'Complete your first workout to start earning badges.',
                            ),
                          )
                        else
                          ...achievements.map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AchievementCard(achievement: a, ref: ref),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () =>
                      const CandySkeleton(height: 300, borderRadius: 18),
                  error: (_, _) => CandyErrorState(
                    message: 'load_failed'.tr(ref),
                    onRetry: () => ref
                        .read(achievementsControllerProvider.notifier)
                        .refresh(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
