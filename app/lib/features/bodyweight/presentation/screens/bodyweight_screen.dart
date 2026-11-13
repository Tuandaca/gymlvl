import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/bodyweight/domain/bodyweight_trend.dart';
import 'package:app/features/bodyweight/presentation/providers/bodyweight_providers.dart';
import 'package:app/features/bodyweight/presentation/widgets/bodyweight_trend_chart.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';
import '../../../../ui/candy/candy_stat_tile.dart';

/// Bodyweight trend screen: body mass over time plus the latest weigh-in.
///
/// Body mass comes exclusively from [profiles.weight_kg] (weigh-ins).
/// workout_sets.weight_kg is external/added load only and is never shown as
/// body mass here.
class BodyweightScreen extends ConsumerWidget {
  const BodyweightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(bodyweightTrendProvider);

    if (trendAsync.isLoading) {
      return _buildLoading(ref);
    }
    if (trendAsync.hasError) {
      return _buildError(ref, trendAsync.error.toString());
    }
    final points = trendAsync.value;
    if (points == null || points.isEmpty) {
      return _buildEmpty(ref);
    }
    return _buildContent(ref, points);
  }

  Widget _buildLoading(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('bodyweight_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(
            'loading'.tr(ref),
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 14,
              color: CandyColors.charcoal,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildError(WidgetRef ref, String message) => CandyScaffold(
    appBar: AppBar(
      title: Text('bodyweight_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyErrorState(
        title: 'error_title'.tr(ref),
        message: message,
        retryLabel: 'retry'.tr(ref),
        onRetry: null,
      ),
    ),
  );

  Widget _buildEmpty(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('bodyweight_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyEmptyState(
        icon: Icons.monitor_weight_outlined,
        title: 'bodyweight_no_data'.tr(ref),
        message: 'plan_empty'.tr(ref),
        actionLabel: null,
        onAction: null,
      ),
    ),
  );

  Widget _buildContent(WidgetRef ref, List<BodyweightTrendPoint> points) {
    final latest = points.last;
    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          'bodyweight_title'.tr(ref),
          style: const TextStyle(fontFamily: CandyFonts.display),
        ),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trend chart.
            BodyweightTrendChart(points: points, ref: ref),
            const SizedBox(height: 16.0),

            // Latest weigh-in: body mass (never external load).
            CandyStatTile(
              label: 'bodyweight_body_mass'.tr(ref),
              value: latest.weightKg.toStringAsFixed(1),
              unit: 'kg',
              subtitle:
                  '${'bodyweight_weigh_in'.tr(ref)}: ${_formatDate(latest.date)}',
              accentColor: CandyColors.hotPink,
            ),
            const SizedBox(height: 16.0),

            // Distinguish body mass from external/added load on sets.
            CandyCard(
              shadow: CandyCardShadow.small,
              backgroundColor: CandyColors.canaryYellow.withValues(alpha: 0.15),
              borderColor: CandyColors.canaryYellow,
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, size: 20, color: CandyColors.ink),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'bodyweight_note'.tr(ref),
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 13,
                        color: CandyColors.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
