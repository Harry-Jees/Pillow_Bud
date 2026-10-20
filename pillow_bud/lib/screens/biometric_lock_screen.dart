import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/auth/biometric_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';

/// Full-screen lock shown whenever the app requires biometric authentication.
class BiometricLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;
  const BiometricLockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAuth());
  }

  Future<void> _tryAuth() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });
    final success = await BiometricService.authenticate(
      reason: 'Unlock Pillow Bud to keep your data private',
    );
    if (!mounted) return;
    if (success) {
      widget.onUnlocked();
    } else {
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'Authentication failed. Tap to try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF212121) : const Color(0xFFF9F7FD),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 48,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Pillow Bud',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? const Color(0xFFECECF1)
                        : const Color(0xFF1A1225),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your conversations are protected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                if (_isAuthenticating)
                  CircularProgressIndicator(color: primary)
                else
                  GestureDetector(
                    onTap: _tryAuth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _errorMessage != null ? 'Try Again' : 'Authenticate',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await BiometricService.setEnabled(false);
                      widget.onUnlocked();
                    },
                    child: Text(
                      'Bypass & Disable Biometric Lock',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
