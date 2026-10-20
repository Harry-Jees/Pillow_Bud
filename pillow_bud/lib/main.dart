import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/screens/biometric_lock_screen.dart';
import 'package:pillow_bud/screens/splash_screen.dart';
import 'package:pillow_bud/services/ai/model_download_service.dart';
import 'package:pillow_bud/services/auth/biometric_service.dart';
import 'package:pillow_bud/services/database/database_service.dart';
import 'package:pillow_bud/services/notifications/notification_service.dart';
import 'package:pillow_bud/services/storage_service.dart';
import 'package:pillow_bud/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await DatabaseService.init();
  await ModelDownloadService.isModelDownloaded();
  await NotificationService.initialize();

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
        tertiary: themeColors['tertiary'],
      ),
      darkTheme: AppTheme.darkTheme(
        primary: themeColors['primary']!,
        secondary: themeColors['secondary']!,
        tertiary: themeColors['tertiary'],
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const _AppRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Root widget that handles the biometric lock gate and app lifecycle.
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot>
    with WidgetsBindingObserver {
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricOnLaunch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called once on initial app launch.
  Future<void> _checkBiometricOnLaunch() async {
    final enabled = await BiometricService.isEnabled();
    if (!enabled) return;
    final valid = await BiometricService.isSessionValid();
    if (!valid) {
      if (mounted) setState(() => _locked = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleResume();
    }
  }

  Future<void> _handleResume() async {
    final enabled = await BiometricService.isEnabled();
    if (!enabled) return;
    final valid = await BiometricService.isSessionValid();
    if (!valid && mounted) {
      setState(() => _locked = true);
    }
  }

  void _onUnlocked() {
    if (mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return BiometricLockScreen(onUnlocked: _onUnlocked);
    }
    return const SplashScreen();
  }
}
