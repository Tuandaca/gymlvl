import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('missing configuration gives actionable setup instructions', (
    tester,
  ) async {
    await tester.pumpWidget(const ConfigurationApp());
    expect(find.text('GYMLEVEL'), findsOneWidget);
    expect(find.textContaining('Configure Supabase to begin.'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data!.contains('--dart-define-from-file=config.local.json'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('configuration failure remains usable on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ConfigurationApp(initializationFailed: true));
    expect(
      find.textContaining('Could not initialize the connection.'),
      findsOneWidget,
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
