import 'dart:async';

import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/analytics/presentation/providers/backup_export_providers.dart';
import 'package:app/features/analytics/presentation/screens/data_export_screen.dart';
import 'package:app/ui/candy/candy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _EnglishMode extends LocalizationModeNotifier {
  @override
  AppLangMode build() => AppLangMode.en;
}

class _VietnameseMode extends LocalizationModeNotifier {
  @override
  AppLangMode build() => AppLangMode.vi;
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Future<String> Function() export, {
  bool vietnamese = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localizationModeProvider.overrideWith(
          vietnamese ? _VietnameseMode.new : _EnglishMode.new,
        ),
        backupExportProvider.overrideWith((ref) => export()),
      ],
      child: const MaterialApp(home: DataExportScreen()),
    ),
  );
}

Finder get _backupButton => find.byWidgetPredicate(
  (widget) => widget is CandyButton && widget.label == 'GymLvl backup (JSON)',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> copied;
  late bool failClipboard;
  setUp(() {
    copied = [];
    failClipboard = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            if (failClipboard) {
              throw PlatformException(code: 'clipboard_unavailable');
            }
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('a second backup tap copies a fresh snapshot', (tester) async {
    var snapshot = '{"version":1}';
    var reads = 0;
    await _pumpScreen(tester, () async {
      reads++;
      return snapshot;
    });

    await tester.tap(_backupButton);
    await tester.pumpAndSettle();
    expect(copied, ['{"version":1}']);

    snapshot = '{"version":2}';
    await tester.tap(_backupButton);
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(copied, ['{"version":1}', '{"version":2}']);
  });

  testWidgets('export failure shows an error and does not copy', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      () async => throw StateError('workout_export_incomplete'),
    );

    await tester.tap(_backupButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(copied, isEmpty);
    expect(find.text('Copied to clipboard'), findsNothing);
    expect(find.textContaining('workout_export_incomplete'), findsNothing);
    expect(
      find.textContaining('Could not read all data for the backup.'),
      findsOneWidget,
    );
  });

  testWidgets('loading backup disables repeated export taps', (tester) async {
    final pending = Completer<String>();
    var reads = 0;
    await _pumpScreen(tester, () {
      reads++;
      return pending.future;
    });

    await tester.tap(_backupButton);
    await tester.pump();
    final button = tester.widget<CandyButton>(_backupButton);
    expect(button.isLoading, isTrue);
    expect(button.onPressed, isNull);
    expect(reads, 1);

    pending.complete('{"version":2}');
    await tester.pumpAndSettle();
    expect(copied, ['{"version":2}']);
  });

  testWidgets('backup limitations are visible in English and Vietnamese', (
    tester,
  ) async {
    await _pumpScreen(tester, () async => '{}');
    expect(find.textContaining('Preferences are excluded.'), findsOneWidget);
    expect(find.textContaining('same GymLvl account.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpScreen(tester, () async => '{}', vietnamese: true);
    expect(find.textContaining('Không gồm tùy chọn cá nhân.'), findsOneWidget);
    expect(find.textContaining('cùng tài khoản GymLvl.'), findsOneWidget);
  });

  testWidgets('clipboard failure has visible error and no copied success', (
    tester,
  ) async {
    failClipboard = true;
    await _pumpScreen(tester, () async => '{"version":2}');

    await tester.tap(_backupButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(copied, isEmpty);
    expect(find.text('Copied to clipboard'), findsNothing);
    expect(find.textContaining('Nothing was copied.'), findsOneWidget);
  });
}
