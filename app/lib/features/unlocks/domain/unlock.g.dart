// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Unlock _$UnlockFromJson(Map<String, dynamic> json) => _Unlock(
  unlockId: json['unlockId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  unlockType: json['unlockType'] as String,
  thresholdValue: (json['thresholdValue'] as num).toInt(),
  rewardType: json['rewardType'] as String,
  rewardValue: json['rewardValue'] as String,
  isUnlocked: json['isUnlocked'] as bool,
);

Map<String, dynamic> _$UnlockToJson(_Unlock instance) => <String, dynamic>{
  'unlockId': instance.unlockId,
  'title': instance.title,
  'description': instance.description,
  'unlockType': instance.unlockType,
  'thresholdValue': instance.thresholdValue,
  'rewardType': instance.rewardType,
  'rewardValue': instance.rewardValue,
  'isUnlocked': instance.isUnlocked,
};
