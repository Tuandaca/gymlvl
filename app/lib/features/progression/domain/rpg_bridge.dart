/// Deterministic class XP / level projection for the RPG class system.
///
/// Pure functions: same inputs always produce the same output. No clock,
/// locale, or random dependence. Versionable by copying this file.
///
/// All values are client-side display estimates only. The server owns every
/// award, level and graduation via `complete_workout`; this package never
/// writes progression.
///
/// Class math per D-043: XP for class level n = ``xp_base * n^xp_slope``,
/// using `class_definitions.xp_base`/`xp_slope`.
library;

import 'dart:math' as math;

/// Projection of a class level after earning preview XP.
class RPGProjection {
  /// Cumulative class XP after adding the earned preview XP.
  final int newXP;

  /// Class level reached at ``newXP`` (1-based, minimum 1, capped at 20).
  final int newLevel;

  /// True when ``newLevel`` exceeds the level before the workout.
  final bool leveledUp;

  /// XP still needed to reach ``newLevel + 1``. Zero at level 20 (graduation).
  final int xpToNextLevel;

  const RPGProjection({
    required this.newXP,
    required this.newLevel,
    required this.leveledUp,
    required this.xpToNextLevel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RPGProjection &&
          runtimeType == other.runtimeType &&
          newXP == other.newXP &&
          newLevel == other.newLevel &&
          leveledUp == other.leveledUp &&
          xpToNextLevel == other.xpToNextLevel;

  @override
  int get hashCode => Object.hash(newXP, newLevel, leveledUp, xpToNextLevel);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'newXP': newXP,
    'newLevel': newLevel,
    'leveledUp': leveledUp,
    'xpToNextLevel': xpToNextLevel,
  };

  factory RPGProjection.fromJson(Map<String, dynamic> json) => RPGProjection(
    newXP: json['newXP'] as int,
    newLevel: json['newLevel'] as int,
    leveledUp: json['leveledUp'] as bool,
    xpToNextLevel: json['xpToNextLevel'] as int,
  );

  @override
  String toString() =>
      'RPGProjection(newXP: $newXP, newLevel: $newLevel, leveledUp: $leveledUp, xpToNextLevel: $xpToNextLevel)';
}

/// Deterministic class XP / level projection.
///
/// Matches `class_definitions.xp_base`/`xp_slope` from the `class_definitions`
/// table. PostgreSQL remains authoritative — Flutter displays estimates only.
class RPGBridge {
  RPGBridge._();

  /// Cumulative XP required to reach ``level``:
  /// ``(xpBase * level^xpSlope).floor()``.
  ///
  /// Levels are 1-based. ``level < 1`` is treated as 1 to avoid NaN from
  /// fractional powers of negative numbers; this never occurs in normal use.
  static int classXPForLevel(int level, int xpBase, double xpSlope) {
    final clampedLevel = level < 1 ? 1 : level;
    return (xpBase * math.pow(clampedLevel.toDouble(), xpSlope)).floor();
  }

  /// Inverse of [classXPForLevel]: the max level L (1-based, capped at 20)
  /// such that ``classXPForLevel(L) <= currentXP``.
  ///
  /// Always returns at least 1: a user begins at level 1 even before earning
  /// the level-1 threshold. Capped at 20 (graduation).
  static int levelForXP(int currentXP, int xpBase, double xpSlope) {
    var level = 1;
    while (level < 20 &&
        currentXP >= classXPForLevel(level + 1, xpBase, xpSlope)) {
      level += 1;
    }
    return level;
  }

  /// Projects the class state after earning ``earnedXP`` preview XP.
  ///
  /// Returns ``newXP``, ``newLevel``, whether a level up occurred, and the
  /// XP remaining to the next level (zero at level 20 / graduation).
  static RPGProjection projectClass({
    required int currentXP,
    required int currentLevel,
    required int earnedXP,
    required int xpBase,
    required double xpSlope,
  }) {
    final newXP = currentXP + earnedXP;
    final newLevel = levelForXP(newXP, xpBase, xpSlope);
    final leveledUp = newLevel > currentLevel;
    final xpToNextLevel = newLevel >= 20
        ? 0
        : math.max(0, classXPForLevel(newLevel + 1, xpBase, xpSlope) - newXP);
    return RPGProjection(
      newXP: newXP,
      newLevel: newLevel,
      leveledUp: leveledUp,
      xpToNextLevel: xpToNextLevel,
    );
  }
}
