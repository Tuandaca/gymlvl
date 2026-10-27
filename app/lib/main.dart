import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/candy_theme.dart';
import 'app.dart';

export 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SupabaseConfig.isConfigured) {
    runApp(const ConfigurationApp());
    return;
  }
  try {
    await SupabaseConfig.initialize();
  } catch (_) {
    runApp(const ConfigurationApp(initializationFailed: true));
    return;
  }

  runApp(const ProviderScope(child: MainApp()));
}

class ConfigurationApp extends StatelessWidget {
  const ConfigurationApp({super.key, this.initializationFailed = false});
  final bool initializationFailed;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymLevel setup',
      debugShowCheckedModeBanner: false,
      theme: CandyTheme.theme,
      darkTheme: CandyTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fitness_center, size: 56),
                    const SizedBox(height: 24),
                    Text(
                      'GYMLEVEL',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      initializationFailed
                          ? 'Không thể khởi tạo kết nối. Kiểm tra cấu hình rồi tải lại.\nCould not initialize the connection. Check configuration and reload.'
                          : 'Cấu hình Supabase để bắt đầu.\nConfigure Supabase to begin.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const SelectableText(
                      'Copy config.example.json to config.local.json, add your public project configuration, then run:\n\nflutter run -d chrome --web-port 8080 --dart-define-from-file=config.local.json\n\nSetup and migrations: README.md',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
