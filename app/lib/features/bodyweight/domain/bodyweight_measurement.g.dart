// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bodyweight_measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BodyweightMeasurement _$BodyweightMeasurementFromJson(
  Map<String, dynamic> json,
) => _BodyweightMeasurement(
  id: json['id'] as String,
  userId: json['userId'] as String,
  weightKg: (json['weight_kg'] as num).toDouble(),
  measuredAt: DateTime.parse(json['measured_at'] as String),
  source: $enumDecode(_$BodyweightSourceEnumMap, json['source']),
  notes: json['notes'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BodyweightMeasurementToJson(
  _BodyweightMeasurement instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'weight_kg': instance.weightKg,
  'measured_at': instance.measuredAt.toIso8601String(),
  'source': _$BodyweightSourceEnumMap[instance.source]!,
  'notes': instance.notes,
  'created_at': instance.createdAt?.toIso8601String(),
};

const _$BodyweightSourceEnumMap = {
  BodyweightSource.profileBaseline: 'profileBaseline',
  BodyweightSource.manualWeighIn: 'manualWeighIn',
  BodyweightSource.scale: 'scale',
};
