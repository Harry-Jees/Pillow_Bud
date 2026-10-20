import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

enum BiometricHardwareStatus {
  notSupported,
  notEnrolled,
  ready,
}

/// Handles biometric / system-level authentication for Pillow Bud.
///
/// Supports Android (fingerprint/face), iOS (Face ID/Touch ID),
/// Windows Hello, and macOS Touch ID. On unsupported platforms (Web)
/// the guard is skipped.
class BiometricService {
  static final _auth = LocalAuthentication();
  static const _enabledKey = 'biometric_enabled';
  static const _lastAuthKey = 'last_auth_ms';

  /// Detailed hardware & enrollment check.
  static Future<BiometricHardwareStatus> checkHardwareStatus() async {
    if (kIsWeb) return BiometricHardwareStatus.notSupported;
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;

      if (!isSupported && !canCheck) {
        return BiometricHardwareStatus.notSupported;
      }

      final biometrics = await _auth.getAvailableBiometrics();
      if (biometrics.isNotEmpty) {
        return BiometricHardwareStatus.ready;
      } else if (isSupported || canCheck) {
        return BiometricHardwareStatus.notEnrolled;
      } else {
        return BiometricHardwareStatus.notEnrolled;
      }
    } catch (e) {
      debugPrint('BiometricService check error: $e');
      return BiometricHardwareStatus.notEnrolled;
    }
  }

  /// Returns whether the device can use biometrics or device credentials.
  static Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    final status = await checkHardwareStatus();
    return status != BiometricHardwareStatus.notSupported;
  }

  /// Returns whether enrolled biometrics are configured and ready.
  static Future<bool> isEnrolled() async {
    final status = await checkHardwareStatus();
    return status == BiometricHardwareStatus.ready;
  }

  /// Returns the list of enrolled biometric types.
  static Future<List<BiometricType>> availableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Whether the user has enabled biometric lock in settings.
  static Future<bool> isEnabled() async {
    final val = await SecureKeyStorage.read(_enabledKey);
    return val == 'true';
  }

  /// Persists the user's biometric preference.
  static Future<void> setEnabled(bool enabled) async {
    await SecureKeyStorage.write(_enabledKey, enabled.toString());
    if (enabled) {
      // Record current time as last authenticated so launch doesn't loop
      await _recordAuthTime();
    }
  }

  /// Triggers biometric authentication. Returns true on success.
  static Future<bool> authenticate({String reason = 'Unlock Pillow Bud'}) async {
    if (kIsWeb) return true;
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow system PIN/password/Windows Hello fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (authenticated) await _recordAuthTime();
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('BiometricService PlatformException: ${e.code} - ${e.message}');
      if (e.code == 'NotEnrolled' || e.code == 'NotAvailable' || e.code == 'PasscodeNotSet') {
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('BiometricService error: $e');
      return false;
    }
  }

  /// Returns true if the session is still within the 90-second window.
  static Future<bool> isSessionValid() async {
    final raw = await SecureKeyStorage.read(_lastAuthKey);
    if (raw == null) return false;
    final lastMs = int.tryParse(raw) ?? 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastMs;
    return elapsed < 90 * 1000; // 1.5 minutes
  }

  /// Call this whenever the app comes to the foreground.
  /// Returns true if the user is authenticated (either valid session or fresh auth).
  static Future<bool> ensureAuthenticated() async {
    if (!await isEnabled()) return true; // feature disabled → let through
    if (await isSessionValid()) return true;
    return authenticate();
  }

  static Future<void> _recordAuthTime() async {
    await SecureKeyStorage.write(
      _lastAuthKey,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
}
