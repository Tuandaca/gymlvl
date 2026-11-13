import 'package:app/features/placement/domain/placement_models.dart';
import 'package:app/features/placement/domain/placement_policy.dart';
import 'package:flutter_test/flutter_test.dart';

const ids = <String, String>{
  'barbell-bench-press': '00000000-0000-4000-8000-000000000001',
  'barbell-squat': '00000000-0000-4000-8000-000000000002',
  'barbell-deadlift': '00000000-0000-4000-8000-000000000003',
  'push-up': '00000000-0000-4000-8000-000000000004',
  'pull-up': '00000000-0000-4000-8000-000000000005',
  'bodyweight-air-squat': '00000000-0000-4000-8000-000000000006',
  'plank': '00000000-0000-4000-8000-000000000007',
};
PlacementAnchor anchor(
  String slug, {
  double load = 0,
  int reps = 0,
  int seconds = 0,
}) => PlacementAnchor(
  exerciseId: ids[slug]!,
  loadKg: load,
  reps: reps,
  durationSeconds: seconds,
);
PlacementInput input({
  String classId = 'E',
  List<PlacementAnchor>? anchors,
  bool trained = true,
  bool skip = false,
  int? age = 30,
  double? mass = 70,
  bool barbell = true,
  bool bar = true,
}) => PlacementInput(
  classId: classId,
  hasTrainingExperience: trained,
  skip: skip,
  age: age,
  bodyMassKg: mass,
  equipment: PlacementEquipment(barbell: barbell, pullUpBar: bar),
  anchors:
      anchors ??
      [
        anchor('pull-up', reps: 4),
        anchor('push-up', reps: 22),
        anchor('plank', seconds: 100),
      ],
);
void main() {
  test('decimal barbell boundary is inclusive without accepting below', () {
    final exact = PlacementPolicy.preview(
      input(
        classId: 'C',
        mass: 72,
        anchors: [
          anchor('barbell-bench-press', load: 24, reps: 6),
          anchor('barbell-squat', load: 90, reps: 6),
        ],
      ),
      ids,
    );
    expect([exact.classLevel, exact.globalLevel], [2, 3]);
    final below = PlacementPolicy.preview(
      input(
        classId: 'C',
        mass: 72,
        anchors: [
          anchor('barbell-bench-press', load: 23.999999999999996, reps: 6),
          anchor('barbell-squat', load: 90, reps: 6),
        ],
      ),
      ids,
    );
    expect(below.classLevel, 1);
  });
  test(
    'bodyweight supplied invalid mass rejects while absent is permitted',
    () {
      for (final mass in [450.0, 19.0, double.nan, double.infinity]) {
        expect(
          () => PlacementPolicy.preview(input(mass: mass), ids),
          throwsArgumentError,
        );
      }
      expect(PlacementPolicy.preview(input(mass: null), ids).classLevel, 4);
    },
  );
  test('C worked example gives class 3 global 5', () {
    final result = PlacementPolicy.preview(
      input(
        classId: 'C',
        anchors: [
          anchor('barbell-squat', load: 70, reps: 8),
          anchor('barbell-bench-press', load: 42.5, reps: 8),
          anchor('barbell-deadlift', load: 80, reps: 6),
        ],
      ),
      ids,
    );
    expect([result.classLevel, result.globalLevel], [3, 5]);
  });
  test('E worked example gives class 4 global 7', () {
    final result = PlacementPolicy.preview(input(), ids);
    expect([result.classLevel, result.globalLevel], [4, 7]);
  });
  const bands = <String, List<double>>{
    'barbell-bench-press': [.4, .6, .8, 1],
    'barbell-squat': [.75, 1, 1.25, 1.5],
    'barbell-deadlift': [.9, 1.2, 1.5, 1.8],
    'push-up': [5, 10, 20, 30],
    'pull-up': [1, 3, 6, 10],
    'bodyweight-air-squat': [10, 20, 30, 40],
    'plank': [30, 60, 90, 120],
  };
  for (final entry in bands.entries) {
    for (var index = 0; index < 4; index++) {
      test('${entry.key} inclusive boundary ${index + 2}', () {
        final barbell = entry.key.startsWith('barbell');
        final metric = entry.value[index];
        // With 6 reps and body mass 120, load is 100 times the ratio.
        final sample = anchor(
          entry.key,
          load: barbell ? metric * 100 : 0,
          reps: barbell
              ? 6
              : entry.key == 'plank'
              ? 0
              : metric.toInt(),
          seconds: entry.key == 'plank' ? metric.toInt() : 0,
        );
        final result = PlacementPolicy.preview(
          input(
            classId: barbell
                ? 'C'
                : entry.key == 'bodyweight-air-squat'
                ? 'A'
                : 'E',
            mass: 120,
            anchors: [sample],
          ),
          ids,
        );
        expect(result.anchorScores[sample.exerciseId], index + 2);
      });
      test('${entry.key} immediately below boundary ${index + 2}', () {
        final barbell = entry.key.startsWith('barbell');
        final metric = entry.value[index];
        // mass72 and reps6: exact boundary load = ratio * 60.
        final sample = anchor(
          entry.key,
          load: barbell ? metric * 60 - .000000001 : 0,
          reps: barbell
              ? 6
              : entry.key == 'plank'
              ? 0
              : metric.toInt() - 1,
          seconds: entry.key == 'plank' ? metric.toInt() - 1 : 0,
        );
        final result = PlacementPolicy.preview(
          input(
            classId: barbell
                ? 'C'
                : entry.key == 'bodyweight-air-squat'
                ? 'A'
                : 'E',
            mass: 72,
            anchors: [sample],
          ),
          ids,
        );
        expect(result.anchorScores[sample.exerciseId], index + 1);
      });
    }
  }
  test('lower of two, caps, and fewer than two', () {
    expect(
      PlacementPolicy.preview(
        input(
          anchors: [anchor('push-up', reps: 30), anchor('plank', seconds: 60)],
        ),
        ids,
      ).classLevel,
      3,
    );
    expect(
      PlacementPolicy.preview(
        input(
          bar: false,
          anchors: [anchor('push-up', reps: 30), anchor('plank', seconds: 120)],
        ),
        ids,
      ).classLevel,
      3,
    );
    expect(
      PlacementPolicy.preview(
        input(anchors: [anchor('push-up', reps: 30)]),
        ids,
      ).reason,
      'insufficient_anchors',
    );
    for (final c in ['A', 'D']) {
      expect(
        PlacementPolicy.preview(
          input(
            classId: c,
            anchors: [
              anchor('push-up', reps: 30),
              anchor('plank', seconds: 120),
              anchor('bodyweight-air-squat', reps: 40),
            ],
          ),
          ids,
        ).classLevel,
        3,
      );
    }
    expect(
      PlacementPolicy.preview(
        input(
          classId: 'F',
          anchors: [
            anchor('barbell-bench-press', load: 100, reps: 10),
            anchor('barbell-squat', load: 150, reps: 10),
            anchor('push-up', reps: 30),
          ],
        ),
        ids,
      ).classLevel,
      3,
    );
  });
  test('never trained skip age and equipment leave level 1', () {
    for (final pair in <(PlacementInput, String)>[
      (input(trained: false), 'never_trained'),
      (input(skip: true), 'skipped'),
      (input(age: 17), 'unsupported_age'),
      (input(age: 65), 'unsupported_age'),
      (input(age: null), 'unsupported_age'),
      (
        input(
          classId: 'C',
          barbell: false,
          anchors: [anchor('push-up', reps: 30), anchor('plank', seconds: 120)],
        ),
        'missing_equipment',
      ),
    ]) {
      final result = PlacementPolicy.preview(pair.$1, ids);
      expect(
        [result.classLevel, result.globalLevel, result.reason],
        [1, 1, pair.$2],
      );
    }
  });
  test('rejects foreign variants duplicate IDs and invalid metrics', () {
    for (final samples in <List<PlacementAnchor>>[
      [const PlacementAnchor(exerciseId: 'unknown', reps: 10)],
      [anchor('push-up', reps: 20), anchor('push-up', reps: 30)],
      [anchor('push-up', load: 1, reps: 20)],
      [anchor('plank', reps: 1, seconds: 30)],
      [anchor('barbell-squat', load: double.nan, reps: 5)],
      [anchor('barbell-squat', load: double.infinity, reps: 5)],
      [anchor('barbell-squat', load: 50, reps: 3)],
      [anchor('barbell-squat', load: 50, reps: 11)],
      [
        const PlacementAnchor(
          exerciseId: '00000000-0000-4000-8000-000000000004',
          protocolVersion: 'assisted',
          reps: 20,
        ),
      ],
      [anchor('pull-up', reps: -1)],
    ]) {
      expect(
        () =>
            PlacementPolicy.preview(input(classId: 'C', anchors: samples), ids),
        throwsArgumentError,
      );
    }
  });
  test('missing barbell body mass gives no elevated preview', () {
    expect(
      PlacementPolicy.preview(
        input(
          classId: 'C',
          mass: null,
          anchors: [
            anchor('barbell-squat', load: 70, reps: 8),
            anchor('barbell-bench-press', load: 40, reps: 8),
          ],
        ),
        ids,
      ).reason,
      'missing_body_mass',
    );
  });
  test('normalized request is sorted, excludes profile and earned fields', () {
    final value = input();
    final request = value.toRequest();
    expect(request.keys.toSet(), {
      'policyVersion',
      'classId',
      'hasTrainingExperience',
      'skip',
      'equipment',
      'anchors',
    });
    expect((request['anchors'] as List).first, {
      'exerciseId': ids['push-up'],
      'protocolVersion': 'strict-v1',
      'loadKg': 0.0,
      'reps': 22,
      'durationSeconds': 0,
    });
    expect(value.toEnvelope('operation'), {
      'operationId': 'operation',
      'request': request,
    });
    expect(input(trained: false).toRequest()['anchors'], isEmpty);
    expect(input(skip: true).toRequest()['anchors'], isEmpty);
  });
  test('state parses readiness separately and never invents confirmation', () {
    final absent = PlacementState.fromJson({'status': 'unassessed'});
    expect(absent.confirmedGlobalFloor, isNull);
    expect(absent.readinessGlobalLevel, isNull);
    final value = PlacementState.fromJson({
      'status': 'confirmed',
      'policyVersion': 'placement-v0.1',
      'assessedClassId': 'C',
      'provisionalClassLevel': 3,
      'provisionalGlobalLevel': 5,
      'confirmedClassFloor': 4,
      'confirmedGlobalFloor': 7,
      'readinessClassLevel': 4,
      'readinessGlobalLevel': 8,
      'readinessXpToNextGlobalLevel': 25,
      'readinessXpToNextClassLevel': 120,
    });
    expect(value.status, 'confirmed');
    expect(value.readinessGlobalLevel, 8);
    expect(value.confirmedGlobalFloor, 7);
    expect(value.readinessXpToNextGlobalLevel, 25);
    expect(
      () => PlacementState.fromJson({
        'status': 'confirmed',
        'readinessGlobalLevel': '8',
      }),
      throwsFormatException,
    );
  });
  test('below first threshold and inability stay score one', () {
    final result = PlacementPolicy.preview(
      input(
        anchors: [
          anchor('pull-up', reps: 0),
          anchor('push-up', reps: 4),
          anchor('plank', seconds: 29),
        ],
      ),
      ids,
    );
    expect(result.classLevel, 1);
    expect(result.anchorScores.values, everyElement(1));
  });
  test('draft and estimate cannot mutate original lists or scores', () {
    final anchors = [anchor('push-up', reps: 20), anchor('plank', seconds: 90)];
    final draft = input(anchors: anchors);
    anchors.clear();
    expect(draft.anchors.length, 2);
    expect(() => draft.anchors.clear(), throwsUnsupportedError);
    final result = PlacementPolicy.preview(draft, ids);
    expect(() => result.anchorScores.clear(), throwsUnsupportedError);
  });
  test('unknown class excessive anchors invalid canonical maps reject', () {
    expect(
      () => PlacementPolicy.preview(input(classId: 'Z'), ids),
      throwsArgumentError,
    );
    expect(
      () => PlacementPolicy.preview(
        input(
          anchors: [
            anchor('push-up'),
            anchor('plank'),
            anchor('pull-up'),
            anchor('push-up'),
          ],
        ),
        ids,
      ),
      throwsArgumentError,
    );
    expect(
      () =>
          PlacementPolicy.preview(input(), {...ids, 'push-up': 'mit:push-up'}),
      throwsArgumentError,
    );
    expect(
      () =>
          PlacementPolicy.preview(input(), {...ids, 'push-up': ids['plank']!}),
      throwsArgumentError,
    );
  });
  test('profile body mass outside 20 through 400 rejects', () {
    for (final mass in [19.9, 400.1, double.nan, double.infinity]) {
      expect(
        () => PlacementPolicy.preview(
          input(
            classId: 'C',
            mass: mass,
            anchors: [
              anchor('barbell-squat', load: 70, reps: 8),
              anchor('barbell-bench-press', load: 40, reps: 8),
            ],
          ),
          ids,
        ),
        throwsArgumentError,
      );
    }
  });
  test('UUID matching and duplicate rejection ignore case', () {
    final letters = {...ids, 'push-up': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'};
    final upper = PlacementAnchor(
      exerciseId: letters['push-up']!.toUpperCase(),
      reps: 30,
    );
    expect(
      PlacementPolicy.preview(
        input(anchors: [upper, anchor('plank', seconds: 120)]),
        letters,
      ).classLevel,
      3,
    );
    expect(
      () => PlacementPolicy.preview(
        input(
          anchors: [
            upper,
            PlacementAnchor(exerciseId: letters['push-up']!, reps: 30),
          ],
        ),
        letters,
      ),
      throwsArgumentError,
    );
    expect(input(anchors: [upper]).toRequest()['anchors'], [
      upper.toJson()..['exerciseId'] = letters['push-up']!,
    ]);
  });
  test('state rejects out-of-range level projection', () {
    for (final pair in [
      ('provisionalClassLevel', 6),
      ('provisionalGlobalLevel', 11),
      ('confirmedClassFloor', 0),
      ('confirmedGlobalFloor', 11),
      ('readinessClassLevel', 21),
      ('readinessGlobalLevel', 101),
    ]) {
      expect(
        () =>
            PlacementState.fromJson({'status': 'confirmed', pair.$1: pair.$2}),
        throwsFormatException,
      );
    }
  });
}
