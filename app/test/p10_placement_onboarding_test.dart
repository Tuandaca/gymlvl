import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/placement/data/supabase_placement_repository.dart';
import 'package:app/features/placement/domain/placement_models.dart';

void main() {
  test('operation id is a canonical UUID v4', () {
    final id = newPlacementOperationId();
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(id),
      isTrue,
    );
  });

  test('never trained and skipped submissions omit anchors', () {
    final input = PlacementInput(
      classId: 'A',
      hasTrainingExperience: false,
      skip: true,
      anchors: [const PlacementAnchor(exerciseId: 'ignored')],
    );
    final request = input.toRequest();
    expect(request['anchors'], isEmpty);
    expect(request['hasTrainingExperience'], isFalse);
    expect(request['skip'], isTrue);
  });

  test(
    'experienced onboarding uses explicit skip and never invents performance',
    () {
      final input = PlacementInput(
        classId: 'B',
        hasTrainingExperience: true,
        skip: true,
        age: 30,
        bodyMassKg: 80,
      );
      final request = input.toRequest();
      expect(request['hasTrainingExperience'], isTrue);
      expect(request['skip'], isTrue);
      expect(request['anchors'], isEmpty);
      expect(request.containsKey('level'), isFalse);
      expect(request.containsKey('xp'), isFalse);
    },
  );
}
