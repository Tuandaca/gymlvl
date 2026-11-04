import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/bodyweight/domain/bodyweight_trend.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_card.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Bodyweight trend line chart: body mass (kg) over time, from weigh-ins only.
///
/// workout_sets.weight_kg is external/added load and is never plotted here.
class BodyweightTrendChart extends StatelessWidget {
  final List<BodyweightTrendPoint> points;
  final WidgetRef ref;

  const BodyweightTrendChart({super.key, required this.points, required this.ref});

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
            'bodyweight_trend'.tr(ref),
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
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            _formatDate(points[idx].date),
                            style: const TextStyle(
                              fontFamily: CandyFonts.body,
                              fontSize: 10,
                              color: CandyColors.charcoal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
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
                lineBarsData: [
                  LineChartBarData(
                    spots: points
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg))
                        .toList(),
                    isCurved: true,
                    color: CandyColors.hotPink,
                    barWidth: 3.0,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: CandyColors.hotPink.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
