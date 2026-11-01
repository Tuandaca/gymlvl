import 'dart:async';

import 'package:app/core/localization/localization_engine.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:app/features/workout/presentation/screens/exercise_detail_screen.dart';
import 'package:app/features/workout/presentation/screens/exercise_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _id = '11111111-1111-4111-8111-111111111111';

const _exercise = Exercise(
  id: _id,
  name: 'Original name',
  nameVi: 'Đẩy tạ',
  nameEn: 'Press',
  category: 'Strength',
  equipment: 'Dumbbell',
  movementPattern: 'Push',
  difficulty: 'Beginner',
  secondaryMuscles: ['Triceps'],
  instructions: ['UNVERIFIED INSTRUCTION MUST NOT DISPLAY'],
  imageUrl: 'https://unlicensed.example/exercise.gif',
);

class _FixedLanguage extends LocalizationModeNotifier {
  _FixedLanguage(this.mode);
  final AppLangMode mode;

  @override
  AppLangMode build() => mode;
}

class _Repository implements ExerciseRepository {
  _Repository(this.load);
  final Future<List<Exercise>> Function() load;
  int calls = 0;

  @override
  Future<List<Exercise>> getExercises() {
    calls++;
    return load();
  }

  @override
  Future<List<Exercise>> searchExercises(String query) => load();

  @override
  Future<List<Exercise>> getExercisesByCategory(String category) => load();
}

class _Launcher extends StatelessWidget {
  const _Launcher({required this.onResult, required this.multiSelect});

  final ValueChanged<Object?> onResult;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: () async {
          if (multiSelect) {
            onResult(
              await context.push<List<Exercise>>(
                '/exercise-picker?multiSelect=true',
              ),
            );
          } else {
            onResult(await context.push<Exercise>('/exercise-picker'));
          }
        },
        child: const Text('Open picker'),
      ),
    ),
  );
}

Widget _app({
  required _Repository repository,
  String initialLocation = '/exercise/$_id',
  AppLangMode language = AppLangMode.en,
  ValueChanged<Object?>? onResult,
  bool multiSelect = false,
  TextScaler textScaler = TextScaler.noScaling,
  Exercise? routeExtra,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            _Launcher(onResult: onResult ?? (_) {}, multiSelect: multiSelect),
      ),
      GoRoute(
        path: '/exercise-picker',
        builder: (_, state) => ExercisePickerScreen(
          multiSelect: state.uri.queryParameters['multiSelect'] == 'true',
        ),
      ),
      GoRoute(
        path: '/exercise/:id',
        builder: (_, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['id'] ?? '',
          initialExercise:
              routeExtra ??
              (state.extra is Exercise ? state.extra as Exercise : null),
          canSelect: state.uri.queryParameters['select'] == 'true',
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      exerciseRepositoryProvider.overrideWithValue(repository),
      localizationModeProvider.overrideWith(() => _FixedLanguage(language)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
    ),
  );
}

void main() {
  testWidgets('stable ID loads real metadata once and never displays media', (
    tester,
  ) async {
    final repository = _Repository(() async => [_exercise]);
    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Press'), findsOneWidget);
    expect(find.text('Dumbbell'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Triceps'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(repository.calls, 1);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Exercise visual unavailable'), findsOneWidget);
  });

  testWidgets('Vietnamese name and labels render without English claims', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => [_exercise]),
        language: AppLangMode.vi,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đẩy tạ'), findsOneWidget);
    expect(find.text('Nhóm cơ chính'), findsOneWidget);
    expect(find.text('Chưa có thông tin'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Hướng dẫn'), findsOneWidget);
  });

  testWidgets('mismatched route extra cannot replace the stable ID result', (
    tester,
  ) async {
    final wrong = _exercise.copyWith(id: 'other-id', nameEn: 'Wrong exercise');
    final repository = _Repository(() async => [_exercise]);
    await tester.pumpWidget(_app(repository: repository, routeExtra: wrong));
    await tester.pumpAndSettle();

    expect(find.text('Press'), findsOneWidget);
    expect(find.text('Wrong exercise'), findsNothing);
    expect(repository.calls, 1);
  });

  testWidgets('untranslated name and unverified instructions stay explicit', (
    tester,
  ) async {
    final withoutTranslation = _exercise.copyWith(nameVi: '');
    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => [withoutTranslation]),
        language: AppLangMode.vi,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Press'), findsOneWidget);
    expect(
      find.text('Đang hiển thị tên hiện có; chưa có bản dịch tiếng Việt.'),
      findsOneWidget,
    );
    expect(find.text('UNVERIFIED INSTRUCTION MUST NOT DISPLAY'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa có hướng dẫn đáng tin cậy cho bài tập này.'),
      findsOneWidget,
    );
  });

  testWidgets('missing optional metadata and missing ID are safe', (
    tester,
  ) async {
    final minimal = _exercise.copyWith(
      equipment: '',
      secondaryMuscles: [],
      movementPattern: null,
      difficulty: null,
      instructions: [],
    );
    await tester.pumpWidget(
      _app(repository: _Repository(() async => [minimal])),
    );
    await tester.pumpAndSettle();
    expect(find.text('Not available'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => [minimal]),
        initialLocation: '/exercise/missing-id',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Exercise not found'), findsOneWidget);
  });

  testWidgets('loading, error, and retry use the catalogue provider', (
    tester,
  ) async {
    final waiting = Completer<List<Exercise>>();
    var fail = true;
    final repository = _Repository(() {
      if (fail) return waiting.future;
      return Future.value([_exercise]);
    });
    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    waiting.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load exercise'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Press'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('missing and error states fit 320dp with 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => []),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Exercise not found'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => throw StateError('offline')),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load exercise'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picker detail returns to picker without selecting on back', (
    tester,
  ) async {
    Object? result;
    final repository = _Repository(() async => [_exercise]);
    await tester.pumpWidget(
      _app(
        repository: repository,
        initialLocation: '/',
        onResult: (v) => result = v,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byTooltip('View details')), const Size(48, 48));
    await tester.tap(find.byTooltip('View details'));
    await tester.pumpAndSettle();
    expect(find.byType(ExerciseDetailScreen), findsOneWidget);
    expect(repository.calls, 1);
    await tester.tap(find.byTooltip('Back to exercises'));
    await tester.pumpAndSettle();
    expect(find.byType(ExercisePickerScreen), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('detail selection preserves single-select result contract', (
    tester,
  ) async {
    Object? result;
    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => [_exercise]),
        initialLocation: '/',
        onResult: (v) => result = v,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('View details'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Select exercise'), findsOneWidget);
    await tester.tap(find.text('Select exercise'));
    await tester.pumpAndSettle();
    expect(result, isA<Exercise>());
    expect((result as Exercise).id, _id);
  });

  testWidgets('detail selection preserves multi-select result contract', (
    tester,
  ) async {
    Object? result;
    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => [_exercise]),
        initialLocation: '/',
        onResult: (v) => result = v,
        multiSelect: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('View details'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Select exercise'), findsOneWidget);
    await tester.tap(find.text('Select exercise'));
    await tester.pumpAndSettle();
    expect(find.byType(ExercisePickerScreen), findsOneWidget);
    await tester.tap(find.text('Finish (1)'));
    await tester.pumpAndSettle();
    expect(result, isA<List<Exercise>>());
    expect((result as List<Exercise>).single.id, _id);
  });

  testWidgets('320dp and 2x text have no overflow and expose semantics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        repository: _Repository(() async => [_exercise]),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to exercises'), findsOneWidget);
    expect(find.text('Exercise visual unavailable'), findsOneWidget);
    final mediaSemantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where(
          (widget) => widget.properties.label == 'Exercise visual unavailable',
        );
    expect(mediaSemantics, hasLength(1));
    expect(mediaSemantics.single.excludeSemantics, isTrue);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
