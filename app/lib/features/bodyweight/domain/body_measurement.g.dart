// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BodyMeasurement _$BodyMeasurementFromJson(Map<String, dynamic> json) =>
    _BodyMeasurement(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$BodyMeasurementTypeEnumMap, json['type']),
      measurementType: $enumDecodeNullable(
        _$BodyMeasurementTypeEnumMap,
        json['measurement_type'],
      ),
      value: (json['value'] as num).toDouble(),
      unit: $enumDecode(_$BodyMeasurementUnitEnumMap, json['unit']),
      measuredAt: DateTime.parse(json['measured_at'] as String),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BodyMeasurementToJson(
  _BodyMeasurement instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$BodyMeasurementTypeEnumMap[instance.type]!,
  'measurement_type': _$BodyMeasurementTypeEnumMap[instance.measurementType],
  'value': instance.value,
  'unit': _$BodyMeasurementUnitEnumMap[instance.unit]!,
  'measured_at': instance.measuredAt.toIso8601String(),
  'notes': instance.notes,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$BodyMeasurementTypeEnumMap = {
  BodyMeasurementType.bodyWeight: 'body_weight',
  BodyMeasurementType.bodyFatPercentage: 'body_fat_percentage',
  BodyMeasurementType.chest: 'chest',
  BodyMeasurementType.waist: 'waist',
  BodyMeasurementType.hips: 'hips',
  BodyMeasurementType.upperArm: 'upper_arm',
  BodyMeasurementType.thigh: 'thigh',
};

const _$BodyMeasurementUnitEnumMap = {
  BodyMeasurementUnit.kg: 'kg',
  BodyMeasurementUnit.cm: 'cm',
  BodyMeasurementUnit.percent: 'percent',
};
