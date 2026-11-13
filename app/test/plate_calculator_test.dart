import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/workout/domain/plate_calculator.dart';

void main() {
  final calc = PlateCalculator();

  test('exact target with bar and plates', () {
    final result = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [20, 10, 5, 2.5, 1.25],
    );
    expect(result.isExact, isTrue);
    expect(result.achievedWeight, 60);
    expect(result.remainder, 0);
    // 60 - 20 = 40 total plates -> 20 per side -> 1x 20kg per side.
    expect(result.platesPerSide, {20: 1});
  });

  test('non-exact target returns closest achievable below target', () {
    final result = calc.calculate(
      targetWeight: 55,
      barWeight: 20,
      denominations: [20, 10, 5, 2.5, 1.25],
    );
    // 55 - 20 = 35 total -> 17.5 per side -> 1x10 + 1x5 + 1x2.5 = 17.5 exact.
    expect(result.isExact, isTrue);
    expect(result.achievedWeight, 55);
    expect(result.platesPerSide, {10: 1, 5: 1, 2.5: 1});
  });

  test('different bar weight changes plate count', () {
    final lightBar = calc.calculate(
      targetWeight: 60,
      barWeight: 0,
      denominations: [20, 10, 5],
    );
    final heavyBar = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [20, 10, 5],
    );
    expect(lightBar.achievedWeight, 60);
    expect(lightBar.platesPerSide, {20: 1, 10: 1});
    expect(heavyBar.achievedWeight, 60);
    expect(heavyBar.platesPerSide, {20: 1});
  });

  test('bar alone heavier than target yields negative remainder', () {
    final result = calc.calculate(
      targetWeight: 15,
      barWeight: 20,
      denominations: [20, 10, 5],
    );
    expect(result.isExact, isFalse);
    expect(result.achievedWeight, 20);
    expect(result.remainder, -5);
    expect(result.platesPerSide, isEmpty);
  });

  test('target equals bar weight is bar-only exact', () {
    final result = calc.calculate(
      targetWeight: 20,
      barWeight: 20,
      denominations: [20, 10, 5],
    );
    expect(result.isExact, isTrue);
    expect(result.isBarOnly, isTrue);
    expect(result.platesPerSide, isEmpty);
    expect(result.achievedWeight, 20);
  });

  test('invalid target weight throws', () {
    expect(
      () => calc.calculate(targetWeight: 0, barWeight: 20, denominations: [10]),
      throwsArgumentError,
    );
    expect(
      () =>
          calc.calculate(targetWeight: -5, barWeight: 20, denominations: [10]),
      throwsArgumentError,
    );
    expect(
      () => calc.calculate(
        targetWeight: double.nan,
        barWeight: 20,
        denominations: [10],
      ),
      throwsArgumentError,
    );
  });

  test('invalid bar weight throws', () {
    expect(
      () => calc.calculate(
        targetWeight: 60,
        barWeight: double.negativeInfinity,
        denominations: [10],
      ),
      throwsArgumentError,
    );
    expect(
      () =>
          calc.calculate(targetWeight: 60, barWeight: -1, denominations: [10]),
      throwsArgumentError,
    );
  });

  test('empty or invalid denominations throw', () {
    expect(
      () => calc.calculate(targetWeight: 60, barWeight: 20, denominations: []),
      throwsArgumentError,
    );
    expect(
      () => calc.calculate(
        targetWeight: 60,
        barWeight: 20,
        denominations: [0, -5],
      ),
      throwsArgumentError,
    );
    expect(
      () => calc.calculate(
        targetWeight: 60,
        barWeight: 20,
        denominations: [double.nan],
      ),
      throwsArgumentError,
    );
  });

  test('denominations are sorted largest-first regardless of input order', () {
    final a = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [1.25, 20, 5, 10, 2.5],
    );
    final b = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [20, 10, 5, 2.5, 1.25],
    );
    expect(a, b);
  });

  test('duplicate denominations are deduplicated', () {
    final a = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [20, 20, 10, 10],
    );
    final b = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [20, 10],
    );
    expect(a, b);
  });

  test('result equality and toString work', () {
    final r1 = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [20, 10],
    );
    final r2 = calc.calculate(
      targetWeight: 60,
      barWeight: 20,
      denominations: [20, 10],
    );
    expect(r1, r2);
    expect(r1.hashCode, r2.hashCode);
    expect(r1.toString(), contains('60'));
    expect(r1.toString(), contains('20'));
  });

  test('diagnostic text reports plate denomination without rounding', () {
    final multiple = calc.calculate(
      targetWeight: 100,
      barWeight: 20,
      denominations: [20],
    );
    final fractional = calc.calculate(
      targetWeight: 22.5,
      barWeight: 20,
      denominations: [1.25],
    );

    expect(multiple.toString(), contains('perSide=2x 20.0kg'));
    expect(fractional.toString(), contains('perSide=1x 1.25kg'));
  });
}
