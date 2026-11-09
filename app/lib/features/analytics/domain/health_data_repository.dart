/// P7 Gate 5: Health-platform integration boundary.
///
/// A narrow, testable abstraction over external health platform data.
/// Does NOT implement production Health Connect / HealthKit integration.
/// External health records are tagged as non-authoritative and grant
/// ZERO RPG reward. complete_workout is never called for health data.
library;

/// Capability state detected by the health platform adapter.
enum HealthCapability { available, unsupported, notConnected }

/// Source of health data.
enum HealthDataSource { googleFit, healthKit, unknown }

/// Type of health measurement.
enum HealthMeasurementType {
  bodyWeight,
  bodyFatPercentage,

  /// Extensible for future compatible measurement types.
}

/// An external health record, explicitly tagged as non-authoritative.
///
/// External health records are never GymLvl authoritative workout
/// completions. They grant ZERO XP, quest progress, streak, achievement,
/// or unlock.
class ExternalHealthRecord {
  const ExternalHealthRecord({
    required this.id,
    required this.userId,
    required this.source,
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.isExternal,
  });

  final String id;
  final String userId;
  final HealthDataSource source;
  final HealthMeasurementType type;
  final double value;
  final String unit;
  final DateTime recordedAt;

  /// Always true for external health records; distinguishes from GymLvl
  /// authoritative records.
  final bool isExternal;

  ExternalHealthRecord copyWith({
    String? id,
    String? userId,
    HealthDataSource? source,
    HealthMeasurementType? type,
    double? value,
    String? unit,
    DateTime? recordedAt,
    bool? isExternal,
  }) {
    return ExternalHealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      recordedAt: recordedAt ?? this.recordedAt,
      isExternal: isExternal ?? this.isExternal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalHealthRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          source == other.source &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, userId, source, type);

  @override
  String toString() =>
      'ExternalHealthRecord(id: $id, source: $source, type: $type, value: $value $unit, external: $isExternal)';
}

/// A workout summary from an external health source (boundary only).
class ExternalHealthWorkoutSummary {
  const ExternalHealthWorkoutSummary({
    required this.externalId,
    required this.userId,
    required this.source,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.caloriesBurned,
    required this.isExternal,
  });

  final String externalId;
  final String userId;
  final HealthDataSource source;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final double? caloriesBurned;
  final bool isExternal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalHealthWorkoutSummary &&
          runtimeType == other.runtimeType &&
          externalId == other.externalId &&
          userId == other.userId &&
          source == other.source;

  @override
  int get hashCode => Object.hash(externalId, userId, source);

  @override
  String toString() =>
      'ExternalHealthWorkoutSummary(externalId: $externalId, source: $source, external: $isExternal)';
}

/// Result of capability detection.
class HealthCapabilityResult {
  const HealthCapabilityResult({required this.capability, this.message});

  final HealthCapability capability;
  final String? message;

  bool get isSupported => capability == HealthCapability.available;

  @override
  String toString() =>
      'HealthCapabilityResult(capability: $capability, message: $message)';
}

/// Abstract repository for health-platform integration.
///
/// Implementations provide a fake/mock for tests and a thin platform
/// adapter when native integration is available. Production Health
/// Connect / HealthKit rollout is PLATFORM-BLOCKED / DEFERRED.
abstract class HealthDataRepository {
  /// Detect whether the platform supports health data access.
  Future<HealthCapabilityResult> detectCapability();

  /// Fetch external body-weight records. Returns empty list when
  /// capability is not available.
  Future<List<ExternalHealthRecord>> getBodyWeightRecords({
    required String userId,
    DateTime? from,
    DateTime? to,
  });

  /// Fetch external body measurement records.
  Future<List<ExternalHealthRecord>> getBodyMeasurementRecords({
    required String userId,
    HealthMeasurementType? type,
    DateTime? from,
    DateTime? to,
  });

  /// Fetch external workout summaries.
  Future<List<ExternalHealthWorkoutSummary>> getWorkoutSummaries({
    required String userId,
    DateTime? from,
    DateTime? to,
  });
}

/// Fake/mock implementation for tests and unsupported platforms.
///
/// Always reports unsupported / not-connected and returns empty data.
/// No real Health platform / device required in CI.
class FakeHealthDataRepository extends HealthDataRepository {
  @override
  Future<HealthCapabilityResult> detectCapability() async =>
      const HealthCapabilityResult(
        capability: HealthCapability.unsupported,
        message: 'Health platform integration not available in this build.',
      );

  @override
  Future<List<ExternalHealthRecord>> getBodyWeightRecords({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async => [];

  @override
  Future<List<ExternalHealthRecord>> getBodyMeasurementRecords({
    required String userId,
    HealthMeasurementType? type,
    DateTime? from,
    DateTime? to,
  }) async => [];

  @override
  Future<List<ExternalHealthWorkoutSummary>> getWorkoutSummaries({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async => [];
}
