import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/training_plan/newcomer_journey_models.dart';
import 'package:app/features/training_plan/presentation/providers/training_plan_providers.dart';
import 'package:app/features/training_plan/presentation/widgets/plan_day_card.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';

/// First-week plan screen: shows the generated beginner plan and journey state.
///
/// Watches [firstWeekPlanProvider] and [newcomerJourneyProvider]. Never writes
/// progression; tapping start/continue delegates to callbacks owned by the
/// caller (workout creation is server-authoritative via complete_workout).
class FirstWeekPlanScreen extends ConsumerWidget {
  /// Invoked when the user starts the first workout.
  final VoidCallback? onStartWorkout;

  /// Invoked when the user continues an in-progress workout.
  final VoidCallback? onContinueWorkout;

  /// Invoked when the user retries after an error.
  final VoidCallback? onRetry;

  const FirstWeekPlanScreen({
    super.key,
    this.onStartWorkout,
    this.onContinueWorkout,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(firstWeekPlanProvider);
    final journeyAsync = ref.watch(newcomerJourneyProvider);

    if (planAsync.isLoading || journeyAsync.isLoading) {
      return _buildLoading(ref);
    }
    if (planAsync.hasError || journeyAsync.hasError) {
      final error = planAsync.error ?? journeyAsync.error;
      return _buildError(ref, error.toString(), onRetry);
    }

    final plan = planAsync.value;
    final journey = journeyAsync.value;
    if (plan == null || journey == null) {
      return _buildEmpty(ref);
    }
    if (plan.isEmpty) {
      return _buildEmpty(ref, journey: journey);
    }
    return _buildContent(ref, plan, journey);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // States
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildLoading(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('plan_title'.tr(ref)),
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

  Widget _buildError(WidgetRef ref, String message, VoidCallback? onRetry) =>
      CandyScaffold(
        appBar: AppBar(
          title: Text('plan_title'.tr(ref)),
          backgroundColor: CandyColors.canvas,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: CandyErrorState(
            title: 'error_title'.tr(ref),
            message: message,
            retryLabel: 'retry'.tr(ref),
            onRetry: onRetry,
          ),
        ),
      );

  Widget _buildEmpty(WidgetRef ref, {NewcomerJourneyState? journey}) {
    final title = journey is ReturningUser
        ? 'journey_returning_user'.tr(ref)
        : 'plan_empty'.tr(ref);
    return CandyScaffold(
      appBar: AppBar(
        title: Text('plan_title'.tr(ref)),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: CandyEmptyState(
          icon: Icons.fitness_center_outlined,
          title: title,
          message: 'plan_empty'.tr(ref),
          actionLabel: null,
          onAction: null,
        ),
      ),
    );
  }

  Widget _buildContent(
    WidgetRef ref,
    FirstWeekPlan plan,
    NewcomerJourneyState journey,
  ) {
    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          'plan_title'.tr(ref),
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
            Semantics(
              label:
                  '${'plan_title'.tr(ref)}: ${_journeyStateLabel(journey, ref)}',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: CandyColors.card,
                  border: CandyColors.standardBorder(),
                  borderRadius: BorderRadius.circular(CandyColors.pillRadius),
                ),
                child: Text(
                  _journeyStateLabel(journey, ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

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
            const SizedBox(height: 16.0),

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
            ...plan.days.map((day) => PlanDayCard(day: day, ref: ref)),
            const SizedBox(height: 24.0),

            _buildActionButton(ref, journey),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  String _journeyStateLabel(NewcomerJourneyState s, WidgetRef ref) {
    if (s is NoHistory) return 'journey_no_history'.tr(ref);
    if (s is PlanAvailable) return 'journey_plan_available'.tr(ref);
    if (s is PlanStarted) return 'journey_plan_started'.tr(ref);
    if (s is WorkoutPartial) return 'journey_workout_partial'.tr(ref);
    if (s is WorkoutComplete) return 'journey_workout_complete'.tr(ref);
    if (s is ProgressionAvailable) {
      return 'journey_progression_available'.tr(ref);
    }
    if (s is ReturningUser) return 'journey_returning_user'.tr(ref);
    return '';
  }

  Widget _buildActionButton(WidgetRef ref, NewcomerJourneyState current) {
    if (current is PlanAvailable) {
      return CandyButton(
        label: 'plan_open'.tr(ref),
        variant: CandyButtonVariant.primary,
        size: CandyButtonSize.medium,
        onPressed: onStartWorkout,
      );
    }
    if (current is PlanStarted) {
      return CandyButton(
        label: 'start_workout'.tr(ref),
        variant: CandyButtonVariant.primary,
        size: CandyButtonSize.medium,
        onPressed: onStartWorkout,
      );
    }
    if (current is WorkoutPartial) {
      return CandyButton(
        label: 'continue'.tr(ref),
        variant: CandyButtonVariant.mint,
        size: CandyButtonSize.medium,
        onPressed: onContinueWorkout,
      );
    }
    return const SizedBox.shrink();
  }
}
