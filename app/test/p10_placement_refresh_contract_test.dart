import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placement readiness is invalidated after every dashboard-facing mutation', () {
    final onboarding = File(
      'lib/features/onboarding/presentation/providers/onboarding_controller.dart',
    ).readAsStringSync();
    final classes = File(
      'lib/features/dashboard/presentation/providers/class_providers.dart',
    ).readAsStringSync();
    final dashboard = File(
      'lib/features/dashboard/presentation/screens/dashboard_screen.dart',
    ).readAsStringSync();

    expect(onboarding, contains('ref.invalidate(placementStateProvider);'));
    expect(classes, contains('ref.invalidate(placementStateProvider);'));
    expect(dashboard, contains('ref.invalidate(placementStateProvider);'));
  });
}
