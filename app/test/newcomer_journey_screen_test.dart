import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/training_plan/presentation/newcomer_journey_screen.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/training_plan/newcomer_journey_models.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:app/ui/candy/candy_button.dart';
import 'package:app/ui/candy/candy_card.dart';
import 'package:app/ui/candy/candy_empty_state.dart';
import 'package:app/ui/candy/candy_error_state.dart';

PlannedExercise _ex(
  String id,
  String name,
  String category,
  WorkoutMode mode,
  double weight,
) {
  return PlannedExercise(
    exerciseId: id,
    exerciseName: name,
    category: category,
    mode: mode,
    sets: 3,
    reps: 10,
    starterWeightKg: weight,
    orderIndex: 0,
  );
}

FirstWeekPlan _plan() {
  List<PlannedExercise> dayExercises(WorkoutMode m, double w) => [
    _ex('e1', 'Push-up', 'Chest', m, w),
    _ex('e2', 'Squat', 'Legs', WorkoutMode.repsWeight, w),
    _ex('e3', 'Row', 'Back', WorkoutMode.repsWeight, w),
  ];
  return FirstWeekPlan(
    userId: 'u1',
    days: [
      PlanDay(
        dayNumber: 1,
        dayName: 'Ngày 1',
        exercises: dayExercises(WorkoutMode.bodyweight, 0.0),
      ),
      PlanDay(
        dayNumber: 2,
        dayName: 'Ngày 2',
        exercises: dayExercises(WorkoutMode.repsWeight, 5.0),
      ),
      PlanDay(
        dayNumber: 3,
        dayName: 'Ngày 3',
        exercises: dayExercises(WorkoutMode.repsWeight, 5.0),
      ),
    ],
  );
}

Future<void> _pump(NewcomerJourneyScreen screen, WidgetTester tester) async {
  await tester.pumpWidget(ProviderScope(child: MaterialApp(home: screen)));
}

void main() {
  testWidgets('renders journey state, 3 days x 3 exercises in VI', (
    WidgetTester tester,
  ) async {
    await _pump(
      NewcomerJourneyScreen(state: const PlanAvailable(), plan: _plan()),
      tester,
    );

    // Plan title.
    expect(find.textContaining('KẾ HOẠ ĐẦU TUẦN'), findsOneWidget);
    // Journey state label.
    expect(find.textContaining('Kế hoạch sẵn sàng'), findsOneWidget);
    // 3 day headers.
    expect(find.text('Ngày 1'), findsOneWidget);
    expect(find.text('Ngày 2'), findsOneWidget);
    expect(find.text('Ngày 3'), findsOneWidget);
    // 3 x 3 exercise cards.
    expect(find.byType(CandyCard), findsAtLeastNWidgets(10));
    // Exercise names (appear once per day).
    expect(find.text('Push-up'), findsAtLeastNWidgets(1));
    expect(find.text('Squat'), findsAtLeastNWidgets(1));
    expect(find.text('Row'), findsAtLeastNWidgets(1));
    // Mode badges.
    expect(find.textContaining('Tự trọng'), findsOneWidget);
    expect(find.textContaining('Trọng lượng'), findsAtLeastNWidgets(1));
    // Sets x reps + weight chips.
    expect(find.text('Số Rep'), findsAtLeastNWidgets(1));
    expect(find.text('Số set'), findsAtLeastNWidgets(1));
    expect(find.textContaining('kg'), findsAtLeastNWidgets(1));
  });

  testWidgets('bodyweight shows added load, reps-weight shows starter weight', (
    WidgetTester tester,
  ) async {
    await _pump(
      NewcomerJourneyScreen(state: const PlanAvailable(), plan: _plan()),
      tester,
    );

    // Bodyweight exercise: added load label + value.
    expect(find.textContaining('Tạ thêm'), findsAtLeastNWidgets(1));
    // Reps-weight exercise: starter weight shown as kg.
    expect(find.textContaining('kg'), findsAtLeastNWidgets(1));

    // Bodyweight reference note (added load, not body mass).
    expect(find.textContaining('không phải khối cơ thể'), findsOneWidget);
  });

  testWidgets('workout start is gated behind journey outcome flags', (
    WidgetTester tester,
  ) async {
    var startCalls = 0;
    var continueCalls = 0;

    // Plan available but not opened: "Open plan" (planOpened, no side effect).
    await _pump(
      NewcomerJourneyScreen(
        state: const PlanAvailable(),
        plan: _plan(),
        onStartWorkout: () => startCalls++,
      ),
      tester,
    );
    expect(find.textContaining('Mở kế hoạch'), findsOneWidget);
    expect(find.textContaining('BẮT ĐẦU TẬP'), findsNothing);
    await tester.scrollUntilVisible(find.textContaining('Mở kế hoạch'), 500.0);
    await tester.tap(find.textContaining('Mở kế hoạch').first);
    await tester.pump();
    expect(startCalls, 0);

    // Plan opened: "Start workout" triggers workoutStarted -> workoutCreated.
    await _pump(
      NewcomerJourneyScreen(
        state: const PlanStarted(),
        plan: _plan(),
        onStartWorkout: () => startCalls++,
      ),
      tester,
    );
    expect(find.textContaining('BẮT ĐẦU TẬP'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('BẮT ĐẦU TẬP'), 500.0);
    await tester.tap(find.textContaining('BẮT ĐẦU TẬP').first);
    await tester.pump();
    expect(startCalls, 1);

    // State advanced to WorkoutPartial: start gone, continue shown.
    await _pump(
      NewcomerJourneyScreen(
        state: const WorkoutPartial(),
        plan: _plan(),
        onContinueWorkout: () => continueCalls++,
      ),
      tester,
    );
    expect(find.textContaining('BẮT ĐẦU TẬP'), findsNothing);
    expect(find.textContaining('Tiếp tục'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Tiếp tục'), 500.0);
    await tester.tap(find.textContaining('Tiếp tục').first);
    await tester.pump();
    expect(continueCalls, 1);
  });

  testWidgets('primary buttons are >= 48dp touch targets', (
    WidgetTester tester,
  ) async {
    await _pump(
      NewcomerJourneyScreen(state: const PlanAvailable(), plan: _plan()),
      tester,
    );

    final button = find.byType(CandyButton).first;
    final size = tester.getSize(button);
    expect(size.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('semantics label on open-plan button', (
    WidgetTester tester,
  ) async {
    await _pump(
      NewcomerJourneyScreen(state: const PlanAvailable(), plan: _plan()),
      tester,
    );

    final button = find.byType(CandyButton).first;
    expect(button, findsOneWidget);
    await tester.scrollUntilVisible(button, 500.0);
    final semantics = tester.getSemantics(button);
    expect(semantics.label, contains('Mở kế hoạch'));
  });

  testWidgets('empty state when no plan', (WidgetTester tester) async {
    await _pump(
      const NewcomerJourneyScreen(state: NoHistory(), plan: null),
      tester,
    );

    expect(find.byType(CandyEmptyState), findsOneWidget);
    expect(find.textContaining('Chưa có hồ sơ'), findsOneWidget);
    expect(find.textContaining('Chưa có kế hoạch tập.'), findsOneWidget);
  });

  testWidgets('error state with retry', (WidgetTester tester) async {
    var retryCalls = 0;
    await _pump(
      NewcomerJourneyScreen(
        state: const PlanAvailable(),
        plan: _plan(),
        error: 'Mạng bị gián đoạn',
        onRetry: () => retryCalls++,
      ),
      tester,
    );

    expect(find.byType(CandyErrorState), findsOneWidget);
    expect(find.textContaining('LỖI'), findsOneWidget);
    expect(find.textContaining('Mạng bị gián đoạn'), findsOneWidget);
    expect(find.textContaining('Thử lại'), findsOneWidget);
    await tester.tap(find.textContaining('Thử lại').first);
    await tester.pump();
    expect(retryCalls, 1);
  });

  testWidgets('loading state', (WidgetTester tester) async {
    await _pump(
      const NewcomerJourneyScreen(
        state: PlanAvailable(),
        plan: null,
        isLoading: true,
      ),
      tester,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Đang tải...'), findsOneWidget);
  });

  testWidgets('usable at 320 dp narrow width', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    await _pump(
      NewcomerJourneyScreen(state: const PlanAvailable(), plan: _plan()),
      tester,
    );

    expect(find.textContaining('KẾ HOẠ ĐẦU TUẦN'), findsOneWidget);
    expect(find.byType(CandyButton), findsOneWidget);
    expect(find.text('Ngày 1'), findsOneWidget);
    expect(find.text('Ngày 3'), findsOneWidget);
  });
}
