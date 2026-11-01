import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../domain/exercise.dart';
import '../../workout_copy.dart';
import '../providers/exercise_providers.dart';

/// Read-only exercise information. The picker remains the owner of selection.
class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;
  final Exercise? initialExercise;
  final bool canSelect;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    this.initialExercise,
    this.canSelect = false,
  });

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/exercise-picker');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached = initialExercise?.id == exerciseId ? initialExercise : null;
    final detail = cached == null
        ? ref.watch(exerciseDetailProvider(exerciseId))
        : AsyncValue<Exercise?>.data(cached);

    return Scaffold(
      backgroundColor: CandyColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: workoutText(ref, 'detail_back'),
          onPressed: () => _goBack(context),
        ),
        title: Text(workoutText(ref, 'exercise_detail')),
      ),
      body: detail.when(
        loading: () => Center(
          child: Semantics(
            label: workoutText(ref, 'exercise_detail'),
            child: const CircularProgressIndicator(color: CandyColors.hotPink),
          ),
        ),
        error: (error, stack) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: CandyErrorState(
                title: workoutText(ref, 'detail_error_title'),
                message: workoutText(ref, 'detail_error_message'),
                retryLabel: workoutText(ref, 'retry'),
                onRetry: () => ref.invalidate(exerciseListProvider),
              ),
            ),
          ),
        ),
        data: (exercise) => exercise == null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: CandyEmptyState(
                      icon: Icons.search_off,
                      title: workoutText(ref, 'detail_not_found_title'),
                      message: workoutText(ref, 'detail_not_found_message'),
                      actionLabel: workoutText(ref, 'detail_back_short'),
                      onAction: () => _goBack(context),
                    ),
                  ),
                ),
              )
            : _ExerciseDetailContent(
                exercise: exercise,
                canSelect: canSelect && context.canPop(),
              ),
      ),
    );
  }
}

class _ExerciseDetailContent extends ConsumerWidget {
  final Exercise exercise;
  final bool canSelect;

  const _ExerciseDetailContent({
    required this.exercise,
    required this.canSelect,
  });

  String _value(WidgetRef ref, String? value) {
    if (value == null || value.trim().isEmpty) {
      return workoutText(ref, 'detail_unavailable');
    }
    return value;
  }

  Widget _field(WidgetRef ref, String labelKey, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workoutText(ref, labelKey),
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CandyColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _value(ref, value),
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 16,
              color: CandyColors.ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(localizationModeProvider);
    final isVi = mode != AppLangMode.en;
    final displayName = exercise.localizedName(isVi ? 'vi' : 'en');
    final nameHasTranslation = isVi
        ? exercise.nameVi.trim().isNotEmpty
        : exercise.nameEn.trim().isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 22, 32),
          children: [
            CandyCard(
              backgroundColor: CandyColors.softLilac,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: workoutText(ref, 'detail_media_unavailable'),
                    excludeSemantics: true,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 144),
                      decoration: BoxDecoration(
                        color: CandyColors.canvas,
                        border: CandyColors.standardBorder(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 44,
                            color: CandyColors.ink,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            workoutText(ref, 'detail_media_unavailable'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: CandyFonts.body,
                              color: CandyColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: CandyFonts.display,
                      fontSize: 24,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      color: CandyColors.ink,
                    ),
                  ),
                  if (!nameHasTranslation) ...[
                    const SizedBox(height: 8),
                    Text(
                      workoutText(ref, 'detail_name_fallback'),
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 13,
                        color: CandyColors.charcoal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            CandyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field(ref, 'detail_primary_muscle', null),
                  _field(
                    ref,
                    'detail_secondary_muscles',
                    exercise.secondaryMuscles.isEmpty
                        ? null
                        : exercise.secondaryMuscles.join(', '),
                  ),
                  _field(ref, 'equipment', exercise.equipment),
                  _field(ref, 'category', exercise.category),
                  _field(
                    ref,
                    'detail_movement_pattern',
                    exercise.movementPattern,
                  ),
                  _field(ref, 'detail_difficulty', exercise.difficulty),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CandyCard(
              backgroundColor: CandyColors.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutText(ref, 'detail_instructions'),
                    style: const TextStyle(
                      fontFamily: CandyFonts.display,
                      fontSize: 19,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                      color: CandyColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workoutText(ref, 'detail_instructions_unavailable'),
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 15,
                      height: 1.5,
                      color: CandyColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            if (canSelect) ...[
              const SizedBox(height: 24),
              CandyButton(
                label: workoutText(ref, 'detail_select'),
                icon: Icons.check,
                onPressed: () => context.pop(exercise),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
