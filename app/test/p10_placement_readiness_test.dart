import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/placement/domain/readiness_projection.dart';
import 'package:app/features/placement/domain/placement_models.dart';

void main() {
  test('global floor 5 needs 318 XP to reach readiness 6', () {
    final p = ReadinessProjection.calculate(
      confirmedGlobalFloor: 5,
      confirmedClassFloor: 1,
      globalPostConfirmationXp: 0,
      classPostConfirmationXp: 0,
      earnedGlobalLevel: 1,
      earnedGlobalXpToNext: 0,
      earnedClassLevel: 1,
      earnedClassXpToNext: 0,
      classXpBase: 100,
      classXpSlope: 1.5,
    );
    expect(p.globalLevel, 5);
    expect(p.globalXpToNext, 318);
    expect(p.advance(globalXp: 318).globalLevel, 6);
  });
  test('earned lane wins and preserves earned next XP', () {
    final p = ReadinessProjection.calculate(
      confirmedGlobalFloor: 5,
      confirmedClassFloor: 3,
      globalPostConfirmationXp: 0,
      classPostConfirmationXp: 0,
      earnedGlobalLevel: 8,
      earnedGlobalXpToNext: 44,
      earnedClassLevel: 4,
      earnedClassXpToNext: 12,
      classXpBase: 100,
      classXpSlope: 1.5,
    );
    expect(p.globalLevel, 8);
    expect(p.globalXpToNext, 44);
    expect(p.classLevel, 4);
    expect(p.classXpToNext, 12);
  });
  test('malformed state is rejected safely', () {
    expect(
      () => PlacementState.fromJson({
        'status': 'confirmed',
        'readinessGlobalLevel': 101,
      }),
      throwsFormatException,
    );
    expect(() => PlacementState.fromJson({'status': 1}), throwsFormatException);
  });
}
