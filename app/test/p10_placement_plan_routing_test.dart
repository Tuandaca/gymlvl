import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/training_plan/presentation/newcomer_journey_screen.dart';
import 'package:app/features/training_plan/presentation/providers/training_plan_providers.dart';
import 'package:app/features/training_plan/routine_models.dart';
import 'package:app/features/training_plan/routine_providers.dart' as routines;
import 'package:app/features/training_plan/presentation/screens/routine_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpEntry(
    WidgetTester tester, {
    required String? experience,
    int completed = 0,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWithValue('test-user'),
          currentUserProfileProvider.overrideWith(
            (ref) async => experience == null
                ? null
                : <String, dynamic>{'experience_level': experience},
          ),
          completedWorkoutCountProvider.overrideWith((ref) async => completed),
          routines.routinesProvider.overrideWith((ref) async => <Routine>[]),
        ],
        child: const MaterialApp(home: PlanEntryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('experienced users enter existing routine selector', (
    tester,
  ) async {
    await pumpEntry(tester, experience: 'intermediate');
    expect(find.byType(RoutineListScreen), findsOneWidget);
    expect(find.byType(NewcomerJourneyScreen), findsNothing);
  });

  testWidgets('beginner with no history enters newcomer journey', (
    tester,
  ) async {
    await pumpEntry(tester, experience: 'beginner');
    expect(find.byType(NewcomerJourneyScreen), findsOneWidget);
    expect(find.byType(RoutineListScreen), findsNothing);
  });

  testWidgets('returning beginner enters existing routine selector', (
    tester,
  ) async {
    await pumpEntry(tester, experience: 'beginner', completed: 1);
    expect(find.byType(RoutineListScreen), findsOneWidget);
    expect(find.byType(NewcomerJourneyScreen), findsNothing);
  });
}
