import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quests/domain/quest_instance.dart';
import '../../../quests/presentation/providers/quest_providers.dart';
import '../../../progression/presentation/providers/player_progression_view_provider.dart';
import '../../../progression/domain/player_progression.dart';
import '../../../achievements/domain/achievement.dart';
import '../../../workout/presentation/controllers/workout_history_controller.dart';
import '../../../workout/presentation/providers/exercise_providers.dart';
import '../providers/class_providers.dart';
import '../providers/stats_providers.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/hero_xp_card.dart';
import '../widgets/kpi_tiles_grid.dart';
import '../widgets/recent_workouts_section.dart';
import '../widgets/stats_charts.dart';
import '../widgets/weekly_activity_grid.dart';

/// Overhauled Dashboard Screen implementing the complete Candy Neubrutalism visual system.
/// Features tactile typography, 0 RenderFlex layout overflows (320px to 1440px),
/// 4 KPI tiles, hero XP progression, weekly activity grid, daily quests preview,
/// recent workouts feed, and tactile CTAs.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _startingQuest = false;

  Future<void> _startQuest(QuestInstance quest) async {
    if (_startingQuest) return;
    setState(() => _startingQuest = true);
    try {
      final started = await ref
          .read(activeWorkoutControllerProvider.notifier)
          .startQuest(quest);
      if (!mounted) return;
      if (started) {
        await context.push('/workout/active');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('quest_start_failed'.tr(ref))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('quest_start_failed'.tr(ref))));
      }
    } finally {
      if (mounted) setState(() => _startingQuest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final classesAsync = ref.watch(userClassesProvider);
    final questAsync = ref.watch(activeQuestControllerProvider);
    final statsAsync = ref.watch(dashboardStatsControllerProvider);
    final recentWorkoutsAsync = ref.watch(recentWorkoutsProvider);
    final progressionAsync = ref.watch(playerProgressionViewProvider);

    return CandyScaffold(
      gridBackground: true,
      appBar: AppBar(
        title: Text(
          'system_hub'.tr(ref),
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
        onRefresh: () async {
          ref.invalidate(currentUserProvider);
          ref.invalidate(userClassesProvider);
          ref.invalidate(recentWorkoutsProvider);
          await Future.wait([
            ref.read(activeQuestControllerProvider.notifier).refresh(),
            ref.read(dashboardStatsControllerProvider.notifier).refresh(),
          ]);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 920
                ? (constraints.maxWidth - 880) / 2
                : (constraints.maxWidth < 360 ? 12.0 : 16.0);

            final userData = userAsync.asData?.value;
            final userClasses = classesAsync.asData?.value ?? [];
            final statsData = statsAsync.asData?.value;
            final recentWorkouts = recentWorkoutsAsync.asData?.value ?? [];

            // Calculate metrics for KPI tiles
            double totalVolume = 0;
            int totalSets = 0;
            final completedWeekdays = <int>{};

            if (statsData != null) {
              for (final pt in statsData.volumeTrend) {
                totalVolume += pt.value;
                try {
                  final dt = DateTime.parse(pt.date);
                  completedWeekdays.add(dt.weekday);
                } catch (_) {}
              }
            }

            for (final w in recentWorkouts) {
              for (final ex in w.exercises) {
                totalSets += (ex.sets as List).length;
              }
              final completed = w.completedAt ?? w.createdAt;
              if (completed != null) {
                completedWeekdays.add(completed.weekday);
              }
            }

            final currentStreak =
                (statsData?.streak?['current_streak'] as num?)?.toInt() ?? 0;
            final longestStreak =
                (statsData?.streak?['longest_streak'] as num?)?.toInt() ?? 0;
            final totalWorkouts = recentWorkouts.length;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              children: [
                // 1. Header with personalized greeting, avatar, and RPG class badges
                if (userData != null)
                  DashboardHeader(user: userData, userClasses: userClasses)
                else if (userAsync.isLoading)
                  const CandySkeleton(height: 90, borderRadius: 18)
                else
                  _buildErrorCard(
                    message: 'load_failed'.tr(ref),
                    onRetry: () => ref.invalidate(currentUserProvider),
                  ),

                const SizedBox(height: 14),

                // 2. Hero XP Progression Bar
                if (userData != null) HeroXpCard(user: userData),

                const SizedBox(height: 16),

                // 3. Tactile Primary Action CTAs
                _buildActionButtons(context, ref),

                const SizedBox(height: 20),

                // 4. 4 Tactile Neubrutalist KPI Tiles
                KpiTilesGrid(
                  totalVolume: totalVolume,
                  totalWorkouts: totalWorkouts,
                  totalSets: totalSets,
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                ),

                const SizedBox(height: 16),

                // 5. 7-Day Weekly Activity Grid
                WeeklyActivityGrid(
                  completedWeekdays: completedWeekdays,
                  activeDaysCount: completedWeekdays.length,
                ),

                const SizedBox(height: 24),

                // 6. Daily Quests Preview
                _buildSectionHeader(
                  context,
                  title: 'todays_objective'.tr(ref),
                  icon: Icons.flag_rounded,
                  accentColor: CandyColors.canaryYellow,
                ),
                const SizedBox(height: 10),
                questAsync.when(
                  data: (quest) => quest == null
                      ? _buildRestDayCard(context, ref)
                      : _buildDailyQuestCard(context, ref, quest),
                  loading: () =>
                      const CandySkeleton(height: 130, borderRadius: 18),
                  error: (_, _) => _buildErrorCard(
                    message: 'load_failed'.tr(ref),
                    onRetry: () =>
                        ref.invalidate(activeQuestControllerProvider),
                  ),
                ),

                const SizedBox(height: 24),

                // 7. Recent Workouts Feed
                RecentWorkoutsSection(recentWorkoutsAsync: recentWorkoutsAsync),

                const SizedBox(height: 24),

                // 8. Unified progression (Class, Level, XP, Streak, Quest, Unlock)
                progressionAsync.when(
                  data: (progression) =>
                      _buildProgressionSection(ref, progression),
                  loading: () =>
                      const CandySkeleton(height: 220, borderRadius: 18),
                  error: (_, _) => _buildErrorCard(
                    message: 'load_failed'.tr(ref),
                    onRetry: () =>
                        ref.invalidate(playerProgressionViewProvider),
                  ),
                ),

                const SizedBox(height: 24),

                // 9. Achievements & Streak Milestones
                _buildSectionHeader(
                  context,
                  title: 'biometric_analysis'.tr(ref),
                  icon: Icons.insights_rounded,
                  accentColor: CandyColors.softLilac,
                ),
                const SizedBox(height: 10),
                statsAsync.when(
                  data: (stats) => stats == null
                      ? _buildEmptyStatsCard(ref)
                      : Column(
                          children: [
                            _buildMilestones(
                              ref,
                              stats.achievements,
                              stats.streak,
                            ),
                            const SizedBox(height: 14),
                            if (stats.volumeTrend.isNotEmpty) ...[
                              VolumeTrendChart(trend: stats.volumeTrend),
                              const SizedBox(height: 14),
                            ],
                            if (stats.muscleSplit.isNotEmpty)
                              MuscleRadarChart(split: stats.muscleSplit),
                          ],
                        ),
                  loading: () =>
                      const CandySkeleton(height: 140, borderRadius: 18),
                  error: (_, _) => _buildErrorCard(
                    message: 'load_failed'.tr(ref),
                    onRetry: () =>
                        ref.invalidate(dashboardStatsControllerProvider),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
            border: CandyColors.standardBorder(width: 1.5),
          ),
          child: Icon(icon, size: 14, color: CandyColors.ink),
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
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        CandyButton(
          label: 'start_workout'.tr(ref),
          variant: CandyButtonVariant.primary,
          size: CandyButtonSize.large,
          icon: Icons.play_arrow_rounded,
          onPressed: () => context.go('/workout'),
        ),
        const SizedBox(height: 10),
        CandyButton(
          label: 'AI Coach',
          variant: CandyButtonVariant.secondary,
          size: CandyButtonSize.medium,
          icon: Icons.auto_awesome_rounded,
          onPressed: () => context.push('/coach'),
        ),
      ],
    );
  }

  Widget _buildDailyQuestCard(
    BuildContext context,
    WidgetRef ref,
    QuestInstance quest,
  ) {
    final complete = quest.status == 'completed';
    final active =
        quest.status == 'active' && quest.expiresAt.isAfter(DateTime.now());
    final int? earnedXp = quest.earnedXp;

    int totalSets = 0;
    for (final ex in quest.config) {
      totalSets += ex.sets;
    }

    CandyQuestStatus status;
    if (complete) {
      status = CandyQuestStatus.claimed;
    } else {
      status = CandyQuestStatus.inProgress;
    }

    final questTitle = (complete ? 'quest_complete' : 'quest_active').tr(ref);
    final questDesc = quest.config.isNotEmpty
        ? quest.config
              .map((e) => '${e.exerciseName} (${e.sets}×${e.reps})')
              .join(' · ')
        : 'quest_reward_hint'.tr(ref);

    return CandyQuestCard(
      title: questTitle,
      description: questDesc,
      currentProgress: complete ? totalSets : null,
      targetProgress: totalSets > 0 ? totalSets : 1,
      xpReward: earnedXp,
      status: status,
      icon: Icons.fitness_center_rounded,
      iconColor: CandyColors.canaryYellow,
      onStart: active ? () => _startQuest(quest) : null,
    );
  }

  Widget _buildRestDayCard(BuildContext context, WidgetRef ref) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(18),
      backgroundColor: CandyColors.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CandyColors.softLilac,
              shape: BoxShape.circle,
              border: CandyColors.standardBorder(),
            ),
            child: const Icon(
              Icons.nights_stay_rounded,
              color: CandyColors.ink,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'rest_day'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  translateText(
                    ref,
                    vi: 'Hôm nay là ngày nghỉ ngơi phục hồi thể lực!',
                    en: 'Today is an honest rest day for recovery!',
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
    );
  }

  Widget _buildMilestones(
    WidgetRef ref,
    List<Map<String, dynamic>> achievements,
    Map<String, dynamic>? streak,
  ) {
    final current = (streak?['current_streak'] as num?)?.toInt() ?? 0;
    final longest = (streak?['longest_streak'] as num?)?.toInt() ?? 0;

    final names = <String, String>{
      'first_workout': translateText(
        ref,
        vi: 'Buổi tập đầu tiên',
        en: 'First workout',
      ),
      'ten_workouts': translateText(ref, vi: '10 buổi tập', en: '10 workouts'),
      'streak_7': translateText(ref, vi: 'Chuỗi 7 ngày', en: '7-day streak'),
      'level_10': translateText(ref, vi: 'Cấp độ 10', en: 'Level 10'),
    };

    final streakSummary = translateText(
      ref,
      vi: 'Chuỗi hiện tại: $current ngày · Kỷ lục: $longest',
      en: 'Current streak: $current days · Best: $longest',
    );

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(18),
      backgroundColor: CandyColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.local_fire_department_rounded,
                  color: CandyColors.ink,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  streakSummary,
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: CandyColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'lifetime_quests'.tr(ref),
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CandyColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          if (achievements.isEmpty)
            Text(
              translateText(
                ref,
                vi: 'Hoàn thành buổi tập đầu tiên để mở huy hiệu.',
                en: 'Complete your first workout to unlock a badge.',
              ),
              style: const TextStyle(
                fontFamily: CandyFonts.body,
                color: CandyColors.muted,
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements.map((achievement) {
                final id = achievement['achievement_id']?.toString() ?? '';
                final label = names[id] ?? id;
                return CandyBadge(
                  label: label,
                  icon: Icons.verified_rounded,
                  variant: CandyBadgeVariant.mint,
                  fontSize: 12,
                  hasShadow: true,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressionSection(
    WidgetRef ref,
    PlayerProgression? progression,
  ) {
    if (progression == null) {
      return CandyCard(
        shadow: CandyCardShadow.small,
        padding: const EdgeInsets.all(18),
        backgroundColor: CandyColors.card,
        child: Center(
          child: Text(
            'no_class_data'.tr(ref),
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              color: CandyColors.muted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final primary = progression.classes.isNotEmpty
        ? progression.classes.firstWhere(
            (c) => c.slot == 'primary',
            orElse: () => progression.classes.first,
          )
        : null;
    final recentAchievement = progression.achievements.isNotEmpty
        ? progression.achievements.last
        : null;
    final nextUnlock = progression.nextUnlock;

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(18),
      backgroundColor: CandyColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.trending_up_rounded,
                  size: 14,
                  color: CandyColors.ink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  translateText(
                    ref,
                    vi: 'Tiến độ người chơi',
                    en: 'Player progression',
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
          const SizedBox(height: 14),

          // Class + level row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary != null
                      ? CandyColors.mintGreen.withValues(alpha: 0.15)
                      : CandyColors.muted.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: CandyColors.standardBorder(),
                  boxShadow: CandyColors.shadowPressed(),
                ),
                child: Center(
                  child: Text(
                    primary != null ? '${primary.level}' : '—',
                    style: const TextStyle(
                      fontFamily: CandyFonts.mono,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: CandyColors.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      primary != null
                          ? '${primary.className} · ${translateText(ref, vi: 'Hệ phái', en: 'Class')}'
                          : translateText(
                              ref,
                              vi: 'Chưa chọn hệ phái',
                              en: 'No class selected',
                            ),
                      style: const TextStyle(
                        fontFamily: CandyFonts.display,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: CandyColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${translateText(ref, vi: 'Cấp độ', en: 'Level')} ${progression.level}  ·  ${translateText(ref, vi: 'Tổng XP', en: 'Total XP')} ${progression.totalXP}',
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 12,
                        color: CandyColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              if (primary != null)
                CandyBadge(
                  label: primary.isGraduated
                      ? translateText(ref, vi: 'Hoàn thành', en: 'Graduated')
                      : translateText(ref, vi: 'Đang học', en: 'Active'),
                  variant: primary.isGraduated
                      ? CandyBadgeVariant.mint
                      : CandyBadgeVariant.yellow,
                  fontSize: 10,
                  hasShadow: true,
                ),
            ],
          ),
          const SizedBox(height: 14),

          // XP progress bar
          if (primary != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'xp_to_next'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CandyColors.charcoal,
                  ),
                ),
                Text(
                  '${progression.xpToNextLevel} XP',
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CandyColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            CandyProgressBar(
              progress: progression.level >= 20
                  ? 1.0
                  : (progression.xpToNextLevel <= 0
                        ? 1.0
                        : 0.0), // client estimate; server is authoritative
              height: 10,
              fillColor: CandyColors.mintGreen,
            ),
            const SizedBox(height: 14),
          ],

          // Streak + active quest + recent achievement + next unlock (compact grid)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak
              Expanded(
                child: CandyStatTile(
                  label: translateText(ref, vi: 'Chuỗi', en: 'Streak'),
                  value: progression.streak?.currentStreak.toString() ?? '0',
                  unit: 'ngày',
                  icon: Icons.local_fire_department_rounded,
                  accentColor: CandyColors.coral,
                  subtitle: progression.streak != null
                      ? translateText(
                          ref,
                          vi: 'Kỷ lục ${progression.streak!.longestStreak}',
                          en: 'Best ${progression.streak!.longestStreak}',
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              // Active quest
              Expanded(
                child: CandyStatTile(
                  label: translateText(ref, vi: 'Nhiệm vụ', en: 'Quest'),
                  value: progression.activeQuest != null ? '1' : '0',
                  unit: 'active',
                  icon: Icons.flag_rounded,
                  accentColor: CandyColors.canaryYellow,
                  subtitle: progression.activeQuest != null
                      ? translateText(
                          ref,
                          vi: 'Đang diễn ra',
                          en: 'In progress',
                        )
                      : translateText(ref, vi: 'Hôm nay nghỉ', en: 'Rest day'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recent achievement + next unlock
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CandyCard(
                  shadow: CandyCardShadow.none,
                  padding: const EdgeInsets.all(12),
                  backgroundColor: CandyColors.canvas,
                  borderColor: CandyColors.muted,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        translateText(
                          ref,
                          vi: 'Huy hiệu gần nhất',
                          en: 'Recent achievement',
                        ),
                        style: const TextStyle(
                          fontFamily: CandyFonts.body,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CandyColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (recentAchievement != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 16,
                              color: CandyColors.mintGreen,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                AchievementCatalog.titleOf(
                                  recentAchievement.achievementId,
                                ),
                                style: const TextStyle(
                                  fontFamily: CandyFonts.display,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: CandyColors.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          translateText(ref, vi: 'Chưa có', en: 'None yet'),
                          style: const TextStyle(
                            fontFamily: CandyFonts.body,
                            fontSize: 12,
                            color: CandyColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CandyCard(
                  shadow: CandyCardShadow.none,
                  padding: const EdgeInsets.all(12),
                  backgroundColor: CandyColors.canvas,
                  borderColor: CandyColors.muted,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        translateText(
                          ref,
                          vi: 'Mốc tiếp theo',
                          en: 'Next milestone',
                        ),
                        style: const TextStyle(
                          fontFamily: CandyFonts.body,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CandyColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (nextUnlock != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 16,
                              color: CandyColors.coral,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nextUnlock['title']?.toString() ?? '',
                                style: const TextStyle(
                                  fontFamily: CandyFonts.display,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: CandyColors.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          translateText(ref, vi: 'Không có', en: 'None'),
                          style: const TextStyle(
                            fontFamily: CandyFonts.body,
                            fontSize: 12,
                            color: CandyColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStatsCard(WidgetRef ref) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(20),
      backgroundColor: CandyColors.card,
      child: Center(
        child: Text(
          'no_data_recorded'.tr(ref),
          style: const TextStyle(
            fontFamily: CandyFonts.body,
            color: CandyColors.muted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard({
    required String message,
    required VoidCallback onRetry,
  }) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      backgroundColor: const Color(0xFFFFF1F0),
      borderColor: CandyColors.coral,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: CandyColors.coral),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: CandyFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CandyButton(
            label: 'Thử lại',
            variant: CandyButtonVariant.danger,
            size: CandyButtonSize.small,
            isFullWidth: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
