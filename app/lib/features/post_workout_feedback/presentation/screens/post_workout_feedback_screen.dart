import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../providers/post_workout_feedback_providers.dart';

class PostWorkoutFeedbackScreen extends ConsumerWidget {
  const PostWorkoutFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(postWorkoutFeedbackControllerProvider);

    return CandyScaffold(
      gridBackground: true,
      appBar: AppBar(
        title: Text(
          result == null
              ? translateText(ref, vi: 'Buổi tập', en: 'Workout')
              : result.leveledUp
              ? 'level_up'.tr(ref)
              : translateText(
                  ref,
                  vi: 'Buổi tập hoàn thành',
                  en: 'Workout complete',
                ),
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
      body: result == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 48,
                    color: CandyColors.muted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    translateText(
                      ref,
                      vi: 'Chưa có kết quả buổi tập.',
                      en: 'No workout result yet.',
                    ),
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 14,
                      color: CandyColors.charcoal,
                    ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
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
                    // XP earned + total
                    Row(
                      children: [
                        Expanded(
                          child: CandyStatTile(
                            label: 'xp_earned'.tr(ref),
                            value: result.earnedXP.toString(),
                            unit: 'XP',
                            icon: Icons.star_rounded,
                            accentColor: CandyColors.canaryYellow,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CandyStatTile(
                            label: 'total_xp'.tr(ref),
                            value: result.totalXP.toString(),
                            unit: 'XP',
                            icon: Icons.trending_up_rounded,
                            accentColor: CandyColors.hotPink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Streak
                    CandyStatTile(
                      label: translateText(
                        ref,
                        vi: 'Chuỗi hiện tại',
                        en: 'Current streak',
                      ),
                      value: result.streak.toString(),
                      unit: 'ngày',
                      icon: Icons.local_fire_department_rounded,
                      accentColor: CandyColors.coral,
                    ),
                    const SizedBox(height: 16),

                    // Level + next-level XP
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${'level'.tr(ref)} ${result.newLevel}',
                              style: const TextStyle(
                                fontFamily: CandyFonts.display,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: CandyColors.ink,
                              ),
                            ),
                            if (result.leveledUp)
                              CandyBadge(
                                label: 'level_up'.tr(ref),
                                variant: CandyBadgeVariant.pink,
                                fontSize: 11,
                                hasShadow: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CandyStatTile(
                          label: 'xp_to_next'.tr(ref),
                          value: result.nextLevelXp.toString(),
                          unit: 'XP',
                          icon: Icons.flag_rounded,
                          accentColor: CandyColors.mintGreen,
                          subtitle: result.leveledUp
                              ? translateText(
                                  ref,
                                  vi: 'Bạn vừa thăng cấp!',
                                  en: 'You just leveled up!',
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    // Class results
                    if (result.classResults.isNotEmpty) ...[
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
                              Icons.class_rounded,
                              size: 14,
                              color: CandyColors.ink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              translateText(
                                ref,
                                vi: 'Tiến độ hệ phái',
                                en: 'Class progress',
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
                      const SizedBox(height: 10),
                      ...result.classResults.map(
                        (cr) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CandyCard(
                            shadow: CandyCardShadow.small,
                            padding: const EdgeInsets.all(12),
                            backgroundColor: CandyColors.card,
                            child: Row(
                              children: [
                                Text(
                                  cr.className,
                                  style: const TextStyle(
                                    fontFamily: CandyFonts.display,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: CandyColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${cr.xpEarned} XP · Lv ${cr.newLevel}',
                                        style: const TextStyle(
                                          fontFamily: CandyFonts.mono,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: CandyColors.ink,
                                        ),
                                      ),
                                      if (cr.isGraduation)
                                        Text(
                                          translateText(
                                            ref,
                                            vi: 'Độ hoàn thành',
                                            en: 'Graduation',
                                          ),
                                          style: const TextStyle(
                                            fontFamily: CandyFonts.body,
                                            fontSize: 10,
                                            color: CandyColors.hotPink,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (cr.leveledUp)
                                  const Icon(
                                    Icons.trending_up,
                                    color: CandyColors.hotPink,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Quest completed
                    if (result.isQuest) ...[
                      CandyCard(
                        shadow: CandyCardShadow.small,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: CandyColors.canaryYellow.withValues(
                          alpha: 0.12,
                        ),
                        borderColor: CandyColors.canaryYellow,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flag_rounded,
                              color: CandyColors.ink,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    translateText(
                                      ref,
                                      vi: 'Nhiệm vụ hoàn thành',
                                      en: 'Quest completed',
                                    ),
                                    style: const TextStyle(
                                      fontFamily: CandyFonts.display,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: CandyColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    translateText(
                                      ref,
                                      vi: 'Phần thưởng nhiệm vụ đã được xác nhận.',
                                      en: 'Quest reward confirmed.',
                                    ),
                                    style: const TextStyle(
                                      fontFamily: CandyFonts.body,
                                      fontSize: 12,
                                      color: CandyColors.charcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Achievements unlocked
                    if (result.achievements.isNotEmpty) ...[
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
                              Icons.emoji_events_rounded,
                              size: 14,
                              color: CandyColors.ink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              translateText(
                                ref,
                                vi: 'Huy hiệu mở khóa',
                                en: 'Achievements unlocked',
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
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: result.achievements
                            .map(
                              (id) => CandyBadge(
                                label: id.replaceAll('_', ' ').toUpperCase(),
                                variant: CandyBadgeVariant.mint,
                                fontSize: 11,
                                hasShadow: true,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Suspicious warning
                    if (result.isSuspicious) ...[
                      CandyCard(
                        shadow: CandyCardShadow.small,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: CandyColors.coral.withValues(
                          alpha: 0.12,
                        ),
                        borderColor: CandyColors.coral,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: CandyColors.ink,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                translateText(
                                  ref,
                                  vi: 'Buổi tập được đánh giá là bất thường — XP tối thiểu đã được áp dụng.',
                                  en: 'Workout flagged as unusual — minimum XP applied.',
                                ),
                                style: const TextStyle(
                                  fontFamily: CandyFonts.body,
                                  fontSize: 12,
                                  color: CandyColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // CTA
                    SizedBox(
                      width: double.infinity,
                      child: CandyButton(
                        label: 'continue'.tr(ref),
                        variant: CandyButtonVariant.primary,
                        size: CandyButtonSize.large,
                        icon: Icons.check_circle_rounded,
                        onPressed: () {
                          ref
                              .read(
                                postWorkoutFeedbackControllerProvider.notifier,
                              )
                              .clear();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
