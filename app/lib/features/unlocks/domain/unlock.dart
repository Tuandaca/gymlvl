/// Unlock domain model for the P5 unlock system.
///
/// Unlocks motivate progression but never lock core fitness functionality
/// (workout logging, exercise access, routine creation, history, analytics,
/// measurements, export, safety). They are awarded server-side and previewed
/// by the client only.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'unlock.freezed.dart';
part 'unlock.g.dart';

/// A single unlock with its unlocked/locked state.
@freezed
abstract class Unlock with _$Unlock {
  const factory Unlock({
    required String unlockId,
    required String title,
    String? description,
    required String unlockType, // 'level' | 'achievement' | 'class' | 'quest'
    required int thresholdValue,
    required String rewardType, // 'badge' | 'title' | 'accent'
    required String rewardValue,
    required bool isUnlocked,
  }) = _Unlock;

  factory Unlock.fromJson(Map<String, dynamic> json) => _$UnlockFromJson(json);
}
