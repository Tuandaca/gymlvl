import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/training_plan/newcomer_journey_models.dart';
import 'package:app/features/training_plan/presentation/providers/training_plan_providers.dart';
import 'package:app/features/training_plan/presentation/screens/first_week_plan_screen.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:app/ui/candy/candy_button.dart';
import 'package:app/ui/candy/candy_empty_state.dart';
import 'package:app/ui/candy/candy_error_state.dart';

FirstWeekPlan _plan() {
  return FirstWeekPlan(
    userId: 'user_1',
    days: [
      PlanDay(
        dayNumber: 1,
        dayName: 'Ngày 1',
        exercises: [
          PlannedExercise(
            exerciseId: 'e1',
            exerciseName: 'Push-up',
            category: 'Chest',
            mode: WorkoutMode.bodyweight,
            sets: 3,
            reps: 10,
            starterWeightKg: 0.0,
            orderIndex: 0,
          ),
          PlannedExercise(
            exerciseId: 'e2',
            exerciseName: 'Squat',
            category: 'Legs',
            mode: WorkoutMode.repsWeight,
            sets: 3,
            reps: 10,
            starterWeightKg: 5.0,
            orderIndex: 1,
          ),
          PlannedExercise(
            exerciseId: 'e3',
            exerciseName: 'Row',
            category: 'Back',
            mode: WorkoutMode.repsWeight,
            sets: 3,
            reps: 10,
            starterWeightKg: 5.0,
            orderIndex: 2,
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('renders plan days and exercises in VI', (
    WidgetTester tester,
  ) async {
    final overrides = [
      firstWeekPlanProvider.overrideWithValue(AsyncData(_plan())),
      newcomerJourneyProvider.overrideWithValue(AsyncData(PlanAvailable())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: FirstWeekPlanScreen()),
      ),
    );

    expect(find.textContaining('KẾ HOẠ ĐẦU TUẦN'), findsOneWidget);
    expect(find.textContaining('Kế hoạch sẵn sàng'), findsOneWidget);
    expect(find.text('Ngày 1'), findsOneWidget);
    expect(find.text('Push-up'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
    expect(find.textContaining('Tự trọng'), findsOneWidget);
    expect(find.textContaining('Trọng lượng'), findsAtLeastNWidgets(1));
    expect(find.text('10'), findsAtLeastNWidgets(1));
    expect(find.text('3'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Tạ thêm'), findsAtLeastNWidgets(1));
  });

  testWidgets('empty state when plan is empty (returning user)', (
    WidgetTester tester,
  ) async {
    final overrides = [
      firstWeekPlanProvider.overrideWithValue(
        AsyncData(FirstWeekPlan.empty('user_1')),
      ),
      newcomerJourneyProvider.overrideWithValue(AsyncData(ReturningUser())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: FirstWeekPlanScreen()),
      ),
    );

    expect(find.byType(CandyEmptyState), findsOneWidget);
    expect(find.textContaining('Người dùng cũ'), findsOneWidget);
    expect(find.textContaining('Chưa có kế hoạch tập.'), findsOneWidget);
  });

  testWidgets('error state with retry', (WidgetTester tester) async {
    var retryCalls = 0;
    final overrides = [
      firstWeekPlanProvider.overrideWithValue(
        AsyncError(Exception('Mạng bị gián đoạn'), StackTrace.empty),
      ),
      newcomerJourneyProvider.overrideWithValue(AsyncData(PlanAvailable())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: FirstWeekPlanScreen(onRetry: () => retryCalls++),
        ),
      ),
    );

    expect(find.byType(CandyErrorState), findsOneWidget);
    expect(find.textContaining('LỖI'), findsOneWidget);
    expect(find.textContaining('Thử lại'), findsOneWidget);
    await tester.tap(find.textContaining('Thử lại').first);
    await tester.pump();
    expect(retryCalls, 1);
  });

  testWidgets('loading state', (WidgetTester tester) async {
    final overrides = [
      firstWeekPlanProvider.overrideWithValue(const AsyncLoading()),
      newcomerJourneyProvider.overrideWithValue(const AsyncLoading()),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: FirstWeekPlanScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Đang tải...'), findsOneWidget);
  });

  testWidgets('start button is >= 48dp touch target', (
    WidgetTester tester,
  ) async {
    final overrides = [
      firstWeekPlanProvider.overrideWithValue(AsyncData(_plan())),
      newcomerJourneyProvider.overrideWithValue(AsyncData(PlanStarted())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: FirstWeekPlanScreen()),
      ),
    );

    final button = find.byType(CandyButton).first;
    final size = tester.getSize(button);
    expect(size.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('usable at 320 dp narrow width', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    final overrides = [
      firstWeekPlanProvider.overrideWithValue(AsyncData(_plan())),
      newcomerJourneyProvider.overrideWithValue(AsyncData(PlanAvailable())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: FirstWeekPlanScreen()),
      ),
    );

    expect(find.textContaining('KẾ HOẠ ĐẦU TUẦN'), findsOneWidget);
    expect(find.text('Ngày 1'), findsOneWidget);
    expect(find.byType(CandyButton), findsOneWidget);
  });
}
