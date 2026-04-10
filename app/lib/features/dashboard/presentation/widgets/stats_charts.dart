import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_stats.dart';

class VolumeTrendChart extends StatelessWidget {
  final List<VolumePoint> trend;

  const VolumeTrendChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WEEKLY VOLUME (kg)',
          style: TextStyle(color: AppTheme.textDim, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                  isCurved: true,
                  color: AppTheme.cyanNeon,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.cyanNeon.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MuscleRadarChart extends StatelessWidget {
  final List<MuscleSplit> split;

  const MuscleRadarChart({super.key, required this.split});

  @override
  Widget build(BuildContext context) {
    if (split.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MUSCLE BALANCE',
          style: TextStyle(color: AppTheme.textDim, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              dataSets: [
                RadarDataSet(
                  fillColor: AppTheme.purpleNeon.withOpacity(0.2),
                  borderColor: AppTheme.purpleNeon,
                  entryRadius: 3,
                  dataEntries: split.map((e) => RadarEntry(value: e.value)).toList(),
                ),
              ],
              getTitle: (index, angle) {
                if (index < split.length) {
                  return RadarChartTitle(text: split[index].label, angle: angle);
                }
                return const RadarChartTitle(text: '');
              },
              radarBorderData: const BorderSide(color: Colors.white10),
              tickBorderData: const BorderSide(color: Colors.transparent),
              gridBorderData: const BorderSide(color: Colors.white10, width: 1),
              titleTextStyle: const TextStyle(color: AppTheme.textDim, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
