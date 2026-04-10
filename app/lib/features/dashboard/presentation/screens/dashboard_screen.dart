import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quests/presentation/providers/quest_providers.dart';
import '../../../quests/presentation/widgets/daily_quest_card.dart';
import '../providers/stats_providers.dart';
import '../widgets/stats_charts.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động đồng bộ Quest ngay khi vào Dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeQuestControllerProvider.notifier); // Trigger build
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserProvider);
    final questState = ref.watch(activeQuestControllerProvider);
    final statsState = ref.watch(dashboardStatsControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(activeQuestControllerProvider.notifier).refresh();
          await ref.read(dashboardStatsControllerProvider.notifier).refresh();
        },
        color: AppTheme.cyanNeon,
        child: CustomScrollView(
          slivers: [
            // App Bar
            const SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'SYSTEM HUB',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                  fontSize: 16,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Profile / Level Status
                  _buildProfileSection(userState),
                  
                  const SizedBox(height: 32),
                  
                  // 2. Daily Quest Section
                  _buildSectionHeader('TODAY\'S OBJECTIVE'),
                  const SizedBox(height: 12),
                  questState.when(
                    data: (quest) => quest != null 
                        ? DailyQuestCard(quest: quest)
                        : _buildEmptyQuest(),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.cyanNeon)),
                    error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                  ),

                  const SizedBox(height: 40),

                  // 3. Analytics Section
                  _buildSectionHeader('BIOMETRIC ANALYSIS'),
                  const SizedBox(height: 12),
                  statsState.when(
                    data: (stats) => stats != null 
                        ? _buildAnalyticsGrid(stats)
                        : const Center(child: Text('No data recorded yet.', style: TextStyle(color: AppTheme.textDim))),
                    loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppTheme.cyanNeon),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(AsyncValue<Map<String, dynamic>?> userState) {
    return userState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        final level = (user['level'] as num?)?.toInt() ?? 1;
        final currentLevelXp = (user['current_level_xp'] as num?)?.toInt() ?? 0;
        final title = (user['current_title'] as String?) ?? 'Seeker';
        
        final nextLevelRequirement = (100 * math.pow(level, 1.5)).floor();
        final progress = (currentLevelXp / nextLevelRequirement).clamp(0.0, 1.0);
        
        return Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.cyanNeon.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppTheme.cyanNeon, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['display_name'] ?? 'User',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('LEVEL', style: TextStyle(color: AppTheme.textDim, fontSize: 10)),
                    Text(
                      '$level',
                      style: const TextStyle(fontFamily: 'Orbitron', fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.cyanNeon),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatNumber(currentLevelXp)} / ${_formatNumber(nextLevelRequirement)} XP',
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: AppTheme.cyanNeon, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white10,
                color: AppTheme.cyanNeon,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatNumber(num number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Widget _buildEmptyQuest() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(Icons.bedtime_outlined, color: AppTheme.textDim, size: 40),
          SizedBox(height: 16),
          Text(
            'SYSTEM STANDBY\nRest day detected.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textDim, height: 1.5, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid(dynamic stats) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.panelBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: VolumeTrendChart(trend: stats.volumeTrend),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.panelBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: MuscleRadarChart(split: stats.muscleSplit),
        ),
      ],
    );
  }
}
