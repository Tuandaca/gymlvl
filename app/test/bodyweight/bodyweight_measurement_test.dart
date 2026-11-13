import 'package:app/features/bodyweight/domain/bodyweight_measurement.dart';
import 'package:flutter_test/flutter_test.dart';

final kUserId = 'user-11111111-1111-1111-1111-111111111111';
final kMeasuredAt = DateTime.utc(2026, 11, 1, 8, 0, 0);

BodyweightMeasurement baseline({
  required String id,
  required String userId,
  required double weightKg,
  required DateTime measuredAt,
  BodyweightSource source = BodyweightSource.profileBaseline,
}) => BodyweightMeasurement(
  id: id,
  userId: userId,
  weightKg: weightKg,
  measuredAt: measuredAt,
  source: source,
);

void main() {
  group('BodyweightMeasurement.fromProfile', () {
    test('derives body mass from profile weight only, never from a set', () {
      final profileWeightKg = 70.5;
      final m = BodyweightMeasurement.fromProfile(
        userId: kUserId,
        profileWeightKg: profileWeightKg,
      );

      expect(m.weightKg, profileWeightKg);
      expect(m.source, BodyweightSource.profileBaseline);
      expect(m.isBaseline, isTrue);
      expect(m.userId, kUserId);
    });

    test('uses provided measuredAt when given', () {
      final m = BodyweightMeasurement.fromProfile(
        userId: kUserId,
        profileWeightKg: 80.0,
        measuredAt: kMeasuredAt,
      );
      expect(m.measuredAt, kMeasuredAt);
      expect(m.source, BodyweightSource.profileBaseline);
    });

    test('defaults measuredAt to a deterministic fixture', () {
      final m = BodyweightMeasurement.fromProfile(
        userId: kUserId,
        profileWeightKg: 60.0,
      );
      expect(m.measuredAt, DateTime.utc(2026, 11, 1));
    });
  });

  group('isBaseline', () {
    test('true only for profileBaseline source', () {
      expect(
        baseline(
          id: 'm1',
          userId: kUserId,
          weightKg: 75.0,
          measuredAt: kMeasuredAt,
        ).isBaseline,
        isTrue,
      );
      expect(
        baseline(
          id: 'm1',
          userId: kUserId,
          weightKg: 75.0,
          measuredAt: kMeasuredAt,
          source: BodyweightSource.manualWeighIn,
        ).isBaseline,
        isFalse,
      );
      expect(
        baseline(
          id: 'm1',
          userId: kUserId,
          weightKg: 75.0,
          measuredAt: kMeasuredAt,
          source: BodyweightSource.scale,
        ).isBaseline,
        isFalse,
      );
    });
  });

  group('equality and hashCode', () {
    test('equal measurements have equal hash codes', () {
      final a = baseline(
        id: 'm1',
        userId: kUserId,
        weightKg: 75.0,
        measuredAt: kMeasuredAt,
      );
      final b = baseline(
        id: 'm1',
        userId: kUserId,
        weightKg: 75.0,
        measuredAt: kMeasuredAt,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different weightKg is not equal', () {
      expect(
        baseline(
          id: 'm1',
          userId: kUserId,
          weightKg: 70.0,
          measuredAt: kMeasuredAt,
        ),
        isNot(
          baseline(
            id: 'm1',
            userId: kUserId,
            weightKg: 75.0,
            measuredAt: kMeasuredAt,
          ),
        ),
      );
    });

    test('different source is not equal', () {
      expect(
        baseline(
          id: 'm1',
          userId: kUserId,
          weightKg: 75.0,
          measuredAt: kMeasuredAt,
        ),
        isNot(
          baseline(
            id: 'm1',
            userId: kUserId,
            weightKg: 75.0,
            measuredAt: kMeasuredAt,
            source: BodyweightSource.scale,
          ),
        ),
      );
    });
  });

  group('json round trip', () {
    test('serializes and deserializes without losing weightKg', () {
      final original = baseline(
        id: 'm1',
        userId: kUserId,
        weightKg: 75.0,
        measuredAt: kMeasuredAt,
      );
      final json = original.toJson();
      final restored = BodyweightMeasurement.fromJson(json);

      expect(restored, original);
      expect(restored.weightKg, original.weightKg);
      expect(restored.source, BodyweightSource.profileBaseline);
      expect(json['weight_kg'], original.weightKg);
    });
  });

  group('weightKg is body mass, never external set load', () {
    test('a profile-based measurement carries body mass (75 kg)', () {
      expect(
        baseline(
          id: 'm1',
          userId: kUserId,
          weightKg: 75.0,
          measuredAt: kMeasuredAt,
        ).weightKg,
        75.0,
      );
    });

    test(
      'the same numeric value as a set load is not confused with body mass',
      () {
        final setLoadKg = 20.0; // e.g. weighted vest
        final bodyMassKg = 75.0;

        final measurement = BodyweightMeasurement.fromProfile(
          userId: kUserId,
          profileWeightKg: bodyMassKg,
        );

        expect(measurement.weightKg, bodyMassKg);
        expect(measurement.weightKg, isNot(setLoadKg));
        expect(measurement.isBaseline, isTrue);
      },
    );
  });
}
