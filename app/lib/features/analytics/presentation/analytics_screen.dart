import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import 'package:app/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:app/features/analytics/presentation/widgets/heatmap_chart.dart';
import 'package:app/features/analytics/presentation/widgets/muscle_balance_chart.dart';
import 'package:app/features/analytics/presentation/widgets/pr_chart.dart';
import 'package:app/features/analytics/presentation/widgets/weight_trend_chart.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';

/// Analytics screen: workout frequency, volume trend, personal records and
/// muscle balance.
///
/// Renders an [AnalyticsResult] (client-side preview only; PostgreSQL is
/// authoritative). Never writes progression or rewards and never calls the
/// server. When no [result] is passed it reads [analyticsProvider]. When every
/// metric list is empty it shows an empty state.
class AnalyticsScreen extends ConsumerWidget {
  /// Aggregated analytics result, or null when not yet loaded.
  final AnalyticsResult? result;

  /// True while data is being loaded.
  final bool isLoading;

  /// Error message when loading failed.
  final String? error;

  /// Invoked when the user retries after an error.
  final VoidCallback? onRetry;

  const AnalyticsScreen({
    super.key,
    this.result,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  bool _hasData(AnalyticsResult r) =>
      r.heatmap.isNotEmpty ||
      r.weightTrend.isNotEmpty ||
      r.prChart.isNotEmpty ||
      r.muscleBalance.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (error != null) {
      return _buildError(ref);
    }
    final resultAsync = result == null
        ? ref.watch(analyticsProvider)
        : AsyncValue.data(result!);

    return resultAsync.when(
      loading: () => _buildLoading(ref),
      error: (e, _) => _buildError(ref, e.toString()),
      data: (data) {
        if (!_hasData(data)) {
          return _buildEmpty(ref);
        }
        return _buildContent(ref, data);
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // States
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildLoading(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('analytics_title'.tr(ref)),
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

  Widget _buildError(WidgetRef ref, [String? message]) => CandyScaffold(
    appBar: AppBar(
      title: Text('analytics_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyErrorState(
        title: 'error_title'.tr(ref),
        message: message ?? error ?? '',
        retryLabel: 'retry'.tr(ref),
        onRetry: onRetry,
      ),
    ),
  );

  Widget _buildEmpty(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('analytics_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyEmptyState(
        icon: Icons.insert_chart_outlined,
        title: 'no_data_recorded'.tr(ref),
        message: 'analytics_empty'.tr(ref),
        actionLabel: null,
        onAction: null,
      ),
    ),
  );

  Widget _buildContent(WidgetRef ref, AnalyticsResult result) {
    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          'analytics_title'.tr(ref),
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
            if (result.heatmap.isNotEmpty)
              HeatmapChart(points: result.heatmap, ref: ref),
            if (result.heatmap.isNotEmpty) const SizedBox(height: 16.0),
            if (result.weightTrend.isNotEmpty)
              WeightTrendChart(points: result.weightTrend, ref: ref),
            if (result.weightTrend.isNotEmpty) const SizedBox(height: 16.0),
            if (result.prChart.isNotEmpty)
              PRChart(points: result.prChart, ref: ref),
            if (result.prChart.isNotEmpty) const SizedBox(height: 16.0),
            if (result.muscleBalance.isNotEmpty)
              MuscleBalanceChart(points: result.muscleBalance, ref: ref),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
