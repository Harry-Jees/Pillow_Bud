import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/user_preference.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/llm_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
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
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _visible = true);
    await Future.delayed(const Duration(seconds: 2));
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
      primaryColor: '#C4A8F8',
      secondaryColor: '#89C4F8',
      onboardingCompleted: completed,
      onboardingCompletedAt: memberSince,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => completed ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _visible ? 1 : 0,
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🛏️', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pillow Bud',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'YOUR EMOTIONAL COMPANION',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
