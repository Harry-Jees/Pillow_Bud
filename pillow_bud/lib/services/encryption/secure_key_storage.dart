import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the master key in the operating system's secure credential store.
///
/// Encryption deliberately fails closed if secure storage is unavailable;
/// there is no embedded/default key fallback.
class SecureKeyStorage {
  static const _storageKey = 'pillow_bud_master_key_v1';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
    wOptions: WindowsOptions(useBackwardCompatibility: false),
    lOptions: LinuxOptions(),
  );

  static String? _cachedKey;

  /// Returns the persisted 256-bit key, creating it once when necessary.
  static Future<String> getOrCreateMasterKey() async {
    if (_cachedKey != null) return _cachedKey!;

    try {
      var key = await _storage.read(key: _storageKey);
      if (key == null || key.isEmpty) {
        key = _generateSecureKey();
        await _storage.write(key: _storageKey, value: key);
        // Verify persistence before allowing this key to encrypt user data.
        final stored = await _storage.read(key: _storageKey);
        if (stored != key) {
          throw StateError('Secure storage did not persist the encryption key.');
        }
      }
      _cachedKey = key;
      return key;
    } catch (_) {
      debugPrint('SecureKeyStorage: secure key access failed.');
      throw StateError(
        'Pillow Bud cannot access secure key storage. '
        'Sensitive data encryption is unavailable on this device.',
      );
    }
  }

  static String _generateSecureKey() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256), growable: false),
    );
    return base64UrlEncode(bytes);
  }

  @visibleForTesting
  static void setMasterKeyForTesting(String key) {
    _cachedKey = key;
  }

  static void resetCache() {
    _cachedKey = null;
  }

  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      throw StateError('Secure storage read failed.');
    }
  }

  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      throw StateError('Secure storage write failed.');
    }
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      throw StateError('Secure storage delete failed.');
    }
  }
}
