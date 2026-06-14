import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pillow_bud/config/constants.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/services/storage_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final memberSince = StorageService.getOnboardingCompletedAt();
    final memberSinceText = memberSince != null
        ? DateFormat.yMMMMd().format(memberSince)
        : 'Today';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  'Member since $memberSinceText',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'About',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem('App Name', 'Pillow Bud'),
          _buildSettingItem('Version', '1.0.0'),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            context,
            title: 'Send feedback',
            subtitle: 'Let us know how Bud is doing',
            icon: Icons.feedback,
            onTap: () => _showInfoDialog(context, 'Feedback',
                'Send feedback to support@pillowbud.app. We appreciate your thoughts.'),
          ),
          _buildActionItem(
            context,
            title: 'App settings',
            subtitle: 'Theme, personality, and preferences',
            icon: Icons.settings,
            onTap: () => _showInfoDialog(context, 'Settings',
                'Settings are not yet available in this build. Coming soon.'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Crisis Resources',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildCrisisResource(context, Constants.icallName, Constants.icallNumber),
          _buildCrisisResource(context, Constants.vandrevalaName, Constants.vandrevalaNumber),
          _buildCrisisResource(context, Constants.aasraName, Constants.aasraNumber),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimaryDark),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildCrisisResource(BuildContext context, String name, String number) {
    return InkWell(
      onTap: () => _showInfoDialog(
        context,
        name,
        'Please call $number for immediate support. You are not alone.',
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const Icon(Icons.call, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimaryDark)),
        content: Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
