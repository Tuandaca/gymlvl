import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../quests/presentation/providers/quest_providers.dart';
import '../../../quests/presentation/widgets/daily_quest_card.dart';
import '../../../onboarding/domain/class_definitions.dart';
import '../providers/stats_providers.dart';
import '../providers/class_providers.dart';
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
    final classesState = ref.watch(userClassesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userClassesProvider);
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
                  
                  const SizedBox(height: 24),
                  
                  // 2. Active Classes (Multi-Class XP Bars)
                  _buildSectionHeader('ACTIVE CLASSES'),
                  const SizedBox(height: 12),
                  _buildClassesSection(classesState),

                  const SizedBox(height: 32),
                  
                  // 3. Daily Quest Section
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

                  // 4. Analytics Section
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

  Widget _buildClassesSection(AsyncValue<List<Map<String, dynamic>>> classesState) {
    return classesState.when(
      data: (classes) {
        if (classes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Text('No class selected yet.', style: TextStyle(color: AppTheme.textDim)),
            ),
          );
        }
        return Column(
          children: classes.map((uc) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildClassCard(uc),
          )).toList(),
        );
      },
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: AppTheme.cyanNeon))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> uc) {
    final classId = uc['class_id'] as String? ?? 'A';
    final classDef = kClassDefinitions[classId];
    final level = (uc['level'] as num?)?.toInt() ?? 1;
    final currentXP = (uc['current_xp'] as num?)?.toInt() ?? 0;
    final slot = (uc['slot'] as String?) ?? 'primary';
    final isGraduated = (uc['is_graduated'] as bool?) ?? false;
    
    // Calculate XP progress for this class
    final classColor = classDef != null ? Color(classDef.colorHex) : AppTheme.cyanNeon;
    final nextLevelXP = classDef?.totalXpForLevel(level + 1) ?? 100;
    final currentLevelBaseXP = classDef?.totalXpForLevel(level) ?? 0;
    final progressInLevel = currentXP - currentLevelBaseXP;
    final xpNeeded = nextLevelXP - currentLevelBaseXP;
    final progress = xpNeeded > 0 ? (progressInLevel / xpNeeded).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: classColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          // Icon + Level
          Column(
            children: [
              Text(classDef?.iconEmoji ?? '⚔️', style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                'Lv $level',
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 13, fontWeight: FontWeight.bold, color: classColor),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Class Info + XP Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      classDef?.className ?? classId,
                      style: TextStyle(color: classColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: classColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slot.toUpperCase(),
                        style: TextStyle(color: classColor.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                    if (isGraduated) ...[
                      const SizedBox(width: 6),
                      const Text('🎓', style: TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatNumber(progressInLevel)} / ${_formatNumber(xpNeeded)} XP',
                      style: const TextStyle(color: AppTheme.textDim, fontSize: 10),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(color: classColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white10,
                    color: classColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
