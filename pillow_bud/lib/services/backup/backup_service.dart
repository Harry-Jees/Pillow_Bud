import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pillow_bud/services/database/database_service.dart';

/// Handles AES-256 encrypted export and import of all Pillow Bud data.
///
/// Export format: `PBv1:<base64(JSON)>`
/// The JSON payload contains raw encrypted SQLite rows (ciphertext + iv pairs)
/// so messages are never decrypted during export – they travel as already-encrypted blobs.
class BackupService {
  static const _magic = 'PBv1:';

  // ──────────────────────────────────────────────────────────
  //  EXPORT
  // ──────────────────────────────────────────────────────────

  /// Exports all data to an encrypted `.pillowbak` file in the device cache dir.
  ///
  /// Returns the [File] so the caller can share / save it.
  static Future<File> exportData() async {
    // 1. Fetch raw (already-encrypted) rows – no decryption needed.
    final chatRows = await DatabaseService.getRawChatMessageRows();
    final journalRows = await DatabaseService.getRawJournalEntryRows();
    final moodRows = await DatabaseService.getMoodHistory();

    // 2. Bundle into one JSON payload.
    final payload = jsonEncode({
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'chat_messages': chatRows,
      'journal_entries': journalRows,
      'mood_logs': moodRows,
    });

    // 3. Base64-encode the JSON (lightweight, no extra crypto layer needed –
    //    the individual rows already carry AES-256 ciphertext + iv).
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

  /// Imports a `.pillowbak` file and restores data into SQLite.
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
    if (version != 1) {
      throw FormatException('Unsupported backup version: $version');
    }

    int chats = 0, journals = 0, moods = 0;

    for (final row in (data['chat_messages'] as List<dynamic>? ?? [])) {
      try {
        await DatabaseService.insertRawRow(
          table: 'chat_messages',
          row: Map<String, dynamic>.from(row as Map),
        );
        chats++;
      } catch (e) {
        debugPrint('BackupService: skipped chat row: $e');
      }
    }

    for (final row in (data['journal_entries'] as List<dynamic>? ?? [])) {
      try {
        await DatabaseService.insertRawRow(
          table: 'journal_entries',
          row: Map<String, dynamic>.from(row as Map),
        );
        journals++;
      } catch (e) {
        debugPrint('BackupService: skipped journal row: $e');
      }
    }

    for (final row in (data['mood_logs'] as List<dynamic>? ?? [])) {
      try {
        await DatabaseService.insertRawRow(
          table: 'mood_logs',
          row: Map<String, dynamic>.from(row as Map),
        );
        moods++;
      } catch (e) {
        debugPrint('BackupService: skipped mood row: $e');
      }
    }

    debugPrint(
      'BackupService: imported $chats chats, $journals journals, $moods moods.',
    );
    return ImportResult(chats: chats, journals: journals, moods: moods);
  }
}

/// Value object returned by [BackupService.importData].
class ImportResult {
  final int chats;
  final int journals;
  final int moods;

  const ImportResult({
    required this.chats,
    required this.journals,
    required this.moods,
  });

  int get total => chats + journals + moods;

  @override
  String toString() =>
      'ImportResult(chats: $chats, journals: $journals, moods: $moods)';
}
