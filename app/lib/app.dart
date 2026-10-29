import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/candy_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/localization_engine.dart';
import 'l10n/app_localizations.dart';

/// Root application widget configured with Candy Neubrutalism visual system
/// (CandyTheme.theme / CandyTheme.lightTheme / CandyTheme.darkTheme) and GoRouter.
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final mode = ref.watch(localizationModeProvider);

    return MaterialApp.router(
      title: 'GymLvl',
      theme: CandyTheme.theme,
      darkTheme: CandyTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: Locale(mode == AppLangMode.en ? 'en' : 'vi'),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
    );
  }
}
