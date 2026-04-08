import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  int _xpRequiredForLevel(int level) {
    return (100 * math.pow(level, 1.5)).floor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('TỔNG QUAN', style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.cyanNeon)),
        error: (e, st) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: AppTheme.dangerOrange))),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Chưa có dữ liệu User.', style: TextStyle(color: AppTheme.textDim)));
          }

          final level = user['level'] as int? ?? 1;
          final totalXp = user['total_xp'] as int? ?? 0;
          final title = user['current_title'] as String? ?? 'Tập Sự';

          final baseXP = level > 1 ? _xpRequiredForLevel(level - 1) : 0;
          final nextXP = _xpRequiredForLevel(level);
          final currentLevelXp = totalXp - baseXP;
          final xpNeeded = nextXP - baseXP;
          
          final progress = xpNeeded > 0 ? (currentLevelXp / xpNeeded).clamp(0.0, 1.0) : 0.0;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thẻ (Card) User Profile "Solo Leveling"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.panelBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.1), blurRadius: 15, spreadRadius: 2),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'LEVEL $level',
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.cyanNeon,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Thanh XP (Progress Bar)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('XP', style: TextStyle(color: AppTheme.textDim, fontWeight: FontWeight.bold)),
                          Text(
                            '$totalXp / $nextXP',
                            style: const TextStyle(color: AppTheme.textMain, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.white10,
                          color: AppTheme.cyanNeon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Các tính năng Dashboard khác\nđang được phát triển...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textDim),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
