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
    // Decrypt each record into a portable payload. The complete payload is
    // encrypted below with the passphrase; import re-encrypts records with the
    // destination installation key before writing them to SQLite.
    final rawChatRows = await DatabaseService.getRawChatMessageRows();
    final rawJournalRows = await DatabaseService.getRawJournalEntryRows();
    final rawMoodRows = await DatabaseService.getRawMoodRows();

    final chatRows = <Map<String, dynamic>>[];
    for (final source in rawChatRows) {
      final row = Map<String, dynamic>.from(source);
      chatRows.add({
        'id': row['id'],
        'session_id': row['session_id'],
        'role': row['role'],
        'text': await _decryptPortableField(row['ciphertext'], row['iv']),
        'timestamp': row['timestamp'],
        'mood': row['mood'] == null
            ? null
            : await _decryptPortableField(row['mood'], row['mood_iv']),
        'intensity': row['intensity'],
      });
    }

    final journalRows = <Map<String, dynamic>>[];
    for (final source in rawJournalRows) {
      final row = Map<String, dynamic>.from(source);
      journalRows.add({
        'id': row['id'],
        'text': await _decryptPortableField(row['ciphertext'], row['iv']),
        'mood': await _decryptPortableField(row['mood'], row['mood_iv']),
        'created_at': row['created_at'],
        'modified_at': row['modified_at'],
      });
    }

    final moodRows = <Map<String, dynamic>>[];
    for (final source in rawMoodRows) {
      final row = Map<String, dynamic>.from(source);
      moodRows.add({
        'id': row['id'],
        'mood': await _decryptPortableField(row['mood'], row['mood_iv']),
        'timestamp': row['timestamp'],
        'note': row['note_ciphertext'] == null
            ? null
            : await _decryptPortableField(row['note_ciphertext'], row['iv']),
      });
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
    final keyMaterial = await _deriveKey(passphrase, salt, 64);
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
      final keyMaterial = await _deriveKey(passphrase, salt, 64);
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
    final chatRows = isPortable
        ? await _encryptPortableChatRows(_validatedRows(data, 'chat_messages'))
        : _validatedRows(data, 'chat_messages');
    final journalRows = isPortable
        ? await _encryptPortableJournalRows(_validatedRows(data, 'journal_entries'))
        : _validatedRows(data, 'journal_entries');
    final moodRows = isPortable
        ? await _encryptPortableMoodRows(_validatedRows(data, 'mood_logs'))
        : _validatedRows(data, 'mood_logs');

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

  static Future<String> _decryptPortableField(
    dynamic ciphertext,
    dynamic iv,
  ) async {
    if (ciphertext is! String || ciphertext.isEmpty) return '';
    // Older metadata fields were plaintext before encryption was introduced.
    if (iv is! String || iv.isEmpty) return ciphertext;
    return EncryptionService.decrypt(ciphertext: ciphertext, ivBase64: iv);
  }

  static Future<List<Map<String, dynamic>>> _encryptPortableChatRows(
    List<Map<String, dynamic>> rows,
  ) async {
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      if (row['id'] is! String || row['session_id'] is! String ||
          row['role'] is! String || row['text'] is! String ||
          row['timestamp'] is! num) {
        throw const FormatException('Portable backup contains an invalid chat record.');
      }
      final text = await EncryptionService.encrypt(row['text'] as String);
      final moodValue = row['mood'];
      final mood = moodValue is String
          ? await EncryptionService.encrypt(moodValue)
          : null;
      result.add({
        'id': row['id'],
        'session_id': row['session_id'],
        'role': row['role'],
        'ciphertext': text['ciphertext'],
        'iv': text['iv'],
        'timestamp': (row['timestamp'] as num).toInt(),
        'mood': mood?['ciphertext'],
        'mood_iv': mood?['iv'],
        'intensity': row['intensity'] is num
            ? (row['intensity'] as num).toDouble()
            : null,
      });
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> _encryptPortableJournalRows(
    List<Map<String, dynamic>> rows,
  ) async {
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      if (row['id'] is! String || row['text'] is! String ||
          row['mood'] is! String || row['created_at'] is! num ||
          row['modified_at'] is! num) {
        throw const FormatException('Portable backup contains an invalid journal record.');
      }
      final text = await EncryptionService.encrypt(row['text'] as String);
      final mood = await EncryptionService.encrypt(row['mood'] as String);
      result.add({
        'id': row['id'],
        'ciphertext': text['ciphertext'],
        'iv': text['iv'],
        'mood': mood['ciphertext'],
        'mood_iv': mood['iv'],
        'created_at': (row['created_at'] as num).toInt(),
        'modified_at': (row['modified_at'] as num).toInt(),
      });
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> _encryptPortableMoodRows(
    List<Map<String, dynamic>> rows,
  ) async {
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      if (row['id'] is! String || row['mood'] is! String ||
          row['timestamp'] is! num) {
        throw const FormatException('Portable backup contains an invalid mood record.');
      }
      final mood = await EncryptionService.encrypt(row['mood'] as String);
      final noteValue = row['note'];
      final note = noteValue is String && noteValue.isNotEmpty
          ? await EncryptionService.encrypt(noteValue)
          : null;
      result.add({
        'id': row['id'],
        'mood': mood['ciphertext'],
        'mood_iv': mood['iv'],
        'timestamp': (row['timestamp'] as num).toInt(),
        'note_ciphertext': note?['ciphertext'],
        'iv': note?['iv'],
      });
    }
    return result;
  }

  static List<int> _secureRandomBytes(int length) {
    final random = math.Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  /// Derive the archive keys off the UI isolate to keep the app responsive.
  static Future<List<int>> _deriveKey(
    String passphrase,
    List<int> salt,
    int length,
  ) {
    return compute(_deriveBackupKeyWorker, {
      'passphrase': passphrase,
      'salt': salt,
      'length': length,
      'iterations': _kdfIterations,
    });
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

/// Isolate entrypoint for PBKDF2-HMAC-SHA256.
List<int> _deriveBackupKeyWorker(Map<String, Object> arguments) {
  final passphrase = arguments['passphrase'] as String;
  final salt = (arguments['salt'] as List).cast<int>();
  final length = arguments['length'] as int;
  final iterations = arguments['iterations'] as int;
  final hmac = Hmac(sha256, utf8.encode(passphrase));
  final output = <int>[];
  var blockIndex = 1;
  while (output.length < length) {
    final blockInput = <int>[
      ...salt,
      (blockIndex >> 24) & 255,
      (blockIndex >> 16) & 255,
      (blockIndex >> 8) & 255,
      blockIndex & 255,
    ];
    var u = hmac.convert(blockInput).bytes;
    final accumulator = List<int>.from(u);
    for (var round = 1; round < iterations; round++) {
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
