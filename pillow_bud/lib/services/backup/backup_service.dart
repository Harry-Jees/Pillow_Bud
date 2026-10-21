import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';
import 'package:pillow_bud/services/encryption/encryption_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pillow_bud/services/database/database_service.dart';

/// Exports encrypted database rows with visible metadata; the archive itself is not encrypted.
///
/// Export format: `PBv2:<base64(JSON)>`. This is encoding, not file encryption.
/// The JSON payload contains raw encrypted SQLite rows (ciphertext + iv pairs)
/// so messages are never decrypted during export – they travel as already-encrypted blobs.
class BackupService {
  static const _magic = 'PBv2:';

  // ──────────────────────────────────────────────────────────
  //  EXPORT
  // ──────────────────────────────────────────────────────────

  /// Exports a `.pillowbak` file to the device cache directory. The file is not encrypted.
  ///
  /// Returns the [File] so the caller can share / save it.
  static Future<File> exportData() async {
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

    final masterKey = await SecureKeyStorage.getOrCreateMasterKey();
    final keyFingerprint = sha256.convert(utf8.encode(masterKey)).toString();

    // 2. Bundle into one JSON payload.
    final payload = jsonEncode({
      'version': 2,
      'key_fingerprint': keyFingerprint,
      'exported_at': DateTime.now().toIso8601String(),
      'chat_messages': chatRows,
      'journal_entries': journalRows,
      'mood_logs': moodRows,
    });

    // Base64 is not encryption. Record payloads remain encrypted, but metadata
    // is visible; the UI warns users before exporting.
    final encoded = base64Encode(utf8.encode(payload));

    // 4. Write with magic header to a uniquely named file.
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/pillow_bud_backup_$timestamp.pillowbak');
    await file.writeAsString('$_magic$encoded', flush: true);

    debugPrint('BackupService: exported ${chatRows.length} messages to ${file.path}');
    return file;
  }

  // ──────────────────────────────────────────────────────────
  //  IMPORT
  // ──────────────────────────────────────────────────────────

  /// Imports a same-installation `.pillowbak` file and restores rows into SQLite.
  ///
  /// Throws [FormatException] for invalid files.
  /// Returns an [ImportResult] with per-table counts.
  static Future<ImportResult> importData(File file) async {
    final raw = await file.readAsString();

    if (!raw.startsWith(_magic)) {
      throw const FormatException('Not a valid Pillow Bud backup file.');
    }

    final encoded = raw.substring(_magic.length);

    late Map<String, dynamic> data;
    try {
      final decoded = utf8.decode(base64Decode(encoded));
      data = jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to decode backup: $e');
    }

    final version = data['version'] as int? ?? 0;
    if (version != 2) {
      throw FormatException(
        'Unsupported or legacy backup version: $version. '
        'Create a new backup with the current app before restoring.',
      );
    }

    final masterKey = await SecureKeyStorage.getOrCreateMasterKey();
    final expectedFingerprint = sha256.convert(utf8.encode(masterKey)).toString();
    if (data['key_fingerprint'] != expectedFingerprint) {
      throw const FormatException(
        'This backup was created with a different installation key and cannot '
        'be restored here. Portable passphrase-protected backups are not yet supported.',
      );
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
