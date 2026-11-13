import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/features/bodyweight/domain/bodyweight_trend.dart';
import 'package:app/features/bodyweight/presentation/providers/bodyweight_providers.dart';
import 'package:app/features/bodyweight/presentation/screens/bodyweight_screen.dart';
import 'package:app/ui/candy/candy_empty_state.dart';
import 'package:app/ui/candy/candy_error_state.dart';
import 'package:app/ui/candy/candy_stat_tile.dart';

List<BodyweightTrendPoint> _points() {
  return [
    BodyweightTrendPoint(date: DateTime(2026, 10, 1), weightKg: 70.0),
    BodyweightTrendPoint(date: DateTime(2026, 10, 2), weightKg: 69.5),
    BodyweightTrendPoint(date: DateTime(2026, 10, 3), weightKg: 70.2),
  ];
}

void main() {
  testWidgets('renders trend chart and latest weigh-in in VI', (
    WidgetTester tester,
  ) async {
    final overrides = [
      bodyweightTrendProvider.overrideWithValue(AsyncData(_points())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: BodyweightScreen()),
      ),
    );

    expect(find.textContaining('TRỌNG LƯỢNG CƠ THỂ'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    // Latest weigh-in (body mass, not external load).
    expect(find.textContaining('Khối cơ thể'), findsOneWidget);
    expect(find.textContaining('kg'), findsOneWidget);
    // Body mass vs external-load note.
    expect(find.textContaining('không phải khối cơ thể'), findsOneWidget);
    expect(find.byType(CandyStatTile), findsOneWidget);
  });

  testWidgets('empty state when no bodyweight data', (
    WidgetTester tester,
  ) async {
    final overrides = [
      bodyweightTrendProvider.overrideWithValue(
        AsyncData(<BodyweightTrendPoint>[]),
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: BodyweightScreen()),
      ),
    );

    expect(find.byType(CandyEmptyState), findsOneWidget);
    expect(
      find.textContaining('Chưa có dữ liệu trọng lượng cơ thể.'),
      findsOneWidget,
    );
  });

  testWidgets('error state', (WidgetTester tester) async {
    final overrides = [
      bodyweightTrendProvider.overrideWithValue(
        AsyncError(Exception('Mạng bị gián đoạn'), StackTrace.empty),
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: BodyweightScreen()),
      ),
    );

    expect(find.byType(CandyErrorState), findsOneWidget);
    expect(find.textContaining('LỖI'), findsOneWidget);
  });

  testWidgets('loading state', (WidgetTester tester) async {
    final overrides = [
      bodyweightTrendProvider.overrideWithValue(const AsyncLoading()),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: BodyweightScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Đang tải...'), findsOneWidget);
  });

  testWidgets('usable at 320 dp narrow width', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    final overrides = [
      bodyweightTrendProvider.overrideWithValue(AsyncData(_points())),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: BodyweightScreen()),
      ),
    );

    expect(find.textContaining('TRỌNG LƯỢNG CƠ THỂ'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(CandyStatTile), findsOneWidget);
  });
}
