import 'package:app/features/progression/presentation/providers/player_progression_provider.dart';
import 'package:app/features/progression/presentation/providers/player_progression_view_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProgressionStub extends PlayerProgressionController {
  @override
  Future<Map<String, dynamic>?> build() async => {
    'userId': 'owner-a',
    'level': 5,
    'totalXP': 1000,
    'classes': [
      {
        'classId': 'A',
        'className': 'Primary',
        'slot': 'primary',
        'currentXP': 200,
        'level': 1,
        'isGraduated': false,
        'xpBase': 80,
        'xpSlope': 1.4,
      },
      {
        'classId': 'B',
        'className': 'Secondary',
        'slot': 'secondary',
        'currentXP': 300,
        'level': 2,
        'isGraduated': false,
        'xpBase': 100,
        'xpSlope': 1.45,
      },
    ],
  };
}

class _GraduatedStub extends _ProgressionStub {
  @override
  Future<Map<String, dynamic>?> build() async {
    final data = (await super.build())!;
    final primary = (data['classes'] as List).first as Map<String, dynamic>;
    primary['currentXP'] = 6000;
    primary['level'] = 20;
    primary['isGraduated'] = true;
    return data;
  }
}

void main() {
  test('next class level subtracts primary class XP, not global XP', () async {
    final container = ProviderContainer(
      overrides: [
        playerProgressionControllerProvider.overrideWith(_ProgressionStub.new),
      ],
    );
    addTearDown(container.dispose);

    final view = await container.read(playerProgressionViewProvider.future);
    expect(view, isNotNull);
    expect(view!.totalXP, 1000);
    expect(view.xpToNextLevel, 11); // floor(80 * 2^1.4) - 200
  });

  test('graduated primary has no next class level', () async {
    final container = ProviderContainer(
      overrides: [
        playerProgressionControllerProvider.overrideWith(_GraduatedStub.new),
      ],
    );
    addTearDown(container.dispose);

    final view = await container.read(playerProgressionViewProvider.future);
    expect(view!.xpToNextLevel, 0);
  });
}
