import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

/// Encrypts local records with AES-256-CBC and encrypt-then-MAC authentication.
///
/// New records store the IV and HMAC-SHA256 tag together in the `iv` field
/// as `<base64-iv>.<hex-mac>`. Records written by older versions (a plain
/// Base64 IV) remain readable for migration, but are not authenticated.
class EncryptionService {
  static enc.Encrypter? _encrypter;
  static List<int>? _macKey;

  static Future<enc.Encrypter> _getEncrypter() async {
    if (_encrypter != null) return _encrypter!;

    final rawKey = await SecureKeyStorage.getOrCreateMasterKey();
    final keyBytes = sha256.convert(utf8.encode(rawKey)).bytes;
    _macKey = sha256.convert(utf8.encode('$rawKey:pillow-bud-record-mac-v1')).bytes;
    _encrypter = enc.Encrypter(
      enc.AES(enc.Key(Uint8List.fromList(keyBytes)), mode: enc.AESMode.cbc),
    );
    return _encrypter!;
  }

  static String _macFor(String ivBase64, String ciphertext) {
    final key = _macKey;
    if (key == null) throw StateError('Encryption keys have not been initialized.');
    return Hmac(sha256, key).convert(utf8.encode('$ivBase64:$ciphertext')).toString();
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return difference == 0;
  }

  /// Encrypts text and returns a Base64 ciphertext and authenticated IV value.
  static Future<Map<String, String>> encrypt(String plainText) async {
    if (plainText.isEmpty) return {'ciphertext': '', 'iv': ''};

    final encrypter = await _getEncrypter();
    final iv = enc.IV.fromSecureRandom(16);
    final ciphertext = encrypter.encrypt(plainText, iv: iv).base64;
    final ivBase64 = iv.base64;
    return {
      'ciphertext': ciphertext,
      'iv': '$ivBase64.${_macFor(ivBase64, ciphertext)}',
    };
  }

  /// Decrypts and authenticates a record. Corrupt/tampered data fails closed.
  static Future<String> decrypt({
    required String ciphertext,
    required String ivBase64,
  }) async {
    if (ciphertext.isEmpty) return '';

    final encrypter = await _getEncrypter();
    final separator = ivBase64.indexOf('.');
    final iv = separator < 0 ? ivBase64 : ivBase64.substring(0, separator);

    if (separator >= 0) {
      final suppliedMac = ivBase64.substring(separator + 1);
      final expectedMac = _macFor(iv, ciphertext);
      if (!_constantTimeEquals(suppliedMac, expectedMac)) {
        throw const FormatException('Encrypted record authentication failed.');
      }
    }

    try {
      return encrypter.decrypt(
        enc.Encrypted.fromBase64(ciphertext),
        iv: enc.IV.fromBase64(iv),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Encrypted record is invalid or corrupted.');
    }
  }

  /// Resets cached key material (primarily for tests).
  static void reset() {
    _encrypter = null;
    _macKey = null;
  }
}
