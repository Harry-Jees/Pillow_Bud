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

  /// Loads the OS-stored key before any synchronous encrypted preference access.
  static Future<void> initialize() async {
    await _getEncrypter();
  }

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
    await _getEncrypter();
    return encryptSync(plainText);
  }

  /// Synchronous encryption for already-initialized local preference storage.
  static Map<String, String> encryptSync(String plainText) {
    if (plainText.isEmpty) return {'ciphertext': '', 'iv': ''};
    final encrypter = _encrypter;
    if (encrypter == null || _macKey == null) {
      throw StateError('EncryptionService.initialize() must run first.');
    }
    final iv = enc.IV.fromSecureRandom(16);
    final ciphertext = encrypter.encrypt(plainText, iv: iv).base64;
    final ivBase64 = iv.base64;
    return {
      'ciphertext': ciphertext,
      'iv': '$ivBase64.${_macFor(ivBase64, ciphertext)}',
    };
  }

  /// Synchronous authenticated decryption for already-initialized local storage.
  static String decryptSync({
    required String ciphertext,
    required String ivBase64,
  }) {
    if (ciphertext.isEmpty) return '';
    final encrypter = _encrypter;
    if (encrypter == null || _macKey == null) {
      throw StateError('EncryptionService.initialize() must run first.');
    }
    final separator = ivBase64.indexOf('.');
    if (separator < 0) {
      throw const FormatException('Unauthenticated encrypted record is not accepted here.');
    }
    final iv = ivBase64.substring(0, separator);
    final suppliedMac = ivBase64.substring(separator + 1);
    if (!_constantTimeEquals(suppliedMac, _macFor(iv, ciphertext))) {
      throw const FormatException('Encrypted record authentication failed.');
    }
    try {
      return encrypter.decrypt(
        enc.Encrypted.fromBase64(ciphertext),
        iv: enc.IV.fromBase64(iv),
      );
    } catch (_) {
      throw const FormatException('Encrypted record is invalid or corrupted.');
    }
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
