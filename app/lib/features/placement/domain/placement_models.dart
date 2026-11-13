/// Preview inputs only; profile snapshots are never sent in the request.
class PlacementEquipment {
  const PlacementEquipment({this.barbell = false, this.pullUpBar = false});
  final bool barbell;
  final bool pullUpBar;
  Map<String, Object> toJson() => {'barbell': barbell, 'pullUpBar': pullUpBar};
}

class PlacementAnchor {
  const PlacementAnchor({
    required this.exerciseId,
    this.protocolVersion = 'strict-v1',
    this.loadKg = 0,
    this.reps = 0,
    this.durationSeconds = 0,
  });
  final String exerciseId;
  final String protocolVersion;
  final double loadKg;
  final int reps;
  final int durationSeconds;
  Map<String, Object> toJson() => {
    'exerciseId': exerciseId.toLowerCase(),
    'protocolVersion': protocolVersion,
    'loadKg': loadKg,
    'reps': reps,
    'durationSeconds': durationSeconds,
  };
}

class PlacementInput {
  PlacementInput({
    required this.classId,
    required this.hasTrainingExperience,
    this.skip = false,
    this.equipment = const PlacementEquipment(),
    List<PlacementAnchor> anchors = const [],
    this.age,
    this.bodyMassKg,
  }) : anchors = List.unmodifiable(anchors);
  final String classId;
  final bool hasTrainingExperience;
  final bool skip;
  final PlacementEquipment equipment;
  final List<PlacementAnchor> anchors;
  final int? age;
  final double? bodyMassKg;
  Map<String, Object> toRequest() {
    final sorted = hasTrainingExperience && !skip
        ? anchors.toList()
        : <PlacementAnchor>[];
    sorted.sort(
      (a, b) =>
          a.exerciseId.toLowerCase().compareTo(b.exerciseId.toLowerCase()),
    );
    return {
      'policyVersion': 'placement-v0.1',
      'classId': classId,
      'hasTrainingExperience': hasTrainingExperience,
      'skip': skip,
      'equipment': equipment.toJson(),
      'anchors': sorted.map((a) => a.toJson()).toList(),
    };
  }

  Map<String, Object> toEnvelope(String operationId) => {
    'operationId': operationId,
    'request': toRequest(),
  };
}

/// Non-authoritative result for selecting a plan, never an earned level.
class PlacementEstimate {
  PlacementEstimate({
    required this.classLevel,
    required this.globalLevel,
    required this.reason,
    Map<String, int> anchorScores = const {},
  }) : anchorScores = Map.unmodifiable(anchorScores);
  final int classLevel;
  final int globalLevel;
  final String reason;
  final Map<String, int> anchorScores;
}

/// Server projection only. Null means unavailable, never a fabricated level.
class PlacementState {
  const PlacementState({
    required this.status,
    this.policyVersion,
    this.assessmentId,
    this.reason,
    this.recommendedPlanRoute,
    this.assessedClassId,
    this.provisionalClassLevel,
    this.provisionalGlobalLevel,
    this.confirmedClassFloor,
    this.confirmedGlobalFloor,
    this.readinessClassLevel,
    this.readinessGlobalLevel,
    this.readinessXpToNextGlobalLevel,
    this.readinessXpToNextClassLevel,
  });
  final String status;
  final String? policyVersion;
  final String? assessmentId;
  final String? reason;
  final String? recommendedPlanRoute;
  final String? assessedClassId;
  final int? provisionalClassLevel;
  final int? provisionalGlobalLevel;
  final int? confirmedClassFloor;
  final int? confirmedGlobalFloor;
  final int? readinessClassLevel;
  final int? readinessGlobalLevel;
  final int? readinessXpToNextGlobalLevel;
  final int? readinessXpToNextClassLevel;
  factory PlacementState.fromJson(Map<String, dynamic> json) {
    String? string(String key) {
      final value = json[key];
      if (value == null || value is String) return value as String?;
      throw FormatException('Invalid placement $key');
    }

    int? integer(String key, {int min = 0, int? max}) {
      final value = json[key];
      if (value == null) return null;
      if (value is num &&
          value.isFinite &&
          value >= min &&
          (max == null || value <= max) &&
          value == value.roundToDouble()) {
        return value.toInt();
      }
      throw FormatException('Invalid placement $key');
    }

    final status = string('status');
    if (status == null || status.isEmpty) {
      throw const FormatException('Missing placement status');
    }
    return PlacementState(
      status: status,
      policyVersion: string('policyVersion'),
      assessmentId: string('assessmentId'),
      reason: string('reason'),
      recommendedPlanRoute: string('recommendedPlanRoute'),
      assessedClassId: string('assessedClassId'),
      provisionalClassLevel: integer('provisionalClassLevel', min: 1, max: 5),
      provisionalGlobalLevel: integer(
        'provisionalGlobalLevel',
        min: 1,
        max: 10,
      ),
      confirmedClassFloor: integer('confirmedClassFloor', min: 1, max: 5),
      confirmedGlobalFloor: integer('confirmedGlobalFloor', min: 1, max: 10),
      readinessClassLevel: integer('readinessClassLevel', min: 1, max: 20),
      readinessGlobalLevel: integer('readinessGlobalLevel', min: 1, max: 100),
      readinessXpToNextGlobalLevel: integer('readinessXpToNextGlobalLevel'),
      readinessXpToNextClassLevel: integer('readinessXpToNextClassLevel'),
    );
  }
}
