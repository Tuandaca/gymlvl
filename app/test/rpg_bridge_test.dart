import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/progression/domain/rpg_bridge.dart';

void main() {
  group('RPGBridge.classXPForLevel', () {
    test('XP for class level n is xpBase * n^xpSlope, floored', () {
      expect(RPGBridge.classXPForLevel(1, 80, 1.40), 80);
      expect(RPGBridge.classXPForLevel(2, 80, 1.40), 211);
      expect(RPGBridge.classXPForLevel(3, 80, 1.40), 372);
      expect(RPGBridge.classXPForLevel(3, 100, 1.45), 491);
      expect(RPGBridge.classXPForLevel(5, 130, 1.55), 1575);
      expect(RPGBridge.classXPForLevel(20, 160, 1.65), 22429);
      expect(RPGBridge.classXPForLevel(20, 80, 1.40), 5303);
    });

    test('same inputs always produce the same output (deterministic)', () {
      final a = RPGBridge.classXPForLevel(7, 100, 1.45);
      final b = RPGBridge.classXPForLevel(7, 100, 1.45);
      expect(a, b);
    });
  });

  group('RPGBridge.levelForXP', () {
    test(
      'returns the max level whose threshold is met, with a level-1 floor',
      () {
        expect(RPGBridge.levelForXP(0, 80, 1.40), 1);
        expect(RPGBridge.levelForXP(80, 80, 1.40), 1);
        expect(RPGBridge.levelForXP(211, 80, 1.40), 2);
        expect(RPGBridge.levelForXP(372, 80, 1.40), 3);
      },
    );

    test('is capped at level 20', () {
      expect(RPGBridge.levelForXP(100000, 80, 1.40), 20);
      expect(RPGBridge.levelForXP(5303, 80, 1.40), 20);
    });

    test('same inputs always produce the same output (deterministic)', () {
      final a = RPGBridge.levelForXP(500, 100, 1.45);
      final b = RPGBridge.levelForXP(500, 100, 1.45);
      expect(a, b);
    });
  });

  group('RPGBridge.projectClass', () {
    test('projects level up when earned XP crosses the next threshold', () {
      final p = RPGBridge.projectClass(
        currentXP: 0,
        currentLevel: 1,
        earnedXP: 211,
        xpBase: 80,
        xpSlope: 1.40,
      );
      expect(p.newXP, 211);
      expect(p.newLevel, 2);
      expect(p.leveledUp, isTrue);
      expect(p.xpToNextLevel, 372 - 211);
    });

    test('stays at the same level when the threshold is not crossed', () {
      final p = RPGBridge.projectClass(
        currentXP: 200,
        currentLevel: 2,
        earnedXP: 100,
        xpBase: 80,
        xpSlope: 1.40,
      );
      expect(p.newXP, 300);
      expect(p.newLevel, 2);
      expect(p.leveledUp, isFalse);
      expect(p.xpToNextLevel, 372 - 300);
    });

    test('caps at level 20 (graduation) with no XP to next level', () {
      final p = RPGBridge.projectClass(
        currentXP: 5000,
        currentLevel: 19,
        earnedXP: 500,
        xpBase: 80,
        xpSlope: 1.40,
      );
      expect(p.newXP, 5500);
      expect(p.newLevel, 20);
      expect(p.leveledUp, isTrue);
      expect(p.xpToNextLevel, 0);
    });

    test('no earned XP keeps level and reports full gap to next level', () {
      final p = RPGBridge.projectClass(
        currentXP: 0,
        currentLevel: 1,
        earnedXP: 0,
        xpBase: 80,
        xpSlope: 1.40,
      );
      expect(p.newXP, 0);
      expect(p.newLevel, 1);
      expect(p.leveledUp, isFalse);
      expect(p.xpToNextLevel, 211);
    });

    test('same inputs always produce the same projection (deterministic)', () {
      final a = RPGBridge.projectClass(
        currentXP: 100,
        currentLevel: 2,
        earnedXP: 50,
        xpBase: 100,
        xpSlope: 1.45,
      );
      final b = RPGBridge.projectClass(
        currentXP: 100,
        currentLevel: 2,
        earnedXP: 50,
        xpBase: 100,
        xpSlope: 1.45,
      );
      expect(a, b);
    });
  });
}
