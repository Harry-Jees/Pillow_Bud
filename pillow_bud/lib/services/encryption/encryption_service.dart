import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

/// Handles cryptographic encryption and decryption of local database records.
/// Uses AES-256 with PKCS7 padding and cryptographic IVs per record.
class EncryptionService {
  static enc.Encrypter? _encrypter;

  static Future<enc.Encrypter> _getEncrypter() async {
    if (_encrypter != null) return _encrypter!;

    final rawKey = await SecureKeyStorage.getOrCreateMasterKey();
    // Derive exactly 32 bytes (256 bits) using SHA-256
    final keyBytes = sha256.convert(utf8.encode(rawKey)).bytes;
    final key = enc.Key(Uint8List.fromList(keyBytes));

    _encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return _encrypter!;
  }

  /// Encrypts plain text into a Base64 ciphertext and a Base64 IV.
  static Future<Map<String, String>> encrypt(String plainText) async {
    if (plainText.isEmpty) {
      return {'ciphertext': '', 'iv': ''};
    }
    final encrypter = await _getEncrypter();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return {
      'ciphertext': encrypted.base64,
      'iv': iv.base64,
    };
  }

  /// Decrypts Base64 ciphertext using the corresponding Base64 IV.
  static Future<String> decrypt({
    required String ciphertext,
    required String ivBase64,
  }) async {
    if (ciphertext.isEmpty) return '';
    try {
      final encrypter = await _getEncrypter();
      final iv = enc.IV.fromBase64(ivBase64);
      final encrypted = enc.Encrypted.fromBase64(ciphertext);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // Return raw string or error fallback in case of corruption
      return ciphertext;
    }
  }

  /// Resets the encrypter instance (e.g. for testing)
  static void reset() {
    _encrypter = null;
  }
}
