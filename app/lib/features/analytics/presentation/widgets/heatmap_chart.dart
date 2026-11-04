import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_card.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Workout frequency heatmap: one cell per local day, color intensity by count.
class HeatmapChart extends StatelessWidget {
  final List<HeatmapPoint> points;
  final WidgetRef ref;

  const HeatmapChart({super.key, required this.points, required this.ref});

  Color _color(int count) {
    if (count <= 0) return CandyColors.card;
    if (count == 1) return CandyColors.mintGreen.withValues(alpha: 0.35);
    if (count == 2) return CandyColors.mintGreen.withValues(alpha: 0.65);
    return CandyColors.mintGreen;
  }

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
            'analytics_heatmap'.tr(ref),
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: CandyColors.ink,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: points.map((p) {
              final label = _formatDate(p.date);
              return Semantics(
                label: '$label: ${p.workoutCount} ${'workouts'.tr(ref)}',
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _color(p.workoutCount),
                      border: CandyColors.standardBorder(),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Center(
                      child: Text(
                        '${p.workoutCount}',
                        style: const TextStyle(
                          fontFamily: CandyFonts.mono,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: CandyColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
