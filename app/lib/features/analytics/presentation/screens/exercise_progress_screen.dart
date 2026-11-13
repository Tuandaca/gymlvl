import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/analytics/presentation/providers/exercise_progress_providers.dart';
import 'package:app/features/analytics/domain/exercise_progress_models.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';
import '../../../../ui/candy/candy_stat_tile.dart';

/// Exercise-level progress / history for a single catalogue exercise.
///
/// Shows completed-session history, working sets, weight, reps, estimated
/// 1RM and PR markers in deterministic chronological order. Warm-up sets are
/// excluded from working-set progression. Renders a graceful empty state when
/// there is no history. Never writes progression or rewards.
class ExerciseProgressScreen extends ConsumerWidget {
  /// Catalogue exercise ID whose progress is shown.
  final String exerciseId;

  /// Optional display name (resolved by the caller when available).
  final String? exerciseName;

  const ExerciseProgressScreen({
    super.key,
    required this.exerciseId,
    this.exerciseName,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _weight(double kg) => kg.toStringAsFixed(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (exerciseName ?? exerciseId).isNotEmpty
        ? '${'exercise_progress_title'.tr(ref)} — ${exerciseName ?? exerciseId}'
        : 'exercise_progress_title'.tr(ref);

    final progressAsync = ref.watch(exerciseProgressProvider(exerciseId));

    return progressAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return _buildEmpty(ref, title);
        }
        return _buildContent(ref, title, sessions);
      },
      loading: () => _buildLoading(ref, title),
      error: (e, _) => _buildError(ref, title, e.toString()),
    );
  }

  Widget _buildLoading(WidgetRef ref, String title) => CandyScaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildError(WidgetRef ref, String title, String message) =>
      CandyScaffold(
        appBar: AppBar(
          title: Text(title),
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

  Widget _buildEmpty(WidgetRef ref, String title) => CandyScaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyEmptyState(
        icon: Icons.fitness_center,
        title: 'exercise_progress_empty'.tr(ref),
        message: 'warmup_excluded'.tr(ref),
        actionLabel: null,
        onAction: null,
      ),
    ),
  );

  Widget _buildContent(
    WidgetRef ref,
    String title,
    List<ExerciseSessionEntry> sessions,
  ) {
    final max1rm = sessions
        .where((s) => s.estimated1rm != null)
        .fold<double?>(
          null,
          (a, b) => (a == null || b.estimated1rm! > a) ? b.estimated1rm : a,
        );
    final prCount = sessions.where((s) => s.hasPr).length;

    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          title,
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
            // KPI tiles.
            CandyStatTile(
              label: 'exercise_history_sessions'.tr(ref),
              value: '${sessions.length}',
              unit: 'buổi tập'.tr(ref),
              accentColor: CandyColors.hotPink,
            ),
            const SizedBox(height: 12.0),
            CandyStatTile(
              label: 'estimated_1rm'.tr(ref),
              value: max1rm != null
                  ? '${max1rm.toStringAsFixed(1)} kg'
                  : 'export_no_data'.tr(ref),
              unit: '1RM',
              accentColor: CandyColors.mintGreen,
            ),
            const SizedBox(height: 12.0),
            CandyStatTile(
              label: 'personal_record'.tr(ref),
              value: '$prCount',
              unit: 'đánh dấu'.tr(ref),
              accentColor: CandyColors.canaryYellow,
            ),
            const SizedBox(height: 20.0),

            // Section header.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 8.0,
              ),
              child: Text(
                'recent_trend'.tr(ref),
                style: const TextStyle(
                  fontFamily: CandyFonts.display,
                  fontSize: 16,
                  color: CandyColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 8.0),

            // Session list (chronological, oldest first).
            ...sessions.map((s) => _sessionRow(ref, s)),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _sessionRow(WidgetRef ref, ExerciseSessionEntry s) {
    final prLabel = switch (s.prKind) {
      'weight' => 'PR (nặng)',
      'reps' => 'PR (lần)',
      'both' => 'PR (nặng + lần)',
      _ => null,
    };
    return CandyCard(
      shadow: CandyCardShadow.small,
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(s.completedAt),
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 15,
                    color: CandyColors.ink,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${s.workingSetCount} ${'working_sets'.tr(ref)} • ${s.totalReps} rep • ${_weight(s.totalVolumeKg)} kg volume',
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    color: CandyColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _weight(s.bestWeightKg),
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 18,
                    color: CandyColors.hotPink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${s.bestReps} rep',
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    color: CandyColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  s.estimated1rm != null
                      ? s.estimated1rm!.toStringAsFixed(1)
                      : '—',
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 15,
                    color: CandyColors.mintGreen,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '1RM'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 11,
                    color: CandyColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          if (prLabel != null)
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: CandyColors.canaryYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: CandyColors.standardBorder(),
                ),
                child: Text(
                  prLabel,
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 11,
                    color: CandyColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
