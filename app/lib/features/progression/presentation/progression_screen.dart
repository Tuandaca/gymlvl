import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/progression/domain/rpg_bridge.dart';
import 'package:app/features/progression/domain/progression_engine.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_badge.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';
import '../../../../ui/candy/candy_stat_tile.dart';
import '../../../../core/localization/localization_engine.dart';
import 'widgets/class_progress_card.dart';
import 'widgets/exercise_progression_card.dart';

/// Progression screen: class XP/level projection, estimated 1RM per set, PR
/// indicators, and RPE/RIR display.
///
/// Everything is a client-side preview computed from `RPGBridge` and
/// `ProgressionEngine`. The server owns every award, level and reward via
/// `complete_workout`; this screen never writes progression.
class ProgressionScreen extends ConsumerWidget {
  /// Projection computed by `RPGBridge.projectClass`; null when no class data.
  final RPGProjection? projection;

  /// Completed sets used to estimate 1RM and detect PR previews.
  final List<WorkoutSet> sets;

  /// Display name of the class.
  final String className;

  /// ``class_definitions.xp_base`` for the progress bar scale.
  final int xpBase;

  /// ``class_definitions.xp_slope`` for the progress bar scale.
  final double xpSlope;

  /// True while data is being loaded.
  final bool isLoading;

  /// Error message when loading failed.
  final String? error;

  /// Retry callback for the error state.
  final VoidCallback? onRetry;

  const ProgressionScreen({
    super.key,
    this.projection,
    this.sets = const [],
    required this.className,
    required this.xpBase,
    required this.xpSlope,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  double? _max1RM(List<WorkoutSet> sets) {
    double? max;
    for (final set in sets) {
      if (!set.isCompleted || set.weightKg <= 0 || set.reps <= 0) continue;
      final estimate = ProgressionEngine.calculateOneRepMax(
        weightKg: set.weightKg,
        reps: set.reps,
      );
      if (estimate != null && (max == null || estimate > max)) {
        max = estimate;
      }
    }
    return max;
  }

  int _prCount(List<WorkoutSet> sets) {
    var count = 0;
    for (final set in sets) {
      if (!set.isCompleted || set.weightKg <= 0 || set.reps <= 0) continue;
      final pr = ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: null,
        existingMaxReps: null,
        newWeight: set.weightKg,
        newReps: set.reps,
      );
      if (pr.kind != 'none') count += 1;
    }
    return count;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (error != null) {
      return _buildError(ref);
    }
    if (isLoading) {
      return _buildLoading(ref);
    }
    if (projection == null) {
      return _buildEmpty(ref);
    }
    return _buildContent(ref);
  }

  Widget _buildLoading(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('progression_title'.tr(ref)),
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

  Widget _buildError(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('progression_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyErrorState(
        title: 'error_title'.tr(ref),
        message: error ?? '',
        retryLabel: 'retry'.tr(ref),
        onRetry: onRetry,
      ),
    ),
  );

  Widget _buildEmpty(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('progression_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'no_class_data'.tr(ref),
        message: 'no_sets_data'.tr(ref),
      ),
    ),
  );

  Widget _buildContent(WidgetRef ref) {
    final projection = this.projection!;
    final max1RM = _max1RM(sets);
    final prCount = _prCount(sets);

    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          'progression_title'.tr(ref),
          style: const TextStyle(fontFamily: CandyFonts.display),
        ),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (projection.leveledUp)
            CandyBadge(
              label: 'level_up'.tr(ref),
              variant: CandyBadgeVariant.yellow,
              fontSize: 11.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClassProgressCard(
              projection: projection,
              className: className,
              xpBase: xpBase,
              xpSlope: xpSlope,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: '${'level'.tr(ref)} ${projection.newLevel}',
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 48.0,
                        minHeight: 48.0,
                      ),
                      child: CandyStatTile(
                        label: 'level'.tr(ref),
                        value: projection.newLevel.toString(),
                        unit: '',
                        icon: Icons.auto_awesome,
                        accentColor: CandyColors.canaryYellow,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Semantics(
                    label:
                        '${'estimated_1rm'.tr(ref)} ${max1RM == null ? '—' : max1RM.toStringAsFixed(0)} kg',
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 48.0,
                        minHeight: 48.0,
                      ),
                      child: CandyStatTile(
                        label: 'estimated_1rm'.tr(ref),
                        value: max1RM == null ? '—' : max1RM.toStringAsFixed(0),
                        unit: 'kg',
                        icon: Icons.fitness_center,
                        accentColor: CandyColors.mintGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Semantics(
                    label: '${'personal_record'.tr(ref)} $prCount',
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 48.0,
                        minHeight: 48.0,
                      ),
                      child: CandyStatTile(
                        label: 'personal_record'.tr(ref),
                        value: prCount.toString(),
                        icon: Icons.emoji_events,
                        accentColor: CandyColors.hotPink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Text(
              'exercises'.tr(ref),
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: CandyColors.ink,
              ),
            ),
            const SizedBox(height: 12.0),
            if (sets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'no_sets_data'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 14,
                    color: CandyColors.charcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sets.length,
                itemBuilder: (context, index) {
                  final set = sets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ExerciseProgressionCard(set: set),
                  );
                },
              ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
