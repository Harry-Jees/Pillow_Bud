import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';
import 'package:pillow_bud/services/encryption/encryption_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pillow_bud/services/database/database_service.dart';

/// Creates portable, passphrase-protected backups of encrypted database rows.
///
/// PBv3 encrypts the complete archive, including metadata, with a key derived
/// from the user's passphrase and authenticates it before decryption. PBv2 is
/// accepted for same-installation backward compatibility only.
class BackupService {
  static const _magic = 'PBv3:';
  static const _legacyMagic = 'PBv2:';
  static const _kdfIterations = 120000;

  // ──────────────────────────────────────────────────────────
  //  EXPORT
  // ──────────────────────────────────────────────────────────

  /// Exports an encrypted `.pillowbak` file to the device cache directory.
  ///
  /// Returns the [File] so the caller can share or save it.
  static Future<File> exportData({required String passphrase}) async {
    if (passphrase.trim().length < 10) {
      throw ArgumentError('Use a backup passphrase with at least 10 characters.');
    }
    // 1. Fetch raw (already-encrypted) rows – no decryption needed.
    final chatRows = (await DatabaseService.getRawChatMessageRows())
        .map(Map<String, dynamic>.from)
        .toList();
    final journalRows = (await DatabaseService.getRawJournalEntryRows())
        .map(Map<String, dynamic>.from)
        .toList();
    final moodRows = (await DatabaseService.getRawMoodRows())
        .map(Map<String, dynamic>.from)
        .toList();

    // Encrypt legacy plaintext mood metadata before it enters an export.
    for (final row in chatRows) {
      final mood = row['mood'];
      if (mood is String && mood.isNotEmpty && row['mood_iv'] == null) {
        final encrypted = await EncryptionService.encrypt(mood);
        row['mood'] = encrypted['ciphertext'];
        row['mood_iv'] = encrypted['iv'];
      }
    }
    for (final row in journalRows) {
      final mood = row['mood'];
      if (mood is String && mood.isNotEmpty && row['mood_iv'] == null) {
        final encrypted = await DatabaseService.encryptBackupField(mood);
        row['mood'] = encrypted['ciphertext'];
        row['mood_iv'] = encrypted['iv'];
      }
    }
    for (final row in moodRows) {
      final mood = row['mood'];
      if (mood is String && mood.isNotEmpty && row['mood_iv'] == null) {
        final encrypted = await DatabaseService.encryptBackupField(mood);
        row['mood'] = encrypted['ciphertext'];
        row['mood_iv'] = encrypted['iv'];
      }
    }

    // The complete archive, including metadata, is encrypted with a key
    // derived from the user's passphrase. This makes backups portable across
    // installations without exposing record metadata in the file.
    final payload = jsonEncode({
      'version': 3,
      'exported_at': DateTime.now().toIso8601String(),
      'chat_messages': chatRows,
      'journal_entries': journalRows,
      'mood_logs': moodRows,
    });
    final salt = _secureRandomBytes(16);
    final ivBytes = _secureRandomBytes(16);
    final keyMaterial = _deriveKey(passphrase, salt, 64);
    final encryptionKey = enc.Key(Uint8List.fromList(keyMaterial.sublist(0, 32)));
    final macKey = keyMaterial.sublist(32, 64);
    final iv = enc.IV(Uint8List.fromList(ivBytes));
    final encrypter = enc.Encrypter(enc.AES(encryptionKey, mode: enc.AESMode.cbc));
    final ciphertext = encrypter.encrypt(payload, iv: iv).bytes;
    final authenticatedBytes = <int>[
      ...utf8.encode('PBv3'),
      ...salt,
      ...ivBytes,
      ...ciphertext,
    ];
    final mac = Hmac(sha256, macKey).convert(authenticatedBytes).bytes;
    final archive = jsonEncode({
      'version': 3,
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _kdfIterations,
      'salt': base64Encode(salt),
      'iv': base64Encode(ivBytes),
      'ciphertext': base64Encode(ciphertext),
      'mac': base64Encode(mac),
    });

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/pillow_bud_backup_$timestamp.pillowbak');
    await file.writeAsString('$_magic${base64Encode(utf8.encode(archive))}', flush: true);

    debugPrint('BackupService: exported ${chatRows.length} messages to ${file.path}');
    return file;
  }

  // ──────────────────────────────────────────────────────────
  //  IMPORT
  // ──────────────────────────────────────────────────────────

  /// Imports a passphrase-protected portable backup or a legacy PBv2 backup.
  ///
  /// Throws [FormatException] for invalid files.
  /// Returns an [ImportResult] with per-table counts.
  static Future<ImportResult> importData(
    File file, {
    required String passphrase,
  }) async {
    final raw = await file.readAsString();

    final isPortable = raw.startsWith(_magic);
    final isLegacy = raw.startsWith(_legacyMagic);
    if (!isPortable && !isLegacy) {
      throw const FormatException('Not a valid Pillow Bud backup file.');
    }

    final prefix = isPortable ? _magic : _legacyMagic;
    final encoded = raw.substring(prefix.length);
    late Map<String, dynamic> data;
    try {
      final decoded = utf8.decode(base64Decode(encoded));
      data = jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to decode backup: $e');
    }

    if (isPortable) {
      final salt = _decodeBackupBytes(data, 'salt');
      final ivBytes = _decodeBackupBytes(data, 'iv');
      final ciphertext = _decodeBackupBytes(data, 'ciphertext');
      final suppliedMac = _decodeBackupBytes(data, 'mac');
      if (salt.length != 16 || ivBytes.length != 16 || suppliedMac.length != 32 ||
          ciphertext.isEmpty || ciphertext.length % 16 != 0) {
        throw const FormatException('Backup archive is malformed.');
      }
      final iterations = data['iterations'];
      if (iterations != _kdfIterations || data['kdf'] != 'PBKDF2-HMAC-SHA256') {
        throw const FormatException('Unsupported backup encryption settings.');
      }
      final keyMaterial = _deriveKey(passphrase, salt, 64);
      final expectedMac = Hmac(sha256, keyMaterial.sublist(32, 64)).convert([
        ...utf8.encode('PBv3'),
        ...salt,
        ...ivBytes,
        ...ciphertext,
      ]).bytes;
      if (!_constantTimeEquals(suppliedMac, expectedMac)) {
        throw const FormatException(
          'Incorrect passphrase or damaged backup file. Nothing was restored.',
        );
      }
      try {
        final encrypter = enc.Encrypter(enc.AES(
          enc.Key(Uint8List.fromList(keyMaterial.sublist(0, 32))),
          mode: enc.AESMode.cbc,
        ));
        final plaintext = encrypter.decrypt(
          enc.Encrypted(Uint8List.fromList(ciphertext)),
          iv: enc.IV(Uint8List.fromList(ivBytes)),
        );
        data = jsonDecode(plaintext) as Map<String, dynamic>;
      } catch (_) {
        throw const FormatException('Backup could not be decrypted or is damaged.');
      }
      if (data['version'] != 3) {
        throw const FormatException('Unsupported portable backup version.');
      }
    } else {
      // Legacy PBv2 backups are installation-bound and are accepted only when
      // their original secure-storage key is still available.
      if ((data['version'] as int? ?? 0) != 2) {
        throw const FormatException('Unsupported legacy backup version.');
      }
      final masterKey = await SecureKeyStorage.getOrCreateMasterKey();
      final expectedFingerprint = sha256.convert(utf8.encode(masterKey)).toString();
      if (data['key_fingerprint'] != expectedFingerprint) {
        throw const FormatException(
          'This older backup belongs to a different installation. Create a new portable backup on the original device.',
        );
      }
    }

    // Validate the entire archive structure before writing any rows. Without
    // this preflight, a malformed later table could leave an accidental partial
    // restore even when the file is rejected.
    final chatRows = _validatedRows(data, 'chat_messages');
    final journalRows = _validatedRows(data, 'journal_entries');
    final moodRows = _validatedRows(data, 'mood_logs');

    // Restore every table in a single SQLite transaction. A malformed row or
    // schema mismatch rolls back the complete import instead of silently
    // leaving a partially restored database.
    await DatabaseService.restoreRawRowsTransaction(
      rowsByTable: {
        'chat_messages': chatRows,
        'journal_entries': journalRows,
        'mood_logs': moodRows,
      },
    );

    debugPrint(
      'BackupService: imported ${chatRows.length} chats, '
      '${journalRows.length} journals, ${moodRows.length} moods.',
    );
    return ImportResult(
      chats: chatRows.length,
      journals: journalRows.length,
      moods: moodRows.length,
    );
  }

  static List<int> _secureRandomBytes(int length) {
    final random = math.Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  /// PBKDF2-HMAC-SHA256; returns [length] derived bytes.
  static List<int> _deriveKey(String passphrase, List<int> salt, int length) {
    final hmac = Hmac(sha256, utf8.encode(passphrase));
    final output = <int>[];
    var blockIndex = 1;
    while (output.length < length) {
      final blockInput = <int>[...salt, (blockIndex >> 24) & 255,
        (blockIndex >> 16) & 255, (blockIndex >> 8) & 255, blockIndex & 255];
      var u = hmac.convert(blockInput).bytes;
      final accumulator = List<int>.from(u);
      for (var round = 1; round < _kdfIterations; round++) {
        u = hmac.convert(u).bytes;
        for (var i = 0; i < accumulator.length; i++) {
          accumulator[i] ^= u[i];
        }
      }
      output.addAll(accumulator);
      blockIndex++;
    }
    return output.sublist(0, length);
  }

  static List<int> _decodeBackupBytes(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String) throw FormatException('Backup field "$key" is missing.');
    try {
      return base64Decode(value);
    } catch (_) {
      throw FormatException('Backup field "$key" is invalid.');
    }
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }

  static List<Map<String, dynamic>> _validatedRows(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value == null) return <Map<String, dynamic>>[];
    if (value is! List) {
      throw FormatException('Backup field "$key" must be a list.');
    }

    final rows = <Map<String, dynamic>>[];
    for (var index = 0; index < value.length; index++) {
      final row = value[index];
      if (row is! Map) {
        throw FormatException(
          'Backup field "$key" contains an invalid record at index $index.',
        );
      }
      try {
        rows.add(Map<String, dynamic>.from(row));
      } catch (_) {
        throw FormatException(
          'Backup field "$key" contains an invalid record at index $index.',
        );
      }
    }
    return rows;
  }
}

/// Value object returned by [BackupService.importData].
class ImportResult {
  final int chats;
  final int journals;
  final int moods;
  final int skippedChats;
  final int skippedJournals;
  final int skippedMoods;

  const ImportResult({
    required this.chats,
    required this.journals,
    required this.moods,
    this.skippedChats = 0,
    this.skippedJournals = 0,
    this.skippedMoods = 0,
  });

  int get total => chats + journals + moods;
  int get skippedTotal => skippedChats + skippedJournals + skippedMoods;

  @override
  String toString() =>
      'ImportResult(chats: $chats, journals: $journals, moods: $moods, '
      'skipped: $skippedTotal)';
}
