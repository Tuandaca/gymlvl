import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/progression/domain/rpg_bridge.dart';
import 'package:app/features/progression/presentation/progression_screen.dart';
import 'package:app/features/progression/presentation/widgets/class_progress_card.dart';
import 'package:app/features/progression/presentation/widgets/exercise_progression_card.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/ui/candy/candy_badge.dart';
import 'package:app/ui/candy/candy_empty_state.dart';
import 'package:app/ui/candy/candy_error_state.dart';

List<WorkoutSet> strengthSets() => [
  WorkoutSet(
    id: 's1',
    workoutExerciseId: 'e1',
    setNumber: 1,
    reps: 10,
    weightKg: 100,
    baselineWeightKg: 0,
    isCompleted: true,
    rpe: 8,
    rir: 2,
  ),
  WorkoutSet(
    id: 's2',
    workoutExerciseId: 'e1',
    setNumber: 2,
    reps: 8,
    weightKg: 105,
    baselineWeightKg: 0,
    isCompleted: true,
    rpe: 9,
    rir: 1,
  ),
];

void main() {
  testWidgets('renders class progress, level bar and per-set 1RM/PR/RPE-RIR', (
    WidgetTester tester,
  ) async {
    final projection = const RPGProjection(
      newXP: 300,
      newLevel: 2,
      leveledUp: true,
      xpToNextLevel: 72,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProgressionScreen(
            projection: projection,
            sets: strengthSets(),
            className: 'Fat Slayer',
            xpBase: 80,
            xpSlope: 1.40,
          ),
        ),
      ),
    );

    // Vietnamese diacritics render correctly.
    expect(find.textContaining('TIẾN ĐỘ TẬP LUYỆN'), findsOneWidget);
    expect(find.textContaining('TIẾN ĐỘ HỆ PHÁI'), findsOneWidget);
    expect(find.textContaining('Cấp độ 2'), findsOneWidget);
    expect(find.textContaining('Fat Slayer'), findsOneWidget);

    // Class progress card present.
    expect(find.byType(ClassProgressCard), findsOneWidget);

    // Stat tiles: level, max 1RM (133.33 -> 133).
    expect(find.text('133'), findsOneWidget);

    // Per-set cards with estimated 1RM and RPE/RIR.
    expect(find.byType(ExerciseProgressionCard), findsNWidgets(2));
    expect(find.textContaining('RPE 8'), findsOneWidget);
    expect(find.textContaining('RIR 2'), findsOneWidget);
    expect(find.textContaining('RPE 9'), findsOneWidget);
    expect(find.textContaining('RIR 1'), findsOneWidget);
    // Both sets are first-record weight PRs (no prior max).
    expect(find.text('PR!'), findsNWidgets(2));

    // Level-up badge shown.
    expect(find.byType(CandyBadge), findsAtLeastNWidgets(1));
  });

  testWidgets('shows empty state when there is no class projection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const ProgressionScreen(
            projection: null,
            className: 'Fat Slayer',
            xpBase: 80,
            xpSlope: 1.40,
          ),
        ),
      ),
    );

    expect(find.byType(CandyEmptyState), findsOneWidget);
    expect(find.textContaining('Chưa có dữ liệu hệ phái.'), findsOneWidget);
  });

  testWidgets('shows error state with retry when load fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProgressionScreen(
            projection: const RPGProjection(
              newXP: 0,
              newLevel: 1,
              leveledUp: false,
              xpToNextLevel: 211,
            ),
            sets: const [],
            className: 'Fat Slayer',
            xpBase: 80,
            xpSlope: 1.40,
            error: 'Mạng bị gián đoạn',
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CandyErrorState), findsOneWidget);
    expect(find.textContaining('LỖI'), findsOneWidget);
    expect(find.textContaining('Mạng bị gián đoạn'), findsOneWidget);
    expect(find.textContaining('Thử lại'), findsOneWidget);
  });

  testWidgets('shows loading state while data is fetched', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const ProgressionScreen(
            projection: null,
            className: 'Fat Slayer',
            xpBase: 80,
            xpSlope: 1.40,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Đang tải...'), findsOneWidget);
  });

  testWidgets('is usable at 320 dp narrow width', (WidgetTester tester) async {
    final projection = const RPGProjection(
      newXP: 300,
      newLevel: 2,
      leveledUp: false,
      xpToNextLevel: 72,
    );

    await tester.binding.setSurfaceSize(const Size(320, 560));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProgressionScreen(
            projection: projection,
            sets: strengthSets(),
            className: 'Fat Slayer',
            xpBase: 80,
            xpSlope: 1.40,
          ),
        ),
      ),
    );

    expect(find.textContaining('TIẾN ĐỘ TẬP LUYỆN'), findsOneWidget);
    expect(find.byType(ClassProgressCard), findsOneWidget);
    expect(find.byType(ExerciseProgressionCard), findsNWidgets(2));
  });
}
