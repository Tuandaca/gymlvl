import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/features/analytics/domain/analytics_models.dart';
import 'package:app/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:app/features/analytics/presentation/analytics_screen.dart';
import 'package:app/ui/candy/candy_empty_state.dart';
import 'package:app/ui/candy/candy_error_state.dart';
import 'package:app/ui/candy/candy_stat_tile.dart';

AnalyticsResult _result() {
  return AnalyticsResult(
    heatmap: [
      HeatmapPoint(date: DateTime(2026, 10, 1), workoutCount: 2),
      HeatmapPoint(date: DateTime(2026, 10, 2), workoutCount: 1),
    ],
    weightTrend: [
      WeightTrendPoint(
        date: DateTime(2026, 10, 1),
        volumeKg: 100.0,
        totalReps: 20,
        totalSets: 5,
      ),
      WeightTrendPoint(
        date: DateTime(2026, 10, 2),
        volumeKg: 150.0,
        totalReps: 30,
        totalSets: 7,
      ),
    ],
    prChart: [
      PRChartPoint(
        exerciseId: 'e1',
        exerciseName: 'Push-up',
        maxWeightKg: 50.0,
        maxReps: 15,
        estimated1rm: 75.0,
        updatedAt: DateTime(2026, 10, 1),
      ),
    ],
    muscleBalance: [
      MuscleBalancePoint(
        category: 'Chest',
        volumeKg: 100.0,
        totalReps: 20,
        totalSets: 5,
        percent: 60.0,
      ),
      MuscleBalancePoint(
        category: 'Legs',
        volumeKg: 66.67,
        totalReps: 13,
        totalSets: 3,
        percent: 40.0,
      ),
    ],
  );
}

void main() {
  testWidgets('renders all four analytics sections in VI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AnalyticsScreen(result: _result()),
        ),
      ),
    );

    expect(find.textContaining('PHÂN TÍCH'), findsOneWidget);
    expect(find.textContaining('TẦN SUẤT TẬP'), findsOneWidget);
    expect(find.textContaining('XU HƯỚNG TỔNG TẠ'), findsOneWidget);
    expect(find.textContaining('BẢNG KÍ NHÂN CAO'), findsOneWidget);
    expect(find.textContaining('PHÂN BỐ NHÓM CƠ'), findsOneWidget);

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);

    expect(find.byType(CandyStatTile), findsAtLeastNWidgets(2));
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);
  });

  testWidgets('provider integration shows real data', (WidgetTester tester) async {
    final overrides = [
      analyticsProvider.overrideWithValue(AsyncData(_result())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: AnalyticsScreen()),
      ),
    );

    expect(find.textContaining('PHÂN TÍCH'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('empty state when all lists empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AnalyticsScreen(
            result: AnalyticsResult(
              heatmap: [],
              weightTrend: [],
              prChart: [],
              muscleBalance: [],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CandyEmptyState), findsOneWidget);
    expect(find.textContaining('Chưa có hồ sơ dữ liệu.'), findsOneWidget);
    expect(find.textContaining('Chưa có dữ liệu tập luyện để hiển thị.'),
        findsOneWidget);
  });

  testWidgets('error state with retry', (WidgetTester tester) async {
    var retryCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AnalyticsScreen(
            result: _result(),
            error: 'Mạng bị gián đoạn',
            onRetry: () => retryCalls++,
          ),
        ),
      ),
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
    final overrides = [
      analyticsProvider.overrideWithValue(const AsyncLoading()),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: AnalyticsScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Đang tải...'), findsOneWidget);
  });

  testWidgets('usable at 320 dp narrow width', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AnalyticsScreen(result: _result())),
      ),
    );

    expect(find.textContaining('PHÂN TÍCH'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.byType(CandyStatTile), findsAtLeastNWidgets(1));
  });
}
