import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';

/// 4 tactile Neubrutalist KPI tiles:
/// - Volume in Canary Yellow (#FFD23F)
/// - Workouts in Hot Pink (#FF3D81)
/// - Sets in Mint Green (#3DDC97)
/// - Streak in Soft Lilac (#C8A2FF) with flame icon
///
/// Guaranteed zero RenderFlex overflow from 320px to 1440px viewports.
class KpiTilesGrid extends ConsumerWidget {
  final double totalVolume;
  final int totalWorkouts;
  final int totalSets;
  final int currentStreak;
  final int longestStreak;

  const KpiTilesGrid({
    super.key,
    required this.totalVolume,
    required this.totalWorkouts,
    required this.totalSets,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumeText = totalVolume >= 10000
        ? (totalVolume / 1000).toStringAsFixed(1)
        : totalVolume.toStringAsFixed(0);
    final volumeUnit = totalVolume >= 10000 ? 't' : 'kg';

    final volumeLabel = translateText(ref, vi: 'KHỐI LƯỢNG', en: 'VOLUME');
    final workoutsLabel = translateText(ref, vi: 'BUỔI TẬP', en: 'WORKOUTS');
    final setsLabel = translateText(ref, vi: 'SỐ HIỆP', en: 'SETS');
    final streakLabel = translateText(ref, vi: 'CHUỖI TẬP', en: 'STREAK');

    // The caller supplies windowed values, never lifetime totals: volume covers
    // the seven-day trend and workouts/sets cover the three most recent sessions.
    // Each tile states its own window instead of claiming a total (FND-BUG-005).
    final volumeWindow = translateText(
      ref,
      vi: '7 ngày gần nhất',
      en: 'last 7 days',
    );
    final recentWindow = translateText(
      ref,
      vi: '3 buổi gần nhất',
      en: 'last 3 workouts',
    );

    final workoutsUnit = translateText(ref, vi: 'buổi', en: 'done');
    final setsUnit = translateText(ref, vi: 'hiệp', en: 'sets');
    final streakUnit = translateText(ref, vi: 'ngày', en: 'days');
    final bestStreakSubtitle = translateText(
      ref,
      vi: 'Kỷ lục: $longestStreak ngày',
      en: 'Best: $longestStreak days',
    );

    final tile1 = CandyStatTile(
      label: volumeLabel,
      value: volumeText,
      unit: volumeUnit,
      subtitle: volumeWindow,
      icon: Icons.fitness_center_rounded,
      accentColor: CandyColors.canaryYellow,
    );

    final tile2 = CandyStatTile(
      label: workoutsLabel,
      value: '$totalWorkouts',
      unit: workoutsUnit,
      subtitle: recentWindow,
      icon: Icons.check_circle_outline_rounded,
      accentColor: CandyColors.hotPink,
    );

    final tile3 = CandyStatTile(
      label: setsLabel,
      value: '$totalSets',
      unit: setsUnit,
      subtitle: recentWindow,
      icon: Icons.repeat_rounded,
      accentColor: CandyColors.mintGreen,
    );

    final tile4 = CandyStatTile(
      label: streakLabel,
      value: '$currentStreak',
      unit: streakUnit,
      icon: Icons.local_fire_department_rounded,
      accentColor: CandyColors.softLilac,
      subtitle: bestStreakSubtitle,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Narrow mobile (<540px): 2x2 grid with tight spacing
        if (constraints.maxWidth < 540) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: tile1),
                  const SizedBox(width: 10),
                  Expanded(child: tile2),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: tile3),
                  const SizedBox(width: 10),
                  Expanded(child: tile4),
                ],
              ),
            ],
          );
        }

        // Wide mobile / tablet / desktop (>=540px): 4 tiles in a single row
        return Row(
          children: [
            Expanded(child: tile1),
            const SizedBox(width: 12),
            Expanded(child: tile2),
            const SizedBox(width: 12),
            Expanded(child: tile3),
            const SizedBox(width: 12),
            Expanded(child: tile4),
          ],
        );
      },
    );
  }
}
