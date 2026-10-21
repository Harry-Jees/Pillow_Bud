import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _dropAnimation;
  late final Animation<double> _impactScale;
  bool _visible = false;
  bool _landed = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    );
    _dropAnimation = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0, 0.86, curve: Curves.easeInCubic),
    );
    _impactScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.84)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.84, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 57,
      ),
    ]).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.78, 1, curve: Curves.easeOut),
    ));
    _logoController.addStatusListener(_handleLogoStatus);
    _startSplash();
  }

  void _handleLogoStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _landed || !mounted) return;
    _landed = true;
    setState(() => _visible = true);
    final platform = defaultTargetPlatform;
    if (!kIsWeb &&
        (platform == TargetPlatform.iOS ||
            platform == TargetPlatform.android)) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _startSplash() async {
    // Read accessibility settings after the first frame, when inherited
    // media information is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final media = MediaQuery.maybeOf(context);
      final reduceMotion = media?.disableAnimations == true ||
          WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
              .reduceMotion;
      if (reduceMotion) {
        _logoController.value = 1;
      } else {
        _logoController.forward();
      }
    });

    await Future.delayed(const Duration(milliseconds: 1450));
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

    // Load persisted encrypted chat messages from SQLite3.
    try {
      final dbMessages = await DatabaseService.getAllChatMessages();
      if (dbMessages.isNotEmpty) {
        ref.read(chatMessagesProvider.notifier).state = dbMessages;
      }
    } catch (_) {}

    // Load persisted encrypted journal entries from SQLite3.
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

    await ModelDownloadService.isModelDownloaded();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            completed ? const HomeScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration:
            MediaQuery.maybeOf(context)?.disableAnimations == true
                ? Duration.zero
                : const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.removeStatusListener(_handleLogoStatus);
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;
    final isDarkMode = ref.watch(isDarkModeProvider);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 112, height: 112),
              const SizedBox(height: 24),
              AnimatedOpacity(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 380),
                opacity: _visible ? 1 : 0,
                curve: Curves.easeOut,
                child: Column(
                  children: [
                    Text(
                      'Pillow Bud',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? const Color(0xFFECECF1)
                            : const Color(0xFF1A1225),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
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
            ],
          ),
          AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) {
              final progress = reduceMotion ? 1.0 : _dropAnimation.value;
              final startOffset = screenHeight * 0.58;
              return Transform.translate(
                offset: Offset(0, -startOffset * (1 - progress)),
                child: Transform.scale(
                  scale: reduceMotion ? 1 : _impactScale.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDarkMode ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: primary.withValues(alpha: 0.42),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.2),
                    blurRadius: 28,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🛏️', style: TextStyle(fontSize: 44)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
