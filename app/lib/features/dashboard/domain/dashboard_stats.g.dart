// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    _DashboardStats(
      volumeTrend: (json['volume_trend'] as List<dynamic>)
          .map((e) => VolumePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      muscleSplit: (json['muscle_split'] as List<dynamic>)
          .map((e) => MuscleSplit.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentPRs:
          (json['recent_prs'] as List<dynamic>?)
              ?.map((e) => PRRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DashboardStatsToJson(_DashboardStats instance) =>
    <String, dynamic>{
      'volume_trend': instance.volumeTrend,
      'muscle_split': instance.muscleSplit,
      'recent_prs': instance.recentPRs,
    };

_VolumePoint _$VolumePointFromJson(Map<String, dynamic> json) => _VolumePoint(
  date: json['date'] as String,
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$VolumePointToJson(_VolumePoint instance) =>
    <String, dynamic>{'date': instance.date, 'value': instance.value};

_MuscleSplit _$MuscleSplitFromJson(Map<String, dynamic> json) => _MuscleSplit(
  label: json['label'] as String,
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$MuscleSplitToJson(_MuscleSplit instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

_PRRecord _$PRRecordFromJson(Map<String, dynamic> json) => _PRRecord(
  exerciseInfo: json['exercises'] as Map<String, dynamic>,
  maxWeight: (json['max_weight_kg'] as num).toDouble(),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PRRecordToJson(_PRRecord instance) => <String, dynamic>{
  'exercises': instance.exerciseInfo,
  'max_weight_kg': instance.maxWeight,
  'updated_at': instance.updatedAt.toIso8601String(),
};
