import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_stat_tile.dart';

/// Muscle balance: volume by exercise category within the aggregation window.
class MuscleBalanceChart extends StatelessWidget {
  final List<MuscleBalancePoint> points;
  final WidgetRef ref;

  const MuscleBalanceChart({
    super.key,
    required this.points,
    required this.ref,
  });

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
            'muscle_balance'.tr(ref),
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: CandyColors.ink,
            ),
          ),
          const SizedBox(height: 12.0),
          ...points.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Semantics(
                label:
                    '${p.category}: ${p.volumeKg.toStringAsFixed(0)} kg, ${p.totalSets} sets, ${p.percent.toStringAsFixed(0)}%',
                child: CandyStatTile(
                  label: p.category,
                  value: p.volumeKg.toStringAsFixed(0),
                  unit: 'kg',
                  subtitle:
                      '${p.totalSets} ${'sets'.tr(ref)} · ${p.percent.toStringAsFixed(0)}%',
                  accentColor: CandyColors.softLilac,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
