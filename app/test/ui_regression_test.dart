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
          theme: AppTheme.darkTheme,
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

  testWidgets(
    'profile identity and edit text meet contrast on the light card',
    (tester) async {
      await pumpFixture(tester, const ProfileScreen(), textScale: 2);

      double contrast(Color a, Color b) {
        final first = a.computeLuminance();
        final second = b.computeLuminance();
        final lighter = first > second ? first : second;
        final darker = first > second ? second : first;
        return (lighter + 0.05) / (darker + 0.05);
      }

      final name = tester.widget<Text>(find.text('Alex Nguyen'));
      expect(name.style?.color, AppTheme.textMain);
      expect(
        contrast(name.style!.color!, AppTheme.panelBackground),
        greaterThanOrEqualTo(4.5),
      );

      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.style?.color, AppTheme.textMain);
      expect(
        contrast(field.style!.color!, AppTheme.panelBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
