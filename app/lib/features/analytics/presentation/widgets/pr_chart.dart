import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_card.dart';

/// Personal-record bar chart: server-authoritative max weight per exercise.
class PRChart extends StatelessWidget {
  final List<PRChartPoint> points;
  final WidgetRef ref;

  const PRChart({super.key, required this.points, required this.ref});

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: CandyCardShadow.medium,
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'analytics_pr_chart'.tr(ref),
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: CandyColors.ink,
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: 200.0,
            child: BarChart(
              BarChartData(
                barGroups: points.asMap().entries.map((e) {
                  final p = e.value;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: p.maxWeightKg,
                        width: 16.0,
                        color: CandyColors.hotPink,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const Text('');
                        }
                        final name = points[idx].exerciseName;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              name.length > 8
                                  ? '${name.substring(0, 8)}…'
                                  : name,
                              style: const TextStyle(
                                fontFamily: CandyFonts.body,
                                fontSize: 9,
                                color: CandyColors.charcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontFamily: CandyFonts.body,
                            fontSize: 10,
                            color: CandyColors.charcoal,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
