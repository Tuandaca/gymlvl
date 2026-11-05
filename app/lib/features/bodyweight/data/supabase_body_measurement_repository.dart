/// Supabase repository for P4 general body measurements.
///
/// Owner-scoped: every row is filtered by the authenticated user's id.
/// Reads/writes go through PostgREST + RLS on public.body_measurements.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/body_measurement.dart';

/// Abstract repository interface for body measurements.
abstract class BodyMeasurementRepository {
  /// All measurements for the owner, newest first.
  Future<List<BodyMeasurement>> getMeasurements();

  /// Measurements for [type], newest first.
  Future<List<BodyMeasurement>> getMeasurementsByType(BodyMeasurementType type);

  /// Insert a measurement. [unit] must match the type's canonical unit.
  Future<BodyMeasurement> insert(BodyMeasurement measurement);

  /// Update an existing measurement (owner-only via RLS).
  Future<BodyMeasurement> update(BodyMeasurement measurement);

  /// Delete a measurement by id (owner-only via RLS).
  Future<void> delete(String id);
}

/// Supabase-backed implementation.
class SupabaseBodyMeasurementRepository implements BodyMeasurementRepository {
  final SupabaseClient _supabase;

  SupabaseBodyMeasurementRepository(this._supabase);

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('session_required');
    return id;
  }

  static BodyMeasurement _decode(Map<String, dynamic> json) {
    final type = BodyMeasurementType.values.firstWhere(
      (e) => e.wireValue == (json['measurement_type'] as String?),
      orElse: () => BodyMeasurementType.bodyWeight,
    );
    final unit = BodyMeasurementUnit.values.firstWhere(
      (e) => e.wireValue == (json['unit'] as String?),
      orElse: () => BodyMeasurementUnit.kg,
    );
    return BodyMeasurement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: type,
      value: (json['value'] as num).toDouble(),
      unit: unit,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  @override
  Future<List<BodyMeasurement>> getMeasurements() async {
    final response = await _supabase
        .from('body_measurements')
        .select()
        .eq('user_id', _userId)
        .order('measured_at', ascending: false);
    return (response as List)
        .map((e) => _decode(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BodyMeasurement>> getMeasurementsByType(
    BodyMeasurementType type,
  ) async {
    final response = await _supabase
        .from('body_measurements')
        .select()
        .eq('user_id', _userId)
        .eq('measurement_type', type.wireValue)
        .order('measured_at', ascending: false);
    return (response as List)
        .map((e) => _decode(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BodyMeasurement> insert(BodyMeasurement measurement) async {
    if (measurement.unit.wireValue != measurement.type.canonicalUnit) {
      throw ArgumentError(
        'Unit ${measurement.unit.wireValue} is not canonical for '
        '${measurement.type.labelKey} (${measurement.type.canonicalUnit}).',
      );
    }
    final response = await _supabase
        .from('body_measurements')
        .insert(measurement.toSupabaseJson())
        .select()
        .single();
    return _decode(response);
  }

  @override
  Future<BodyMeasurement> update(BodyMeasurement measurement) async {
    if (measurement.unit.wireValue != measurement.type.canonicalUnit) {
      throw ArgumentError(
        'Unit ${measurement.unit.wireValue} is not canonical for '
        '${measurement.type.labelKey} (${measurement.type.canonicalUnit}).',
      );
    }
    final response = await _supabase
        .from('body_measurements')
        .update(measurement.toSupabaseJson())
        .eq('id', measurement.id)
        .eq('user_id', _userId)
        .select()
        .single();
    return _decode(response);
  }

  @override
  Future<void> delete(String id) async {
    await _supabase
        .from('body_measurements')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
