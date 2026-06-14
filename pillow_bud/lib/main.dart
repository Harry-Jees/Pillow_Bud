import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/storage_service.dart';
import 'package:pillow_bud/services/isar_service.dart';
import 'package:pillow_bud/theme/app_theme.dart';
import 'package:pillow_bud/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await IsarService.init();
  runApp(const ProviderScope(child: PillowBudApp()));
}

class PillowBudApp extends ConsumerWidget {
  const PillowBudApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeColors = ref.watch(currentThemeProvider);

    return MaterialApp(
      title: 'Pillow Bud',
      theme: AppTheme.lightTheme(
        primary: themeColors['primary']!,
        secondary: themeColors['secondary']!,
      ),
      darkTheme: AppTheme.darkTheme(
        primary: themeColors['primary']!,
        secondary: themeColors['secondary']!,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
