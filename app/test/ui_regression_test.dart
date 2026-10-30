import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/localization/localization_engine.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/ui/candy/candy_button.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/auth/presentation/screens/register_screen.dart';
import 'package:app/features/dashboard/domain/dashboard_stats.dart';
import 'package:app/features/dashboard/presentation/providers/class_providers.dart';
import 'package:app/features/dashboard/presentation/providers/stats_providers.dart';
import 'package:app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:app/features/onboarding/domain/user_profile_draft.dart';
import 'package:app/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:app/features/profile/presentation/screens/profile_screen.dart';
import 'package:app/features/progression/presentation/widgets/level_up_overlay.dart';
import 'package:app/features/quests/domain/quest_instance.dart';
import 'package:app/features/quests/presentation/providers/quest_providers.dart';
import 'package:app/features/quests/presentation/screens/quests_screen.dart';

class FixtureLanguage extends LocalizationModeNotifier {
  FixtureLanguage(this.mode);
  final AppLangMode mode;
  @override
  AppLangMode build() => mode;
}

class FixtureQuest extends ActiveQuestController {
  FixtureQuest({this.fail = false, this.empty = false});
  final bool fail;
  final bool empty;
  @override
  Future<QuestInstance?> build() async {
    if (fail) throw StateError('private backend detail');
    if (empty) return null;
    return QuestInstance(
      id: 'quest-instance',
      userId: 'user',
      questId: 'daily',
      status: 'active',
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      config: const [
        PrescribedExercise(
          exerciseId: 'squat',
          exerciseName: 'Bodyweight Squat',
          sets: 3,
          reps: 12,
          weightKg: 0,
        ),
        PrescribedExercise(
          exerciseId: 'pushup',
          exerciseName: 'Push-up',
          sets: 3,
          reps: 10,
          weightKg: 0,
        ),
      ],
    );
  }
}

class FixtureStats extends DashboardStatsController {
  @override
  Future<DashboardStats?> build() async => const DashboardStats(
    volumeTrend: [
      VolumePoint(date: '2026-10-24', value: 900),
      VolumePoint(date: '2026-10-25', value: 1400),
      VolumePoint(date: '2026-10-26', value: 1250),
    ],
    muscleSplit: [
      MuscleSplit(label: 'Legs', value: 12),
      MuscleSplit(label: 'Chest', value: 8),
    ],
    achievements: [
      {'achievement_id': 'first_workout'},
      {'achievement_id': 'streak_7'},
    ],
    streak: {'current_streak': 7, 'longest_streak': 9},
  );
}

class RejectingAuth extends AuthController {
  @override
  Future<void> signIn(String email, String password) async {
    state = AsyncError(
      StateError('private backend detail'),
      StackTrace.current,
    );
  }
}

class FixtureOnboarding extends OnboardingController {
  int submissions = 0;
  @override
  Future<void> submitOnboarding() async {
    submissions++;
  }
}

Future<ProviderContainer> pumpFixture(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(390, 844),
  AppLangMode language = AppLangMode.en,
  double textScale = 1,
  bool questFailure = false,
  bool questEmpty = false,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      localizationModeProvider.overrideWith(() => FixtureLanguage(language)),
      currentUserProvider.overrideWith(
        (ref) async => {
          'display_name': 'Alex Nguyen',
          'email': 'alex@example.test',
          'level': 4,
          'current_level_xp': 180,
          'current_title': 'Warrior',
        },
      ),
      currentUserProfileProvider.overrideWith(
        (ref) async => {
          'age': 29,
          'height_cm': 175.5,
          'weight_kg': 72.5,
          'weekly_gym_days': 3,
          'weekly_home_days': 1,
          'preferred_training_days': ['mon', 'wed', 'fri'],
        },
      ),
      userClassesProvider.overrideWith(
        (ref) async => [
          {'class_id': 'B', 'slot': 'primary', 'level': 3, 'current_xp': 900},
          {'class_id': 'C', 'slot': 'secondary', 'level': 2, 'current_xp': 400},
        ],
      ),
      activeQuestControllerProvider.overrideWith(
        () => FixtureQuest(fail: questFailure, empty: questEmpty),
      ),
      dashboardStatsControllerProvider.overrideWith(FixtureStats.new),
      authControllerProvider.overrideWith(RejectingAuth.new),
      onboardingControllerProvider.overrideWith(FixtureOnboarding.new),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: const ValueKey('capture'),
        child: MaterialApp(
          theme: theme ?? AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          locale: Locale(language == AppLangMode.en ? 'en' : 'vi'),
          supportedLocales: const [Locale('en'), Locale('vi')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: screen,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_UI')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('capture')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('../docs/verification/ui');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

// ---------------------------------------------------------------------------
// Painted-colour resolution for the FND-BUG-004 light-surface checks.
//
// These helpers read the colours the widget tree actually hands to its
// painters instead of comparing two declared constants:
//   * text colour comes from the RenderParagraph that rasterises the glyphs
//     (or EditableText.style for input fields), with translucency composited
//     over the surface behind it;
//   * the background comes from the ancestor fill layers (Material, Container,
//     DecoratedBox, ColoredBox, Ink) composited outermost-to-innermost, which
//     is what the engine paints behind the node.
// A node whose surface cannot be resolved throws instead of falling back to a
// guessed value.
// ---------------------------------------------------------------------------

const double bodyTextContrastTarget = 4.5;
const double nonTextContrastTarget = 3.0;

double contrastRatio(Color a, Color b) {
  final double first = a.computeLuminance();
  final double second = b.computeLuminance();
  final double lighter = first > second ? first : second;
  final double darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Composites translucent paint over the surface behind it, as the engine does.
Color flattenOnto(Color foreground, Color background) =>
    foreground.a < 1 ? Color.alphaBlend(foreground, background) : foreground;

Color? _decorationColour(Decoration? decoration) => switch (decoration) {
  BoxDecoration(:final Color? color) => color,
  ShapeDecoration(:final Color? color) => color,
  _ => null,
};

Color? _paintedFill(Widget widget, ThemeData theme) => switch (widget) {
  // Container and AnimatedContainer never paint themselves; they hand the
  // fill to a child ColoredBox/DecoratedBox, so reading them here would
  // composite a translucent fill twice.
  Material(:final Color? color, :final MaterialType type) =>
    color ??
        switch (type) {
          MaterialType.canvas => theme.canvasColor,
          MaterialType.card => theme.cardColor,
          _ => null,
        },
  Scaffold(:final Color? backgroundColor) =>
    backgroundColor ?? theme.scaffoldBackgroundColor,
  DecoratedBox(:final Decoration decoration) => _decorationColour(decoration),
  ColoredBox(:final Color color) => color,
  Ink(:final Decoration? decoration) => _decorationColour(decoration),
  _ => null,
};

/// Composites every ancestor fill that paints behind [finder].
Color resolvePaintedBackground(WidgetTester tester, Finder finder) {
  final List<Color> layers = <Color>[];
  tester.element(finder).visitAncestorElements((Element element) {
    final Color? fill = _paintedFill(element.widget, Theme.of(element));
    if (fill != null && fill.a > 0) {
      layers.add(fill);
    }
    return true;
  });
  if (layers.isEmpty) {
    throw StateError('No painted background resolves for $finder');
  }
  Color surface = layers.last;
  if (surface.a < 1) {
    throw StateError('Outermost painted background for $finder is transparent');
  }
  for (var i = layers.length - 2; i >= 0; i--) {
    surface = Color.alphaBlend(layers[i], surface);
  }
  return surface;
}

/// The colour the paragraph renderer uses for the glyphs.
Color resolvePaintedTextColour(WidgetTester tester, Finder finder) {
  final Finder richText = find.descendant(
    of: finder,
    matching: find.byType(RichText),
  );
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
    richText.first,
  );
  final Color? colour = paragraph.text.style?.color;
  if (colour == null) {
    throw StateError('Text at $finder has no resolved paint colour');
  }
  return colour;
}

/// The colour an input field rasterises its value with.
Color resolveInputTextColour(WidgetTester tester, Finder finder) {
  final Finder editable = find.descendant(
    of: finder,
    matching: find.byType(EditableText),
  );
  final Color? colour = tester.widget<EditableText>(editable.first).style.color;
  if (colour == null) {
    throw StateError('EditableText at $finder has no resolved paint colour');
  }
  return colour;
}

Color resolveIconColour(WidgetTester tester, Finder finder) {
  final Color? colour = tester.widget<Icon>(finder).color;
  if (colour == null) {
    throw StateError('Icon at $finder has no resolved paint colour');
  }
  return colour;
}

/// The checkmark colour the chip render object actually paints.
///
/// `RawChip` hands the resolved colour to the private `_ChipRenderTheme` that
/// owns the checkmark painter, so it is not reachable through a public widget
/// property. Reading that theme keeps the assertion on the painted value
/// instead of on the `FilterChip.checkmarkColor` argument.
Color resolveChipCheckmarkColour(WidgetTester tester, Finder finder) {
  final Finder renderChip = find.descendant(
    of: finder,
    matching: find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == '_ChipRenderWidget',
    ),
  );
  final Widget chipWidget = tester.widget<Widget>(renderChip.first);
  // The resolved chip paint theme is private, so it is read through dynamic
  // dispatch on the widget that hands the colour to the checkmark painter.
  // ignore: avoid_dynamic_calls
  final dynamic chipTheme = (chipWidget as dynamic).theme;
  // ignore: avoid_dynamic_calls
  final Color? colour = chipTheme.checkmarkColor as Color?;
  if (colour == null) {
    throw StateError('Chip at $finder paints no checkmark colour');
  }
  return colour;
}

/// Asserts that [node] paints [expectedForeground] on its real surface with at
/// least [target] contrast, and that [regressionColour] (the colour this node
/// shipped with before the fix) would fail the very same assertion.
void expectPaintedContrast(
  WidgetTester tester, {
  required String name,
  required Finder node,
  required Color expectedForeground,
  required Color regressionColour,
  required double target,
  Color Function(WidgetTester tester, Finder finder)? resolveForeground,
}) {
  final Color background = resolvePaintedBackground(tester, node);
  final Color painted = (resolveForeground ?? resolvePaintedTextColour)(
    tester,
    node,
  );
  final Color foreground = flattenOnto(painted, background);
  expect(foreground, expectedForeground, reason: '$name paints $foreground');
  final double ratio = contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(target),
    reason: '$name: $foreground on $background = ${ratio.toStringAsFixed(2)}:1',
  );
  final double control = contrastRatio(
    flattenOnto(regressionColour, background),
    background,
  );
  expect(
    control,
    lessThan(target),
    reason:
        '$name positive control: $regressionColour on $background = '
        '${control.toStringAsFixed(2)}:1 must fail the $target target',
  );
}

typedef _ProfileCopy = ({
  String biometrics,
  String schedule,
  String classes,
  String classTitle,
  String ratio,
  String gymSessions,
  String homeSessions,
  String preferred,
  String selectedDay,
  String unselectedDay,
});

_ProfileCopy _profileCopy(AppLangMode language) => switch (language) {
  AppLangMode.vi => (
    biometrics: 'CHỈ SỐ CƠ THỂ',
    schedule: 'LỊCH TRÌNH TẬP LUYỆN',
    classes: 'HỆ PHÁI KÍCH HOẠT',
    classTitle: 'WARRIOR',
    ratio: '3/1 NGÀY',
    gymSessions: 'Buổi gym mỗi tuần: 3',
    homeSessions: 'Buổi tập tại nhà mỗi tuần: 1',
    preferred: 'NGÀY ƯU TIÊN',
    selectedDay: 'T2',
    unselectedDay: 'T3',
  ),
  AppLangMode.en || AppLangMode.bilingual => (
    biometrics: 'BIOMETRICS BOARD',
    schedule: 'BATTLE SCHEDULE',
    classes: 'ACTIVE CLASSES',
    classTitle: 'WARRIOR',
    ratio: '3/1 DAYS',
    gymSessions: 'Gym sessions per week: 3',
    homeSessions: 'Home sessions per week: 1',
    preferred: 'PREFERRED PROTOCOLS',
    selectedDay: 'Mon',
    unselectedDay: 'Tue',
  ),
};

typedef _OnboardingCopy = ({String male, String mon, String tue});

_OnboardingCopy _onboardingCopy(AppLangMode language) => switch (language) {
  AppLangMode.vi => (male: 'Nam', mon: 'T2', tue: 'T3'),
  AppLangMode.en ||
  AppLangMode.bilingual => (male: 'Male', mon: 'Mon', tue: 'Tue'),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in {
      'Inter': 'assets/fonts/InterVariable.ttf',
      'Orbitron': 'assets/fonts/OrbitronVariable.ttf',
    }.entries) {
      final loader = FontLoader(font.key)
        ..addFont(
          Future.value(
            ByteData.sublistView(await File(font.value).readAsBytes()),
          ),
        );
      await loader.load();
    }
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  final screens = <String, Widget>{
    'dashboard': const DashboardScreen(),
    'quests': const QuestsScreen(),
    'profile': const ProfileScreen(),
    'onboarding': const OnboardingScreen(),
  };
  for (final entry in screens.entries) {
    for (final language in [AppLangMode.vi, AppLangMode.en]) {
      for (final width in [320.0, 390.0, 768.0, 1440.0]) {
        testWidgets(
          '${entry.key} ${language.name} width $width has no layout errors',
          (tester) async {
            await pumpFixture(
              tester,
              entry.value,
              language: language,
              size: Size(width, width < 400 ? 844 : 900),
            );
            expect(tester.takeException(), isNull);
            await capture(
              tester,
              '${entry.key}_${language.name}_${width.toInt()}',
            );
          },
        );
      }
    }
  }

  testWidgets(
    'authentication validates inputs and exposes safe service errors',
    (tester) async {
      await pumpFixture(tester, const LoginScreen());
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'alex@example.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Could not sign in. Check your email, password, and connection.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('private backend'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('registration rejects mismatched passwords', (tester) async {
    await pumpFixture(
      tester,
      const RegisterScreen(),
      size: const Size(320, 844),
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'alex@example.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different123');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create account'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all nine onboarding steps remain reachable before submission', (
    tester,
  ) async {
    final container = await pumpFixture(
      tester,
      const OnboardingScreen(),
      size: const Size(320, 844),
    );
    container
        .read(onboardingDraftProvider.notifier)
        .set(
          const UserProfileDraft(
            environment: 'gym',
            goals: ['hypertrophy'],
            primaryClassId: 'B',
            secondaryClassId: 'C',
            experienceLevel: 'beginner',
            age: 29,
            gender: 'male',
            heightCm: 175,
            weightKg: 72,
            weeklyGymDays: 3,
            weeklyHomeDays: 1,
            preferredDays: ['mon', 'wed', 'fri'],
          ),
        );
    await tester.pumpAndSettle();
    for (var step = 1; step < 9; step++) {
      expect(find.text('Step $step/9'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Step 9/9'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Begin your journey'),
      findsOneWidget,
    );
    expect(
      (container.read(onboardingControllerProvider.notifier)
              as FixtureOnboarding)
          .submissions,
      0,
    );
    await capture(tester, 'onboarding_confirmation_en_320');
  });

  testWidgets('quest errors offer retry and never expose internal details', (
    tester,
  ) async {
    await pumpFixture(tester, const QuestsScreen(), questFailure: true);
    expect(
      find.text(
        'Could not load your data. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('private backend'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quest empty state is an honest rest day', (tester) async {
    await pumpFixture(tester, const QuestsScreen(), questEmpty: true);
    expect(
      find.text('No quest today. You can still start your own workout.'),
      findsOneWidget,
    );
    expect(find.text('350 XP'), findsNothing);
  });

  testWidgets(
    'completion feedback is scrollable at large text and short height',
    (tester) async {
      await pumpFixture(
        tester,
        Scaffold(
          body: LevelUpOverlay(
            xpResult: const {
              'earnedXP': 350,
              'totalXP': 2500,
              'leveledUp': true,
              'newLevel': 6,
              'newTitle': 'Warrior',
            },
            onDismiss: () {},
          ),
        ),
        size: const Size(320, 480),
        textScale: 1.5,
      );
      expect(find.text('+350 XP'), findsOneWidget);
      await tester.ensureVisible(find.byType(CandyButton));
      expect(tester.takeException(), isNull);
      await capture(tester, 'completion_en_320_large_text');
    },
  );

  testWidgets(
    'dashboard stats and unlocked badges render without narrow overflows',
    (tester) async {
      await pumpFixture(
        tester,
        const DashboardScreen(),
        size: const Size(320, 844),
        textScale: 1.5,
      );
      await tester.drag(find.byType(ListView), const Offset(0, -1600));
      await tester.pumpAndSettle();
      expect(find.text('First workout'), findsOneWidget);
      expect(find.text('7-day streak'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capture(tester, 'dashboard_stats_en_320_large_text');
    },
  );

  // -----------------------------------------------------------------------
  // FND-BUG-004: production Candy light surfaces.
  //
  // Every assertion below resolves the colour the widget tree actually paints
  // (text via the RenderParagraph / EditableText that rasterises the glyphs,
  // background via the ancestor fill layers composited outermost-inward), so
  // it fails if the app drifts back to legacy white/amber foregrounds even
  // though the constants still compile. Each node also carries a positive
  // control proving the same assertion rejects the pre-fix colour.
  // -----------------------------------------------------------------------
  for (final language in [AppLangMode.en, AppLangMode.vi]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'profile light surfaces keep readable paint (${language.name}, ${textScale}x)',
        (tester) async {
          final s = _profileCopy(language);
          await pumpFixture(
            tester,
            const ProfileScreen(),
            language: language,
            textScale: textScale,
            size: const Size(320, 844),
            theme: AppTheme.lightTheme,
          );
          expect(AppTheme.lightTheme.brightness, Brightness.light);
          // The pumped theme is the one app.dart installs (CandyTheme.theme),
          // and the panel/backdrop tokens the screen reads match it.
          expect(
            AppTheme.lightTheme.scaffoldBackgroundColor,
            AppTheme.background,
          );
          expect(AppTheme.lightTheme.cardColor, AppTheme.panelBackground);
          // Filled inputs paint their own surface inside a private render
          // object, so the input pair is only honest if that fill is the same
          // colour as the panel the resolver sees behind the field.
          expect(
            AppTheme.lightTheme.inputDecorationTheme.fillColor,
            AppTheme.panelBackground,
          );

          // View mode.
          expectPaintedContrast(
            tester,
            name: 'profile identity',
            node: find.text('Alex Nguyen'),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'section header',
            node: find.text(s.biometrics),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'section header (schedule)',
            node: find.text(s.schedule),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'section header (classes)',
            node: find.text(s.classes),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'class title',
            node: find.text(s.classTitle),
            expectedForeground: AppTheme.textDim,
            regressionColour: Colors.amber,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'schedule ratio value',
            node: find.text(s.ratio),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );

          // Edit mode.
          await tester.tap(find.byIcon(Icons.edit_rounded));
          await tester.pumpAndSettle();
          expectPaintedContrast(
            tester,
            name: 'profile name field',
            node: find.byType(TextField).first,
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
            resolveForeground: resolveInputTextColour,
          );
          expectPaintedContrast(
            tester,
            name: 'edit gym sessions label',
            node: find.text(s.gymSessions),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'edit home sessions label',
            node: find.text(s.homeSessions),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'edit preferred protocols label',
            node: find.text(s.preferred),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'edit selected day chip',
            node: find.text(s.selectedDay),
            expectedForeground: Colors.black,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'edit unselected day chip',
            node: find.text(s.unselectedDay),
            expectedForeground: AppTheme.textMain,
            regressionColour: Colors.white,
            target: bodyTextContrastTarget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  // -----------------------------------------------------------------------
  // FND-BUG-004 onboarding extension: unselected/selected chip paint resolved
  // from the live tree, plus the interaction that flips each chip.
  // -----------------------------------------------------------------------
  for (final language in [AppLangMode.en, AppLangMode.vi]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'onboarding chip paint is readable before and after selection '
        '(${language.name}, ${textScale}x)',
        (tester) async {
          final s = _onboardingCopy(language);
          final container = await pumpFixture(
            tester,
            const OnboardingScreen(),
            language: language,
            textScale: textScale,
            size: const Size(320, 844),
            theme: AppTheme.lightTheme,
          );
          final PageView pages = tester.widget<PageView>(find.byType(PageView));

          // Step 7 (index 6) — gender chips on the explicit light panel.
          pages.controller!.jumpToPage(6);
          await tester.pumpAndSettle();
          expect(find.text(s.male), findsOneWidget);

          expectPaintedContrast(
            tester,
            name: 'gender chip label (unselected)',
            node: find.text(s.male),
            expectedForeground: AppTheme.textDim,
            regressionColour: Colors.white54,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'gender chip icon (unselected)',
            node: find.byIcon(Icons.male),
            expectedForeground: AppTheme.textDim,
            regressionColour: Colors.white54,
            target: nonTextContrastTarget,
            resolveForeground: resolveIconColour,
          );

          await tester.ensureVisible(find.text(s.male));
          await tester.tap(find.text(s.male));
          await tester.pumpAndSettle();
          expect(container.read(onboardingDraftProvider).gender, 'male');

          expectPaintedContrast(
            tester,
            name: 'gender chip label (selected)',
            node: find.text(s.male),
            expectedForeground: AppTheme.textMain,
            regressionColour: AppTheme.cyanNeon,
            target: bodyTextContrastTarget,
          );
          expectPaintedContrast(
            tester,
            name: 'gender chip icon (selected)',
            node: find.byIcon(Icons.male),
            expectedForeground: AppTheme.textMain,
            regressionColour: AppTheme.cyanNeon,
            target: nonTextContrastTarget,
            resolveForeground: resolveIconColour,
          );
          // Resolver self-check: the selected chip paints exactly one 15%
          // accent fill over the card panel, not a double-composited fill.
          expect(
            resolvePaintedBackground(tester, find.text(s.male)),
            Color.alphaBlend(
              AppTheme.cyanNeon.withValues(alpha: 0.15),
              AppTheme.panelBackground,
            ),
          );

          // Step 8 (index 7) — preferred-day FilterChips.
          pages.controller!.jumpToPage(7);
          await tester.pumpAndSettle();
          expect(find.text(s.tue), findsOneWidget);
          expectPaintedContrast(
            tester,
            name: 'day chip label (unselected)',
            node: find.text(s.tue),
            expectedForeground: AppTheme.textDim,
            regressionColour: Colors.white54,
            target: bodyTextContrastTarget,
          );

          await tester.ensureVisible(find.text(s.mon));
          await tester.tap(find.text(s.mon));
          await tester.pumpAndSettle();
          expect(
            container.read(onboardingDraftProvider).preferredDays,
            contains('mon'),
          );
          expectPaintedContrast(
            tester,
            name: 'day chip label (selected)',
            node: find.text(s.mon),
            expectedForeground: AppTheme.textMain,
            regressionColour: AppTheme.cyanNeon,
            target: bodyTextContrastTarget,
          );

          final Finder selectedChip = find.widgetWithText(FilterChip, s.mon);
          final Color chipSurface = resolvePaintedBackground(
            tester,
            find.text(s.mon),
          );
          final Color checkmark = resolveChipCheckmarkColour(
            tester,
            selectedChip,
          );
          expect(checkmark, AppTheme.textMain);
          expect(
            contrastRatio(checkmark, chipSurface),
            greaterThanOrEqualTo(nonTextContrastTarget),
            reason: 'selected day chip checkmark on $chipSurface',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
