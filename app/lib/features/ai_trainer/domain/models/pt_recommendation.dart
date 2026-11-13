/// AI Personal Trainer response model.
///
/// The current Edge contract returns advisory text only. A future structured
/// response must pass validation before any action becomes available.
library;

/// A single recommendation item with a validated target.
class PtRecommendationItem {
  /// Recommendation category.
  final PtRecommendationType type;

  /// Target exercise ID (when type relates to a specific exercise).
  final String? exerciseId;

  /// Exercise name (for display when exerciseId is unknown or null).
  final String? exerciseName;

  /// Human-readable action description.
  final String action;

  /// Optional target details (sets, reps, weight, rest, etc.).
  final Map<String, dynamic> target;

  /// Confidence level as assessed by the AI (0.0-1.0).
  final double confidence;

  /// Whether this item has been validated against GymLvl's data model.
  final bool isValidated;

  const PtRecommendationItem({
    required this.type,
    this.exerciseId,
    this.exerciseName,
    required this.action,
    this.target = const {},
    required this.confidence,
    required this.isValidated,
  });
}

/// Types of AI recommendations.
enum PtRecommendationType {
  exerciseAdjustment,
  exerciseAddition,
  exerciseRemoval,
  exerciseReplacement,
  setRepsAdjustment,
  weightAdjustment,
  restAdjustment,
  frequencyAdjustment,
  progressionStrategy,
  recoveryAdjustment,
  general,
}

/// Structured response from the AI PT service.
class PtRecommendation {
  /// Human-readable summary of the recommendation.
  final String summary;

  /// Machine-readable reasoning steps (observable facts only).
  final List<String> reasoning;

  /// Actionable recommendation items.
  final List<PtRecommendationItem> recommendations;

  /// Safety warnings (medical discomfort, injury risk, etc.).
  final List<String> warnings;

  /// Overall confidence (0.0-1.0).
  final double confidence;

  /// Whether the response passed schema validation.
  final bool isValidated;

  const PtRecommendation({
    required this.summary,
    required this.reasoning,
    required this.recommendations,
    this.warnings = const [],
    required this.confidence,
    required this.isValidated,
  });

  /// Returns actionable (validated) recommendations only.
  List<PtRecommendationItem> get actionable =>
      recommendations.where((r) => r.isValidated).toList();

  /// Returns whether there are any actionable recommendations.
  bool get hasActionable => actionable.isNotEmpty;
}

/// Result of validating an AI response against GymLvl's data model.
class PtValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<PtRecommendationItem> items;

  const PtValidationResult({
    required this.isValid,
    this.errors = const [],
    this.items = const [],
  });
}

/// Validates an AI response against known exercise IDs and
/// supported workout modes.
PtValidationResult validateRecommendation(
  Map<String, dynamic> response, {
  required Set<String> knownExerciseIds,
  required Set<String> supportedModes,
}) {
  final errors = <String>[];
  final items = <PtRecommendationItem>[];

  final rawItems = response['recommendations'];
  if (rawItems == null || rawItems is! List) {
    return const PtValidationResult(
      isValid: false,
      errors: ['missing_recommendations_array'],
    );
  }

  for (final raw in rawItems) {
    if (raw is! Map) continue;
    final typeStr = raw['type'] as String?;
    final type = _parseRecommendationType(typeStr);

    final exerciseId = raw['exercise_id'];
    if (exerciseId != null && !knownExerciseIds.contains(exerciseId)) {
      errors.add('unknown_exercise_id: $exerciseId');
      continue; // Unknown exercise IDs are not added to items.
    }

    final target = Map<String, dynamic>.from(raw['target'] ?? {});

    // Validate numeric targets based on recommendation type.
    if (type == PtRecommendationType.weightAdjustment) {
      final weight = target['weight_kg'];
      if (weight == null || weight is! num || weight < 0 || weight > 1000) {
        errors.add('invalid_weight');
        continue;
      }
    }

    if (type == PtRecommendationType.setRepsAdjustment) {
      final reps = target['reps'];
      if (reps == null || reps is! int || reps < 1 || reps > 1000) {
        errors.add('invalid_reps');
        continue;
      }
    }

    if (type == PtRecommendationType.restAdjustment) {
      final rest = target['rest_seconds'];
      if (rest == null || rest is! int || rest < 0 || rest > 7200) {
        errors.add('invalid_rest_seconds');
        continue;
      }
    }

    // Unknown type (mapped to general) is not actionable.
    final isValidated = type != PtRecommendationType.general;

    items.add(
      PtRecommendationItem(
        type: type,
        exerciseId: exerciseId as String?,
        exerciseName: raw['exercise_name'] as String?,
        action: raw['action'] as String? ?? '',
        target: target,
        confidence: (raw['confidence'] as num?)?.toDouble() ?? 0.5,
        isValidated: isValidated,
      ),
    );
  }

  return PtValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    items: items,
  );
}

/// Maps JSON type strings (snake_case) to [PtRecommendationType] enum values.
PtRecommendationType _parseRecommendationType(String? typeStr) {
  switch (typeStr) {
    case 'exercise_adjustment':
      return PtRecommendationType.exerciseAdjustment;
    case 'exercise_addition':
      return PtRecommendationType.exerciseAddition;
    case 'exercise_removal':
      return PtRecommendationType.exerciseRemoval;
    case 'exercise_replacement':
      return PtRecommendationType.exerciseReplacement;
    case 'set_reps_adjustment':
      return PtRecommendationType.setRepsAdjustment;
    case 'weight_adjustment':
      return PtRecommendationType.weightAdjustment;
    case 'rest_adjustment':
      return PtRecommendationType.restAdjustment;
    case 'frequency_adjustment':
      return PtRecommendationType.frequencyAdjustment;
    case 'progression_strategy':
      return PtRecommendationType.progressionStrategy;
    case 'recovery_adjustment':
      return PtRecommendationType.recoveryAdjustment;
    case 'general':
    case null:
    default:
      return PtRecommendationType.general;
  }
}
