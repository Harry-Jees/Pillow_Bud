import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pillow_bud/models/user_preference.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/llm_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/ai/model_download_service.dart';
import 'package:pillow_bud/services/auth/biometric_service.dart';
import 'package:pillow_bud/services/backup/backup_service.dart';
import 'package:pillow_bud/services/crisis_detector.dart';
import 'package:pillow_bud/services/database/database_service.dart';
import 'package:pillow_bud/services/notifications/notification_service.dart';
import 'package:pillow_bud/services/storage_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = false;
  BiometricHardwareStatus _biometricHardwareStatus =
      BiometricHardwareStatus.notSupported;
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hwStatus = await BiometricService.checkHardwareStatus();
    final biometricEnabled = await BiometricService.isEnabled();
    final notificationsEnabled = await NotificationService.isEnabled();
    final reminderTime = await NotificationService.getReminderTime();
    if (mounted) {
      setState(() {
        _biometricHardwareStatus = hwStatus;
                _biometricEnabled = biometricEnabled;
        _notificationsEnabled = notificationsEnabled;
        _reminderTime = reminderTime;
      });
    }
  }

  Future<void> _updatePersonality(String mode) async {
    ref.read(buddyPersonalityProvider.notifier).state = mode;
    await StorageService.setBuddyPersonality(mode);
    final userPref = ref.read(userPreferenceProvider);
    final updated = UserPreference(
      userName: userPref.userName,
      buddyPersonality: mode,
      isDarkMode: userPref.isDarkMode,
      primaryColor: userPref.primaryColor,
      secondaryColor: userPref.secondaryColor,
      onboardingCompleted: userPref.onboardingCompleted,
      onboardingCompletedAt: userPref.onboardingCompletedAt,
    );
    ref.read(userPreferenceProvider.notifier).state = updated;
    try {
      await DatabaseService.savePreferences(updated);
    } catch (_) {}
  }

  Future<void> _updateTheme(String themeKey) async {
    ref.read(themeProvider.notifier).state = themeKey;
    await StorageService.saveTheme(themeKey);
  }

  Future<void> _toggleDarkMode(bool isDark) async {
    ref.read(isDarkModeProvider.notifier).state = isDark;
    await StorageService.setDarkMode(isDark);
  }

  void _triggerModelDownload() {
    ModelDownloadService.startDownload(
      onComplete: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _pauseModelDownload() {
    ModelDownloadService.pauseDownload();
    if (mounted) setState(() {});
  }

  void _resumeModelDownload() {
    ModelDownloadService.resumeDownload(
      onComplete: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _deleteModel() async {
    await ModelDownloadService.deleteModel();
    if (mounted) setState(() {});
  }

  void _showBiometricSetupDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Set Up System Security',
                style: TextStyle(fontFamily: 'Lora', fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No Fingerprint, Face ID, or PIN passkey was detected on this device.\n\n'
              'To enable Biometric Lock for Pillow Bud:',
              style:
                  TextStyle(fontFamily: 'DM Sans', fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '📱 Android: Settings → Security → Biometrics / Lock Screen',
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 12)),
                  SizedBox(height: 6),
                  Text(
                      '🪟 Windows: Settings → Accounts → Sign-in options → Windows Hello / PIN',
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 12)),
                  SizedBox(height: 6),
                  Text('🍎 iOS: Settings → Face ID & Passcode',
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await BiometricService.authenticate(
                reason: 'Verify system credentials for Pillow Bud',
              );
              if (success) {
                await BiometricService.setEnabled(true);
                await _loadSettings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Biometric Lock enabled successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } else {
                await _loadSettings();
              }
            },
            child: const Text('Verify & Enable Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final hwStatus = await BiometricService.checkHardwareStatus();
      if (hwStatus == BiometricHardwareStatus.notSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Biometric / Windows Hello hardware is not available on this device.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      if (hwStatus == BiometricHardwareStatus.notEnrolled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Biometrics / PIN not set up in system settings yet. Please add a Fingerprint, Face ID, or PIN in your device security settings.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        await BiometricService.authenticate(
            reason: 'Configure device security for Pillow Bud');
        await _loadSettings();
        return;
      }
      final success = await BiometricService.authenticate(
        reason: 'Verify your identity to enable biometric lock',
      );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Authentication was cancelled or failed. Please check your system security settings.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    }
    await BiometricService.setEnabled(value);
    if (mounted) setState(() => _biometricEnabled = value);
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Notification permission denied. Enable it in Settings.'),
            ),
          );
        }
        return;
      }
    }
    await NotificationService.setEnabled(value, time: _reminderTime);
    if (mounted) setState(() => _notificationsEnabled = value);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null) return;
    setState(() => _reminderTime = picked);
    await NotificationService.scheduleDailyReminder(picked);
  }

  Future<void> _exportBackup() async {
    final passphrase = await _requestBackupPassphrase(
      title: 'Protect your backup',
      description: 'Create a passphrase with at least 10 characters. You will need it to restore this backup on any device. Pillow Bud cannot recover a forgotten passphrase.',
      confirm: true,
    );
    if (passphrase == null || !mounted) return;

    setState(() => _isExporting = true);
    try {
      final file = await BackupService.exportData(passphrase: passphrase);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Pillow Bud Encrypted Backup',
        text: 'Pillow Bud encrypted backup. Keep your passphrase separate and private.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<String?> _requestBackupPassphrase({
    required String title,
    required String description,
    required bool confirm,
  }) async {
    final controller = TextEditingController();
    final confirmation = TextEditingController();
    String? result;
    try {
      result = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Backup passphrase',
                    helperText: 'At least 10 characters',
                  ),
                ),
                if (confirm) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmation,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Confirm passphrase',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text;
                if (value.trim().length < 10 ||
                    (confirm && value != confirmation.text)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(value.trim().length < 10
                          ? 'Use at least 10 characters.'
                          : 'The passphrases do not match.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: Text(confirm ? 'Encrypt Backup' : 'Unlock Backup'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
      confirmation.dispose();
    }
    return result;
  }

  Future<void> _importBackup() async {
    // Authenticate before import
    final isEnabled = await BiometricService.isEnabled();
    if (isEnabled) {
      final ok = await BiometricService.authenticate(
        reason: 'Authenticate to restore your backup',
      );
      if (!ok) return;
    }

    setState(() => _isImporting = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final prefix = await file.openRead(0, 5).transform(utf8.decoder).join();
      final isLegacyBackup = prefix.startsWith('PBv2:');
      final passphrase = isLegacyBackup
          ? ''
          : await _requestBackupPassphrase(
              title: 'Unlock backup',
              description: 'Enter the passphrase used when this backup was created.',
              confirm: false,
            );
      if (passphrase == null || !mounted) return;
      final importResult = await BackupService.importData(
        file,
        passphrase: passphrase,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Restored ${importResult.chats} messages, ${importResult.journals} journal entries, and ${importResult.moods} mood check-ins.',
            ),
          ),
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid backup: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);
    final buddyPersonality = ref.watch(buddyPersonalityProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final activeTheme = ref.watch(themeProvider);
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    final memberSince = StorageService.getOnboardingCompletedAt();
    final memberSinceText = memberSince != null
        ? DateFormat.yMMMMd().format(memberSince)
        : 'Recently';

    final displayName = userName.isNotEmpty ? userName : 'Pillow Bud Friend';

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color:
                isDarkMode ? const Color(0xFFECECF1) : const Color(0xFF1A1225),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. User Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary,
                          themeColors['secondary'] ?? AppColors.secondary
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? const Color(0xFFECECF1)
                          : const Color(0xFF1A1225),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member since $memberSinceText',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 2. Local AI Model Download & Management Dashboard
            Text(
              'ON-DEVICE AI MODEL (QWEN3 4B INSTRUCT)',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<ModelDownloadStatus>(
              valueListenable: ModelDownloadService.statusNotifier,
              builder: (context, status, _) {
                final isDownloaded = status == ModelDownloadStatus.downloaded;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0x18FFFFFF)
                          : const Color(0x12000000),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDownloaded
                                  ? AppColors.success.withValues(alpha: 0.18)
                                  : primary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isDownloaded
                                  ? Icons.check_circle_rounded
                                  : Icons.memory_rounded,
                              color: isDownloaded ? AppColors.success : primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Qwen3 4B Instruct GGUF',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode
                                        ? const Color(0xFFECECF1)
                                        : const Color(0xFF1A1225),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ValueListenableBuilder<String>(
                                  valueListenable: ModelDownloadService
                                      .statusMessageNotifier,
                                  builder: (context, msg, _) {
                                    return Text(
                                      msg,
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11,
                                        color: isDarkMode
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (status == ModelDownloadStatus.downloading ||
                          status == ModelDownloadStatus.paused) ...[
                        const SizedBox(height: 14),
                        ValueListenableBuilder<double>(
                          valueListenable:
                              ModelDownloadService.progressNotifier,
                          builder: (context, prog, _) {
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: prog > 0 ? prog : null,
                                    backgroundColor: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.08),
                                    color: primary,
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(prog * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: primary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (status ==
                                            ModelDownloadStatus.downloading)
                                          ElevatedButton.icon(
                                            onPressed: _pauseModelDownload,
                                            icon: const Icon(
                                                Icons.pause_rounded,
                                                size: 14),
                                            label: const Text('Pause',
                                                style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                            ),
                                          )
                                        else
                                          ElevatedButton.icon(
                                            onPressed: _resumeModelDownload,
                                            icon: const Icon(
                                                Icons.play_arrow_rounded,
                                                size: 14),
                                            label: const Text('Resume',
                                                style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primary,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                            ),
                                          ),
                                        const SizedBox(width: 6),
                                        TextButton(
                                          onPressed: ModelDownloadService
                                              .cancelDownload,
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            if (!isDownloaded)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _triggerModelDownload,
                                  icon: const Icon(Icons.download_rounded,
                                      size: 18),
                                  label: const Text('Download Model (~700 MB)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              )
                            else ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _deleteModel,
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      size: 18, color: AppColors.danger),
                                  label: const Text(
                                    'Reclaim Storage',
                                    style: TextStyle(color: AppColors.danger),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.danger),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // 3. Security & System-Level Storage Status
            Text(
              'SECURITY & SYSTEM STORAGE',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: AppColors.success, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AES-256 SQLite3 Encrypted',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode
                                    ? const Color(0xFFECECF1)
                                    : const Color(0xFF1A1225),
                              ),
                            ),
                            Text(
                              'Hardware-backed system keys (Android KeyStore / iOS Keychain / Windows DPAPI)',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

                        // 3b. Biometric Lock (Always visible on mobile/desktop)
            if (!kIsWeb) ...[
              Text(
                'BIOMETRIC LOCK',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: isDarkMode
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0x18FFFFFF)
                        : const Color(0x12000000),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _biometricEnabled
                                ? AppColors.success.withValues(alpha: 0.15)
                                : primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fingerprint_rounded,
                            color: _biometricEnabled ? AppColors.success : primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Biometric / System Lock',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode
                                      ? const Color(0xFFECECF1)
                                      : const Color(0xFF1A1225),
                                ),
                              ),
                              Text(
                                _biometricHardwareStatus ==
                                        BiometricHardwareStatus.notEnrolled
                                    ? '⚠️ Hardware available, but biometrics/PIN not set up in OS settings'
                                    : 'Lock after 1.5 min of inactivity',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _biometricEnabled,
                          activeThumbColor: AppColors.success,
                          onChanged: _toggleBiometric,
                        ),
                      ],
                    ),
                    if (!_biometricEnabled ||
                        _biometricHardwareStatus ==
                            BiometricHardwareStatus.notEnrolled) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showBiometricSetupDialog,
                          icon: const Icon(Icons.settings_suggest_rounded,
                              size: 18),
                          label:
                              const Text('Set Up / Configure System Passkey'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

// 3c. Daily Notification
            Text(
              'DAILY CHECK-IN',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.notifications_rounded,
                            color: primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Reflection Reminder',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode
                                    ? const Color(0xFFECECF1)
                                    : const Color(0xFF1A1225),
                              ),
                            ),
                            Text(
                              'Gentle nudge to share your day with Bud',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        activeThumbColor: primary,
                        onChanged: _toggleNotifications,
                      ),
                    ],
                  ),
                  if (_notificationsEnabled) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _pickReminderTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: primary.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reminder Time',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? const Color(0xFFECECF1)
                                    : const Color(0xFF1A1225),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _reminderTime.format(context),
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.edit_rounded,
                                    color: primary, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 3d. Backup & Restore
            Text(
              'BACKUP & RESTORE',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your data is exported as an encrypted `.pillowbak` file that only Pillow Bud can read.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportBackup,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.upload_rounded, size: 18),
                          label: Text(
                              _isExporting ? 'Exporting...' : 'Export Backup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isImporting ? null : _importBackup,
                          icon: _isImporting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: primary),
                                )
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                              _isImporting ? 'Importing...' : 'Import Backup'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 4. Bud Personality Mode
            Text(
              'BUD\'S PERSONALITY',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                children: [
                  _buildPersonalityTile(
                    title: 'Balanced',
                    subtitle:
                        'Harmonious blend of validation, inquiry, and wisdom',
                    mode: 'balanced',
                    currentMode: buddyPersonality,
                    primary: primary,
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildPersonalityTile(
                    title: 'Gentle',
                    subtitle:
                        'Soft, reassuring, validating with minimal questions',
                    mode: 'gentle',
                    currentMode: buddyPersonality,
                    primary: primary,
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildPersonalityTile(
                    title: 'Curious',
                    subtitle: 'Warm, exploratory questions to reflect deeply',
                    mode: 'curious',
                    currentMode: buddyPersonality,
                    primary: primary,
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildPersonalityTile(
                    title: 'Wise',
                    subtitle:
                        'Philosophical, thoughtful perspective without judgment',
                    mode: 'wise',
                    currentMode: buddyPersonality,
                    primary: primary,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 5. Theme & Appearance
            Text(
              'THEME & APPEARANCE',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dark Theme',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? const Color(0xFFECECF1)
                              : const Color(0xFF1A1225),
                        ),
                      ),
                      Switch(
                        value: isDarkMode,
                        activeThumbColor: primary,
                        onChanged: (val) => _toggleDarkMode(val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Color Scheme Preset',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: themePresets.entries.map((entry) {
                      final key = entry.key;
                      final name = entry.value['name'] as String;
                      final pCol = entry.value['primary'] as Color;
                      final isSelected = activeTheme == key;

                      return GestureDetector(
                        onTap: () => _updateTheme(key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? pCol.withValues(alpha: 0.22)
                                : (isDarkMode
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : const Color(0xFFF8F6FF)),
                            border: Border.all(
                              color: isSelected
                                  ? pCol
                                  : (isDarkMode
                                      ? const Color(0x18FFFFFF)
                                      : const Color(0x12000000)),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: pCol,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? pCol
                                      : (isDarkMode
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 6. Crisis Helplines
            Text(
              'CRISIS & HELPLINE SUPPORT',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                children: CrisisDetector.getResources().map((resource) {
                  return ListTile(
                    title: Text(
                      resource['name']!,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? const Color(0xFFECECF1)
                            : const Color(0xFF1A1225),
                      ),
                    ),
                    subtitle: Text(
                      '${resource['number']} • ${resource['desc']}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    trailing:
                        Icon(Icons.call_rounded, color: primary, size: 20),
                    onTap: () {
                      _showResourceDialog(
                          context, resource, isDarkMode, primary);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // 7. Privacy & Build Specs
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security_rounded,
                          size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        '100% Private, Local & Cross-Platform',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? const Color(0xFFECECF1)
                              : const Color(0xFF1A1225),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Built with Material 3 for Android, iOS, Windows, macOS, Linux, and Web. Zero analytics trackers and zero third-party cloud uploads.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pillow Bud v1.0.0+1',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: isDarkMode
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                      Text(
                        'Apache 2.0 Open Source',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: isDarkMode
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityTile({
    required String title,
    required String subtitle,
    required String mode,
    required String currentMode,
    required Color primary,
    required bool isDarkMode,
  }) {
    final isSelected = currentMode == mode;

    return ListTile(
      onTap: () => _updatePersonality(mode),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected
            ? primary
            : (isDarkMode ? Colors.white38 : Colors.black38),
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? primary
              : (isDarkMode
                  ? const Color(0xFFECECF1)
                  : const Color(0xFF1A1225)),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 11,
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDarkMode ? const Color(0x14FFFFFF) : const Color(0x0C000000),
    );
  }

  void _showResourceDialog(BuildContext context, Map<String, String> resource,
      bool isDarkMode, Color primary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          resource['name']!,
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Call: ${resource['number']}',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resource['desc']!,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
            ),
          ],
        ),
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
