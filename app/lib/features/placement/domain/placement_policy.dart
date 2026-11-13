import 'placement_models.dart';

abstract final class PlacementPolicy {
  static const policyVersion = 'placement-v0.1';
  static const anchorSlugsByClass = <String, List<String>>{
    'A': ['push-up', 'bodyweight-air-squat', 'plank'],
    'B': ['barbell-bench-press', 'barbell-squat', 'barbell-deadlift'],
    'C': ['barbell-squat', 'barbell-bench-press', 'barbell-deadlift'],
    'D': ['bodyweight-air-squat', 'push-up', 'plank'],
    'E': ['pull-up', 'push-up', 'plank'],
    'F': ['barbell-bench-press', 'barbell-squat', 'push-up'],
  };
  static const _bands = <String, List<double>>{
    'barbell-bench-press': [.4, .6, .8, 1],
    'barbell-squat': [.75, 1, 1.25, 1.5],
    'barbell-deadlift': [.9, 1.2, 1.5, 1.8],
    'push-up': [5, 10, 20, 30],
    'pull-up': [1, 3, 6, 10],
    'bodyweight-air-squat': [10, 20, 30, 40],
    'plank': [30, 60, 90, 120],
  };
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Mirrors the server policy for plan preview. Never grants progression.
  static PlacementEstimate preview(
    PlacementInput input,
    Map<String, String> canonicalExerciseIds,
  ) {
    if (!anchorSlugsByClass.containsKey(input.classId)) {
      throw ArgumentError.value(input.classId, 'classId');
    }
    PlacementEstimate base(
      String reason, [
      Map<String, int> scores = const {},
    ]) => PlacementEstimate(
      classLevel: 1,
      globalLevel: 1,
      reason: reason,
      anchorScores: scores,
    );
    // These paths intentionally discard performance answers, as does serialization.
    if (!input.hasTrainingExperience) return base('never_trained');
    if (input.skip) return base('skipped');
    final suppliedMass = input.bodyMassKg;
    if (suppliedMass != null &&
        (!suppliedMass.isFinite || suppliedMass < 20 || suppliedMass > 400)) {
      throw ArgumentError('Invalid body mass');
    }
    if (input.anchors.length > 3) throw ArgumentError('At most three anchors');
    final reverse = <String, String>{};
    for (final entry in canonicalExerciseIds.entries) {
      if (!_bands.containsKey(entry.key)) continue;
      if (!_uuid.hasMatch(entry.value) ||
          reverse.containsKey(entry.value.toLowerCase())) {
        throw ArgumentError('Canonical IDs must be distinct catalog UUIDs');
      }
      reverse[entry.value.toLowerCase()] = entry.key;
    }
    final seen = <String>{};
    final scores = <String, int>{};
    final requiresBarbell = ['B', 'C', 'F'].contains(input.classId);
    final fallback = requiresBarbell && !input.equipment.barbell;
    final allowed = fallback
        ? anchorSlugsByClass['A']!
        : anchorSlugsByClass[input.classId]!;
    var missingMass = false;
    for (final anchor in input.anchors) {
      final exerciseId = anchor.exerciseId.toLowerCase();
      final slug = reverse[exerciseId];
      if (slug == null ||
          !allowed.contains(slug) ||
          !seen.add(exerciseId) ||
          anchor.protocolVersion != 'strict-v1') {
        throw ArgumentError('Unsupported or duplicate anchor/protocol');
      }
      if (!anchor.loadKg.isFinite ||
          anchor.loadKg < 0 ||
          anchor.loadKg > 1000 ||
          anchor.reps < 0 ||
          anchor.reps > 1000 ||
          anchor.durationSeconds < 0 ||
          anchor.durationSeconds > 7200) {
        throw ArgumentError('Invalid anchor measurements');
      }
      int score;
      if (slug.startsWith('barbell-')) {
        if (!input.equipment.barbell ||
            anchor.loadKg <= 0 ||
            anchor.reps < 4 ||
            anchor.reps > 10 ||
            anchor.durationSeconds != 0) {
          throw ArgumentError(
            'Barbell requires total load and 4–10 repetitions',
          );
        }
        final mass = input.bodyMassKg;
        if (mass == null) {
          missingMass = true;
          continue;
        }
        if (!mass.isFinite || mass < 20 || mass > 400) {
          throw ArgumentError('Invalid body mass');
        }
        score =
            1 +
            _bands[slug]!
                .where(
                  (threshold) => _barbellMeets(
                    anchor.loadKg,
                    anchor.reps,
                    mass,
                    threshold,
                  ),
                )
                .length;
      } else {
        if (anchor.loadKg != 0 ||
            (slug == 'plank'
                ? anchor.reps != 0
                : anchor.durationSeconds != 0)) {
          throw ArgumentError(
            'Bodyweight anchors require exact unweighted metrics',
          );
        }
        if (slug == 'pull-up' && !input.equipment.pullUpBar) {
          throw ArgumentError('Pull-up bar unavailable');
        }
        final metric = slug == 'plank' ? anchor.durationSeconds : anchor.reps;
        score = 1 + _bands[slug]!.where((value) => metric >= value).length;
      }
      scores[exerciseId] = score;
    }
    if (input.age == null || input.age! < 18 || input.age! > 64) {
      return base('unsupported_age', scores);
    }
    if (fallback) return base('missing_equipment', scores);
    if (missingMass) return base('missing_body_mass', scores);
    if (scores.length < 2) return base('insufficient_anchors', scores);
    final sorted = scores.values.toList()..sort();
    var level = sorted.length == 3 ? sorted[1] : sorted[0];
    final cap =
        ['A', 'D', 'F'].contains(input.classId) ||
            (input.classId == 'E' &&
                !seen.contains(canonicalExerciseIds['pull-up']?.toLowerCase()))
        ? 3
        : 5;
    if (level > cap) level = cap;
    return PlacementEstimate(
      classLevel: level,
      globalLevel: const [1, 3, 5, 7, 10][level - 1],
      reason: 'provisional',
      anchorScores: scores,
    );
  }

  // Compare the decimal values sent as JSON, matching PostgreSQL numeric.
  // Avoid both intermediate floating-point division and threshold epsilons.
  static bool _barbellMeets(
    double load,
    int reps,
    double mass,
    double threshold,
  ) {
    final (loadN, loadD) = _decimalFraction(load);
    final (massN, massD) = _decimalFraction(mass);
    final (bandN, bandD) = _decimalFraction(threshold);
    return loadN * BigInt.from(30 + reps) * massD * bandD >=
        BigInt.from(30) * massN * bandN * loadD;
  }

  static (BigInt, BigInt) _decimalFraction(double value) {
    final parts = value.toString().toLowerCase().split('e');
    final mantissa = parts.first.split('.');
    final decimals = mantissa.length == 2 ? mantissa[1] : '';
    final numerator = BigInt.parse('${mantissa.first}$decimals');
    final scale =
        decimals.length - (parts.length == 2 ? int.parse(parts[1]) : 0);
    return scale >= 0
        ? (numerator, BigInt.from(10).pow(scale))
        : (numerator * BigInt.from(10).pow(-scale), BigInt.one);
  }
}
