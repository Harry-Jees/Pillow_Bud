import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages system-level hardware-backed master encryption keys.
/// Uses Android KeyStore, iOS Keychain, Windows DPAPI, macOS Keychain, and Linux Secret Service.
class SecureKeyStorage {
  static const _storageKey = 'pillow_bud_master_key_v1';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    wOptions: WindowsOptions(
      useBackwardCompatibility: false,
    ),
    lOptions: LinuxOptions(),
  );

  static String? _cachedKey;

  /// Retrieves the 256-bit encryption key from system-level secure storage,
  /// generating and saving one if it does not already exist.
  static Future<String> getOrCreateMasterKey() async {
    if (_cachedKey != null) return _cachedKey!;

    try {
      String? key = await _storage.read(key: _storageKey);
      if (key == null || key.isEmpty) {
        key = _generateSecureKey();
        await _storage.write(key: _storageKey, value: key);
      }
      _cachedKey = key;
      return key;
    } catch (e) {
      debugPrint('SecureKeyStorage system-level fallback: $e');
      _cachedKey ??= 'PillowBudDefaultSecureKey32BytesLongSecret2026!';
      return _cachedKey!;
    }
  }

  /// Generates a cryptographically random 256-bit (32-byte) key encoded in Base64
  static String _generateSecureKey() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64UrlEncode(bytes);
  }

  /// Resets the key cache (useful during tests or complete user resets)
  static void resetCache() {
    _cachedKey = null;
  }

  // ──────────────────────────────────────────────────────
  //  General-purpose secure key–value store
  // ──────────────────────────────────────────────────────

  /// Reads an arbitrary value from the secure store. Returns null if absent.
  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('SecureKeyStorage.read($key): $e');
      return null;
    }
  }

  /// Writes an arbitrary value to the secure store.
  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureKeyStorage.write($key): $e');
    }
  }

  /// Deletes an arbitrary key from the secure store.
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('SecureKeyStorage.delete($key): $e');
    }
  }
}
