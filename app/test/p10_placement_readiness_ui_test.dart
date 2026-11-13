import 'package:app/features/placement/domain/placement_models.dart';
import 'package:app/features/placement/presentation/placement_readiness_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('confirmed card labels readiness separately from earned RPG', (
    tester,
  ) async {
    const state = PlacementState(
      status: 'confirmed',
      assessedClassId: 'A',
      readinessClassLevel: 4,
      readinessGlobalLevel: 5,
      readinessXpToNextGlobalLevel: 318,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlacementReadinessCard(
            state: state,
            earnedGlobalLevel: 2,
            earnedClassLevel: 1,
          ),
        ),
      ),
    );

    expect(find.text('TRAINING READINESS'), findsOneWidget);
    expect(find.text('Confirmed training readiness'), findsOneWidget);
    expect(find.text('Earned RPG'), findsOneWidget);
    expect(find.text('Global 2 · Class 1'), findsOneWidget);
    expect(find.textContaining('318'), findsOneWidget);
    expect(find.textContaining('level up'), findsNothing);
    expect(find.textContaining('XP awarded'), findsNothing);
  });

  testWidgets(
    'Vietnamese unassessed state is accessible and does not invent levels',
    (tester) async {
      const state = PlacementState(status: 'unassessed');
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlacementReadinessCard(state: state, isVietnamese: true),
          ),
        ),
      );

      expect(find.text('READINESS TẬP LUYỆN'), findsOneWidget);
      expect(find.text('Chưa đánh giá readiness tập luyện'), findsOneWidget);
      expect(find.text('Readiness lớp'), findsNothing);
      final semantics = tester.getSemantics(
        find.byType(PlacementReadinessCard),
      );
      expect(semantics.label, contains('readiness'));
    },
  );
}
