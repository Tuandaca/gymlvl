import 'package:app/ui/candy/candy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double _borderWidth(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.byType(AnimatedContainer),
  );
  final decoration = container.decoration! as BoxDecoration;
  return (decoration.border! as Border).top.width;
}

void main() {
  testWidgets('CandyButton is keyboard focusable and activates once', (
    tester,
  ) async {
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CandyButton(
              label: 'Continue',
              isFullWidth: false,
              onPressed: () => activations++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_borderWidth(tester), 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    expect(
      FocusManager.instance.primaryFocus?.hasFocus,
      isTrue,
      reason: 'Tab must reach the enabled CandyButton',
    );
    expect(
      _borderWidth(tester),
      3,
      reason: 'Focused buttons need a visible focus indicator',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(activations, 2);

    await tester.tap(find.byType(CandyButton));
    await tester.pumpAndSettle();
    expect(activations, 3, reason: 'Pointer activation must still work');
  });

  testWidgets('a disabled CandyButton is skipped in focus traversal', (
    tester,
  ) async {
    var enabledActivations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CandyButton(label: 'Disabled', onPressed: null),
                CandyButton(
                  label: 'Enabled',
                  onPressed: () => enabledActivations++,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final widths = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map(
          (container) =>
              ((container.decoration! as BoxDecoration).border! as Border)
                  .top
                  .width,
        )
        .toList();
    expect(widths, [2, 3], reason: 'Focus must land on the enabled button');

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(enabledActivations, 1);
  });
}
