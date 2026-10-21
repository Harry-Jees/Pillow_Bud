import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/user_preference.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/llm_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/auth/biometric_service.dart';
import 'package:pillow_bud/services/database/database_service.dart';
import 'package:pillow_bud/services/storage_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  String userName = '';
  String selectedPersonality = 'balanced';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final name = userName.trim().isEmpty ? 'Friend' : userName.trim();
    final now = DateTime.now();

    final pref = UserPreference(
      userName: name,
      buddyPersonality: selectedPersonality,
      isDarkMode: true,
      primaryColor: '#8B78D6',
      secondaryColor: '#76B8E8',
      onboardingCompleted: true,
      onboardingCompletedAt: now,
    );

    ref.read(userNameProvider.notifier).state = name;
    ref.read(onboardingCompletedProvider.notifier).state = true;
    ref.read(buddyPersonalityProvider.notifier).state = selectedPersonality;
    ref.read(userPreferenceProvider.notifier).state = pref;

    await StorageService.setUserName(name);
    await StorageService.setOnboardingCompleted(true);
    await StorageService.setBuddyPersonality(selectedPersonality);
    await StorageService.setOnboardingCompletedAt(now);

    // Save to Encrypted SQLite3 Database with hardware-backed key
    try {
      await DatabaseService.savePreferences(pref);
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: List.generate(6, (index) {
                  final isActive = index <= _currentPage;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: MediaQuery.maybeOf(context)?.disableAnimations == true
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary
                            : (isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(primary, isDarkMode),
                  _buildNamePage(primary, isDarkMode),
                  _buildPersonalityPage(primary, isDarkMode),
                  _buildBiometricSetupPage(primary, isDarkMode),
                  _buildDisclaimerPage(primary, isDarkMode),
                  _buildReadyPage(primary, isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(Color primary, bool isDarkMode) {
    return _buildPageLayout(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: primary.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Text('🛏️', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Meet Pillow Bud',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your local, private emotional companion. Always listening, completely encrypted, zero cloud tracking.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        _buildActionButton(
          label: 'Begin Journey',
          enabled: true,
          primary: primary,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildNamePage(Color primary, bool isDarkMode) {
    return _buildPageLayout(
      children: [
        Text(
          'What should Bud call you?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your name is stored encrypted on this device.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          onChanged: (value) => setState(() => userName = value),
          decoration: InputDecoration(
            hintText: 'Enter your preferred name...',
            prefixIcon: Icon(Icons.person_outline, color: primary),
          ),
          style: TextStyle(
            fontFamily: 'DM Sans',
            color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 16,
          ),
          autofocus: true,
        ),
        const SizedBox(height: 36),
        _buildActionButton(
          label: 'Continue',
          enabled: userName.trim().isNotEmpty,
          primary: primary,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildPersonalityPage(Color primary, bool isDarkMode) {
    return _buildPageLayout(
      children: [
        Text(
          'How should Bud respond?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a conversational tone (modifiable anytime)',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            _buildPersonalityOption('Balanced', 'Equal harmony of validation, inquiry, and wisdom', primary, isDarkMode),
            const SizedBox(height: 10),
            _buildPersonalityOption('Gentle', 'Soft, reassuring, validating with minimal questions', primary, isDarkMode),
            const SizedBox(height: 10),
            _buildPersonalityOption('Curious', 'Warm, exploratory questions to discover insights', primary, isDarkMode),
            const SizedBox(height: 10),
            _buildPersonalityOption('Wise', 'Reflective, grounded perspective without judgment', primary, isDarkMode),
          ],
        ),
        const SizedBox(height: 28),
        _buildActionButton(
          label: 'Continue',
          enabled: true,
          primary: primary,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildPersonalityOption(String title, String subtitle, Color primary, bool isDarkMode) {
    final isSelected = selectedPersonality == title.toLowerCase();

    return GestureDetector(
      onTap: () => setState(() => selectedPersonality = title.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primary : (isDarkMode ? const Color(0x18FFFFFF) : const Color(0x12000000)),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? primary.withValues(alpha: 0.12)
              : (isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primary : (isDarkMode ? Colors.white38 : Colors.black38),
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primary : (isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricSetupPage(Color primary, bool isDarkMode) {
    return _buildPageLayout(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.fingerprint_rounded, color: primary, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          'Biometric & System Lock',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Protect your private conversations with Fingerprint, Face ID, or Windows Hello. Bud automatically locks after 1.5 minutes of inactivity.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            height: 1.5,
            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0x18FFFFFF) : const Color(0x12000000),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.security_rounded, color: primary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Biometric Protection',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'System-level Hardware Lock',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await BiometricService.authenticate(
                    reason: 'Test biometric authentication to enable app lock',
                  );
                  if (success) {
                    await BiometricService.setEnabled(true);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Biometric Lock enabled successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Device authentication failed or not configured on this PC.'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('Enable & Test', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          label: 'Continue Setup',
          enabled: true,
          primary: primary,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildDisclaimerPage(Color primary, bool isDarkMode) {
    return _buildPageLayout(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.shield_outlined, color: AppColors.info, size: 30),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Privacy & Care Foundation',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0x18FFFFFF) : const Color(0x12000000),
            ),
          ),
          child: Column(
            children: [
              _buildFeatureBullet(
                Icons.lock_rounded,
                'Hardware-Backed Encryption',
                'Your keys are stored in your device\'s system secure enclave / DPAPI.',
                primary,
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildFeatureBullet(
                Icons.cloud_off_rounded,
                '100% Offline & Private',
                'Bud processes thoughts locally without uploading your private logs to external clouds.',
                primary,
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildFeatureBullet(
                Icons.favorite_rounded,
                'Supportive Companion',
                'Bud is an AI companion for emotional reflection, not clinical medical treatment.',
                primary,
                isDarkMode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        _buildActionButton(
          label: 'I Understand & Agree',
          enabled: true,
          primary: primary,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildFeatureBullet(IconData icon, String title, String desc, Color primary, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadyPage(Color primary, bool isDarkMode) {
    return _buildPageLayout(
      children: [
        const Text('🌸', style: TextStyle(fontSize: 58)),
        const SizedBox(height: 22),
        Text(
          'You\'re Ready!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bud is prepared with your personalized settings.\nLet\'s start creating your calm space.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        _buildActionButton(
          label: 'Open Pillow Bud',
          enabled: true,
          primary: primary,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildPageLayout({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool enabled,
    required Color primary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 320,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? primary : primary.withValues(alpha: 0.35),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
