import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
abstract class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @JsonKey(name: 'volume_trend') required List<VolumePoint> volumeTrend,
    @JsonKey(name: 'muscle_split') required List<MuscleSplit> muscleSplit,
    @JsonKey(name: 'recent_prs') @Default([]) List<PRRecord> recentPRs,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}

@freezed
abstract class VolumePoint with _$VolumePoint {
  const factory VolumePoint({
    required String date,
    required double value,
  }) = _VolumePoint;

  factory VolumePoint.fromJson(Map<String, dynamic> json) =>
      _$VolumePointFromJson(json);
}

@freezed
abstract class MuscleSplit with _$MuscleSplit {
  const factory MuscleSplit({
    required String label,
    required double value,
  }) = _MuscleSplit;

  factory MuscleSplit.fromJson(Map<String, dynamic> json) =>
      _$MuscleSplitFromJson(json);
}

@freezed
abstract class PRRecord with _$PRRecord {
  const factory PRRecord({
    @JsonKey(name: 'exercises') required Map<String, dynamic> exerciseInfo,
    @JsonKey(name: 'max_weight_kg') required double maxWeight,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _PRRecord;

  factory PRRecord.fromJson(Map<String, dynamic> json) =>
      _$PRRecordFromJson(json);
}
