// FND-BUG-005: the dashboard KPI tiles are fed windowed values — the volume
// trend covers seven days and the workout/set counts cover at most the three
// most recent sessions. Every such tile must name its window instead of
// claiming a lifetime total, in both languages.
import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/dashboard/presentation/widgets/kpi_tiles_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedLanguage extends LocalizationModeNotifier {
  _FixedLanguage(this.mode);
  final AppLangMode mode;
  @override
  AppLangMode build() => mode;
}

Future<void> _pumpGrid(
  WidgetTester tester,
  AppLangMode language, {
  double width = 390,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localizationModeProvider.overrideWith(() => _FixedLanguage(language)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KpiTilesGrid(
              totalVolume: 12500,
              totalWorkouts: 3,
              totalSets: 12,
              currentStreak: 5,
              longestStreak: 9,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('english tiles name their aggregation windows', (tester) async {
    await _pumpGrid(tester, AppLangMode.en);

    expect(find.text('VOLUME'), findsOneWidget);
    expect(find.text('WORKOUTS'), findsOneWidget);
    expect(find.text('SETS'), findsOneWidget);
    expect(find.text('STREAK'), findsOneWidget);
    expect(find.text('last 7 days'), findsOneWidget);
    expect(find.text('last 3 workouts'), findsNWidgets(2));

    // The regression: no tile may claim a lifetime total while showing a window.
    expect(find.textContaining('TOTAL'), findsNothing);

    // Values still come from the caller untouched.
    expect(find.text('12.5'), findsOneWidget);
    expect(find.text('t'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('vietnamese tiles name their aggregation windows', (
    tester,
  ) async {
    await _pumpGrid(tester, AppLangMode.vi);

    expect(find.text('KHỐI LƯỢNG'), findsOneWidget);
    expect(find.text('BUỔI TẬP'), findsOneWidget);
    expect(find.text('SỐ HIỆP'), findsOneWidget);
    expect(find.text('CHUỖI TẬP'), findsOneWidget);
    expect(find.text('7 ngày gần nhất'), findsOneWidget);
    expect(find.text('3 buổi gần nhất'), findsNWidgets(2));
    expect(find.textContaining('TỔNG'), findsNothing);
  });

  testWidgets('window labels and values survive a 320 px viewport', (
    tester,
  ) async {
    await _pumpGrid(tester, AppLangMode.en, width: 320);

    expect(tester.takeException(), isNull);
    expect(find.text('last 7 days'), findsOneWidget);
    expect(find.text('last 3 workouts'), findsNWidgets(2));
    // Longest supported streak subtitle still renders.
    expect(find.text('Best: 9 days'), findsOneWidget);
  });
}
