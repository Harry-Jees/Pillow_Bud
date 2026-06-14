import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/llm_provider.dart';
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

  Future<void> _addMemberSince() async {
    final now = DateTime.now();
    await StorageService.setOnboardingCompletedAt(now);
  }

  void _nextPage() async {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    ref.read(userNameProvider.notifier).state = userName.trim();
    ref.read(onboardingCompletedProvider.notifier).state = true;
    ref.read(buddyPersonalityProvider.notifier).state = selectedPersonality;

    await StorageService.setUserName(userName.trim());
    await StorageService.setOnboardingCompleted(true);
    await StorageService.setBuddyPersonality(selectedPersonality);
    await _addMemberSince();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _buildWelcomePage(),
          _buildNamePage(),
          _buildPersonalityPage(),
          _buildDisclaimerPage(),
          _buildReadyPage(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildPageLayout(
      children: [
        const Text(
          'Welcome to Pillow Bud',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your emotional companion, always listening',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 40),
        _buildActionButton(label: 'Begin', enabled: true, onPressed: _nextPage),
      ],
    );
  }

  Widget _buildNamePage() {
    return _buildPageLayout(
      children: [
        const Text(
          'What\'s your name?',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          onChanged: (value) => setState(() => userName = value),
          decoration: InputDecoration(
            hintText: 'Enter your name...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
          ),
          style: const TextStyle(color: AppColors.textPrimaryDark),
          autofocus: true,
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          label: 'Continue',
          enabled: userName.trim().isNotEmpty,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildPersonalityPage() {
    return _buildPageLayout(
      children: [
        const Text(
          'How should Bud be with you?',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            _buildPersonalityOption('Gentle', 'Soft, validating'),
            const SizedBox(height: 12),
            _buildPersonalityOption('Curious', 'Ask questions'),
            const SizedBox(height: 12),
            _buildPersonalityOption('Wise', 'Reflective, thoughtful'),
            const SizedBox(height: 12),
            _buildPersonalityOption('Balanced', 'Mix of all (default)'),
          ],
        ),
        const SizedBox(height: 32),
        _buildActionButton(label: 'Continue', enabled: true, onPressed: _nextPage),
      ],
    );
  }

  Widget _buildPersonalityOption(String title, String subtitle) {
    final isSelected = selectedPersonality == title.toLowerCase();

    return GestureDetector(
      onTap: () => setState(() => selectedPersonality = title.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(14),
            color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerPage() {
    return _buildPageLayout(
      children: [
        const Text(
          'Important',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bud is your emotional companion, not a licensed therapist. For serious mental health concerns, please talk to a professional or call a crisis helpline.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        _buildActionButton(label: 'I understand', enabled: true, onPressed: _nextPage),
      ],
    );
  }

  Widget _buildReadyPage() {
    return _buildPageLayout(
      children: [
        const Text(
          'You\'re all set!',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bud is ready to listen. Let\'s begin.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 40),
        _buildActionButton(label: 'Let\'s go', enabled: true, onPressed: _nextPage),
      ],
    );
  }

  Widget _buildPageLayout({required List<Widget> children}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.35),
        ),
        child: Text(
          label,
          style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
