import 'package:app/features/bodyweight/domain/bodyweight_measurement.dart';
import 'package:app/features/bodyweight/domain/bodyweight_trend.dart';
import 'package:flutter_test/flutter_test.dart';

final kUserId = 'user-11111111-1111-1111-1111-111111111111';

BodyweightMeasurement m(
  String id,
  double weightKg, {
  int year = 2026,
  int month = 11,
  required int day,
  BodyweightSource source = BodyweightSource.manualWeighIn,
}) {
  final measuredAt = DateTime.utc(year, month, day, 8, 0, 0);
  return BodyweightMeasurement(
    id: id,
    userId: kUserId,
    weightKg: weightKg,
    measuredAt: measuredAt,
    source: source,
  );
}

void main() {
  group('BodyweightTrend empty history', () {
    test('all aggregates are null and points is empty', () {
      final trend = BodyweightTrend([]);

      expect(trend.points, isEmpty);
      expect(trend.first, isNull);
      expect(trend.last, isNull);
      expect(trend.totalChangeKg, isNull);
      expect(trend.averageWeightKg, isNull);
      expect(trend.minWeightKg, isNull);
      expect(trend.maxWeightKg, isNull);
      expect(trend.direction, TrendDirection.stable);
      expect(trend.changeInLastDays(30), isNull);
    });
  });

  group('single measurement', () {
    test('first and last are the same; no net change', () {
      final trend = BodyweightTrend([
        m('m1', 75.0, day: 1),
      ]);

      expect(trend.first?.weightKg, 75.0);
      expect(trend.last?.weightKg, 75.0);
      expect(trend.totalChangeKg, isNull);
      expect(trend.averageWeightKg, 75.0);
      expect(trend.minWeightKg, 75.0);
      expect(trend.maxWeightKg, 75.0);
      expect(trend.direction, TrendDirection.stable);
    });
  });

  group('multiple measurements sorted ascending', () {
    test('sorts unsorted input by measuredAt', () {
      final trend = BodyweightTrend([
        m('m3', 78.0, day: 3),
        m('m1', 75.0, day: 1),
        m('m2', 77.0, day: 2),
      ]);

      final dates = trend.points.map((p) => p.date).toList();
      expect(dates, [
        DateTime.utc(2026, 11, 1, 8, 0, 0),
        DateTime.utc(2026, 11, 2, 8, 0, 0),
        DateTime.utc(2026, 11, 3, 8, 0, 0),
      ]);
      expect(trend.first?.weightKg, 75.0);
      expect(trend.last?.weightKg, 78.0);
    });

    test('computes total change, average, min, max', () {
      final trend = BodyweightTrend([
        m('m1', 75.0, day: 1),
        m('m2', 77.0, day: 2),
        m('m3', 76.0, day: 3),
      ]);

      expect(trend.totalChangeKg, 76.0 - 75.0); // +1.0
      expect(trend.averageWeightKg, closeTo((75 + 77 + 76) / 3, 0.001));
      expect(trend.minWeightKg, 75.0);
      expect(trend.maxWeightKg, 77.0);
    });

    test('direction up when net change exceeds threshold', () {
      final trend = BodyweightTrend([
        m('m1', 70.0, day: 1),
        m('m2', 72.0, day: 2),
      ]);
      expect(trend.direction, TrendDirection.up);
      expect(trend.totalChangeKg, 2.0);
    });

    test('direction down when net change exceeds negative threshold', () {
      final trend = BodyweightTrend([
        m('m1', 80.0, day: 1),
        m('m2', 77.0, day: 2),
      ]);
      expect(trend.direction, TrendDirection.down);
      expect(trend.totalChangeKg, -3.0);
    });

    test('direction stable when change is within threshold', () {
      final trend = BodyweightTrend([
        m('m1', 75.0, day: 1),
        m('m2', 75.3, day: 2),
      ]);
      expect(trend.direction, TrendDirection.stable);
      expect(trend.totalChangeKg, closeTo(0.3, 0.001));
    });
  });

  group('changeInLastDays', () {
    test('computes change within a window', () {
      final trend = BodyweightTrend([
        m('m1', 70.0, day: 6),
        m('m2', 72.0, day: 8),
        m('m3', 75.0, day: 10),
      ]);
      final ref = DateTime.utc(2026, 11, 10);
      expect(trend.changeInLastDays(5, reference: ref), 75.0 - 70.0); // +5.0
    });

    test('null when fewer than two points in window', () {
      final trend = BodyweightTrend([
        m('m1', 70.0, day: 1),
        m('m2', 72.0, day: 10),
      ]);
      final ref = DateTime.utc(2026, 11, 10);
      expect(trend.changeInLastDays(5, reference: ref), isNull);
    });
  });

  group('toChartPoints', () {
    test('returns points aligned with measurements', () {
      final trend = BodyweightTrend([
        m('m1', 75.0, day: 1),
        m('m2', 77.0, day: 2),
      ]);
      final points = trend.toChartPoints();
      expect(points.length, 2);
      expect(points[0].weightKg, 75.0);
      expect(points[1].weightKg, 77.0);
    });
  });
}
