import 'dart:convert';

/// Identifies one proposed workout write without performing or storing it.
///
/// The local/test RPC accepts UUID operation IDs as idempotency keys. Production
/// replay remains disabled until the remaining data policies are approved.
final class WorkoutWriteIdentity {
  final String ownerId;
  final String workoutId;
  final String operationId;

  const WorkoutWriteIdentity._({
    required this.ownerId,
    required this.workoutId,
    required this.operationId,
  });

  factory WorkoutWriteIdentity({
    required String ownerId,
    required String workoutId,
    required String operationId,
  }) {
    _validateId(ownerId, 'ownerId');
    _validateId(workoutId, 'workoutId');
    _validateId(operationId, 'operationId');
    return WorkoutWriteIdentity._(
      ownerId: ownerId,
      workoutId: workoutId,
      operationId: operationId,
    );
  }

  factory WorkoutWriteIdentity.fromJson(Map<String, dynamic> json) {
    const keys = {'owner_id', 'workout_id', 'operation_id'};
    if (json.length != keys.length || !json.keys.toSet().containsAll(keys)) {
      throw const FormatException('Invalid workout write identity fields');
    }

    final ownerId = json['owner_id'];
    final workoutId = json['workout_id'];
    final operationId = json['operation_id'];
    if (ownerId is! String ||
        workoutId is! String ||
        operationId is! String ||
        !_validId(ownerId) ||
        !_validId(workoutId) ||
        !_validId(operationId)) {
      throw const FormatException('Invalid workout write identity values');
    }
    return WorkoutWriteIdentity._(
      ownerId: ownerId,
      workoutId: workoutId,
      operationId: operationId,
    );
  }

  /// Field order is fixed so a JSON round-trip has a stable representation.
  Map<String, String> toJson() => {
    'owner_id': ownerId,
    'workout_id': workoutId,
    'operation_id': operationId,
  };

  /// A collision-safe local comparison key, not a server idempotency token.
  String get dedupKey => jsonEncode([ownerId, workoutId, operationId]);

  bool belongsTo(String ownerId, String workoutId) =>
      this.ownerId == ownerId && this.workoutId == workoutId;

  @override
  bool operator ==(Object other) =>
      other is WorkoutWriteIdentity &&
      ownerId == other.ownerId &&
      workoutId == other.workoutId &&
      operationId == other.operationId;

  @override
  int get hashCode => Object.hash(ownerId, workoutId, operationId);

  static bool _validId(String value) =>
      value.isNotEmpty && value.trim() == value;

  static void _validateId(String value, String name) {
    if (!_validId(value)) {
      throw ArgumentError.value(value, name, 'Must be non-blank and trimmed');
    }
  }
}
