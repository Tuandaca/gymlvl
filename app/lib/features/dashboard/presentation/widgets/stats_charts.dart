import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../../domain/dashboard_stats.dart';

/// Tactile Neubrutalist Volume Trend Chart with 2px solid ink borders,
/// hard shadows, and Space Mono metrics.
class VolumeTrendChart extends ConsumerWidget {
  const VolumeTrendChart({super.key, required this.trend});
  final List<VolumePoint> trend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (trend.isEmpty) return const SizedBox.shrink();
    final total = trend.fold<double>(0, (value, point) => value + point.value);
    final maxVal = trend.fold<double>(1.0, (m, p) => math.max(m, p.value));

    final semanticsLabel = trend
        .map((p) => '${p.date}: ${p.value.toStringAsFixed(0)} kg')
        .join(', ');

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(18),
      backgroundColor: CandyColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'weekly_volume'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CandyColors.charcoal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CandyBadge(
                label:
                    '${trend.length} ${translateText(ref, vi: 'ngày', en: 'days')}',
                variant: CandyBadgeVariant.yellow,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${total.toStringAsFixed(0)} kg',
            style: const TextStyle(
              fontFamily: CandyFonts.mono,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: CandyColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),

          // Tactile Bar Visualization
          Semantics(
            label: semanticsLabel,
            child: ExcludeSemantics(
              child: SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: trend.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    final fraction = (point.value / maxVal).clamp(0.05, 1.0);
                    final isHighest = point.value == maxVal;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              point.value >= 1000
                                  ? '${(point.value / 1000).toStringAsFixed(1)}k'
                                  : point.value.toStringAsFixed(0),
                              style: const TextStyle(
                                fontFamily: CandyFonts.mono,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: CandyColors.charcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 100 * fraction,
                              decoration: BoxDecoration(
                                color: isHighest
                                    ? CandyColors.canaryYellow
                                    : (index % 2 == 0
                                          ? CandyColors.mintGreen
                                          : CandyColors.softLilac),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                border: CandyColors.standardBorder(width: 1.8),
                                boxShadow: CandyColors.shadowPressed(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  trend.first.date,
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    color: CandyColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trend.last.date,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    color: CandyColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tactile Neubrutalist Muscle Balance chart with Space Grotesk labels
/// and CandyProgressBar indicators.
class MuscleRadarChart extends ConsumerWidget {
  const MuscleRadarChart({super.key, required this.split});
  final List<MuscleSplit> split;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (split.isEmpty) return const SizedBox.shrink();
    final maximum = split.fold<double>(
      1,
      (value, item) => math.max(value, item.value),
    );

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(18),
      backgroundColor: CandyColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'muscle_balance'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CandyColors.charcoal,
                  ),
                ),
              ),
              const Icon(
                Icons.pie_chart_outline_rounded,
                size: 16,
                color: CandyColors.charcoal,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...split.map((item) {
            final fraction = (item.value / maximum).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontFamily: CandyFonts.body,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: CandyColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.value.toStringAsFixed(0)} ${translateText(ref, vi: 'hiệp', en: 'sets')}',
                        style: const TextStyle(
                          fontFamily: CandyFonts.mono,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CandyColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CandyProgressBar(
                    progress: fraction,
                    height: 10,
                    fillColor: CandyColors.softLilac,
                    trackColor: CandyColors.canvas,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
