import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/user_preference.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/llm_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/ai/model_download_service.dart';
import 'package:pillow_bud/services/database/database_service.dart';
import 'package:pillow_bud/services/storage_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    setState(() => _visible = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    await _loadPersistentState();
  }

  Future<void> _loadPersistentState() async {
    final completed = StorageService.isOnboardingCompleted();
    final userName = StorageService.getUserName() ?? '';
    final buddyPersonality = StorageService.getBuddyPersonality();
    final isDarkMode = StorageService.isDarkMode();
    final savedTheme = StorageService.getTheme();
    final memberSince = StorageService.getOnboardingCompletedAt();

    ref.read(userNameProvider.notifier).state = userName;
    ref.read(onboardingCompletedProvider.notifier).state = completed;
    ref.read(buddyPersonalityProvider.notifier).state = buddyPersonality;
    ref.read(isDarkModeProvider.notifier).state = isDarkMode;
    ref.read(themeProvider.notifier).state = savedTheme;
    ref.read(userPreferenceProvider.notifier).state = UserPreference(
      userName: userName,
      buddyPersonality: buddyPersonality,
      isDarkMode: isDarkMode,
      primaryColor: '#8B78D6',
      secondaryColor: '#76B8E8',
      onboardingCompleted: completed,
      onboardingCompletedAt: memberSince,
    );

    // Load persisted encrypted chat messages from SQLite3
    try {
      final dbMessages = await DatabaseService.getAllChatMessages();
      if (dbMessages.isNotEmpty) {
        ref.read(chatMessagesProvider.notifier).state = dbMessages;
      }
    } catch (_) {}

    // Load persisted encrypted journal entries from SQLite3
    try {
      final dbEntries = await DatabaseService.getAllJournalEntries();
      if (dbEntries.isNotEmpty) {
        ref.read(journalEntriesProvider.notifier).state = dbEntries;
      } else {
        final localEntries = StorageService.getJournalEntries();
        ref.read(journalEntriesProvider.notifier).state = localEntries;
      }
    } catch (_) {
      final localEntries = StorageService.getJournalEntries();
      ref.read(journalEntriesProvider.notifier).state = localEntries;
    }

    // Check model presence
    await ModelDownloadService.isModelDownloaded();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            completed ? const HomeScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: AnimatedOpacity(
          duration: MediaQuery.maybeOf(context)?.disableAnimations == true
              ? Duration.zero
              : const Duration(milliseconds: 600),
          opacity: _visible ? 1 : 0,
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.25),
                      primary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🛏️', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pillow Bud',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ENCRYPTED • LOCAL AI • 100% PRIVATE',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
