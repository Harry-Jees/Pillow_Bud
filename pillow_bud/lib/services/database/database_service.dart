import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pillow_bud/models/chat_message.dart';
import 'package:pillow_bud/models/journal_entry.dart';
import 'package:pillow_bud/models/user_preference.dart';
import 'package:pillow_bud/services/encryption/encryption_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Lightweight SQLite3 Database Service with transparent column-level AES-256 encryption.
/// Fully compatible with Android, iOS, Windows, macOS, Linux, and Web.
class DatabaseService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null && _db!.isOpen) return;

    try {
      // Enable FFI on Desktop platforms
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final dbFolder = await getApplicationSupportDirectory();
      final dbPath = p.join(dbFolder.path, 'pillow_bud_encrypted.sqlite3');

      _db = await openDatabase(
        dbPath,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stackTrace) {
      debugPrint('DatabaseService initialization failed: $e');
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  static bool get isInitialized => _db != null && _db!.isOpen;

  static Future<void> _onCreate(Database db, int version) async {
    // 1. Encrypted Chat Messages Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        role TEXT NOT NULL,
        ciphertext TEXT NOT NULL,
        iv TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        mood TEXT,
        mood_iv TEXT,
        intensity REAL
      )
    ''');

    // 2. Encrypted Journal Entries Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS journal_entries (
        id TEXT PRIMARY KEY,
        ciphertext TEXT NOT NULL,
        iv TEXT NOT NULL,
        mood TEXT NOT NULL,
        mood_iv TEXT,
        created_at INTEGER NOT NULL,
        modified_at INTEGER NOT NULL
      )
    ''');

    // 3. Encrypted User Preferences Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_preferences (
        id TEXT PRIMARY KEY,
        ciphertext TEXT NOT NULL,
        iv TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 4. Encrypted Mood Check-in Logs Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mood_logs (
        id TEXT PRIMARY KEY,
        mood TEXT NOT NULL,
        mood_iv TEXT,
        timestamp INTEGER NOT NULL,
        note_ciphertext TEXT,
        iv TEXT
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE chat_messages ADD COLUMN mood_iv TEXT');
      await db.execute('ALTER TABLE journal_entries ADD COLUMN mood_iv TEXT');
      await db.execute('ALTER TABLE mood_logs ADD COLUMN mood_iv TEXT');
    }
  }

  // ==================== CHAT MESSAGES ====================

  static Future<void> saveChatMessage(ChatMessage message, {String? mood, double? intensity}) async {
    if (!isInitialized) return;
    final encrypted = await EncryptionService.encrypt(message.text);
    final encryptedMood = mood == null ? null : await EncryptionService.encrypt(mood);

    await _db!.insert(
      'chat_messages',
      {
        'id': message.id,
        'session_id': message.sessionId,
        'role': message.isFromBud ? 'bud' : 'user',
        'ciphertext': encrypted['ciphertext']!,
        'iv': encrypted['iv']!,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'mood': encryptedMood?['ciphertext'],
        'mood_iv': encryptedMood?['iv'],
        'intensity': intensity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ChatMessage>> getAllChatMessages({String? sessionId}) async {
    if (!isInitialized) return [];

    final List<Map<String, dynamic>> maps;
    if (sessionId != null && sessionId.isNotEmpty) {
      maps = await _db!.query(
        'chat_messages',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp ASC',
      );
    } else {
      maps = await _db!.query('chat_messages', orderBy: 'timestamp ASC');
    }

    final List<ChatMessage> messages = [];
    for (final row in maps) {
      final text = await EncryptionService.decrypt(
        ciphertext: row['ciphertext'] as String,
        ivBase64: row['iv'] as String,
      );

      messages.add(ChatMessage(
        id: row['id'] as String,
        text: text,
        isFromBud: (row['role'] as String) == 'bud',
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
        sessionId: row['session_id'] as String,
      ));
    }

    return messages;
  }

  static Future<void> clearAllChatMessages({String? sessionId}) async {
    if (!isInitialized) return;
    if (sessionId != null && sessionId.isNotEmpty) {
      await _db!.delete('chat_messages', where: 'session_id = ?', whereArgs: [sessionId]);
    } else {
      await _db!.delete('chat_messages');
    }
  }

  // ==================== JOURNAL ENTRIES ====================

  static Future<void> saveJournalEntry(JournalEntry entry) async {
    if (!isInitialized) return;
    final encrypted = await EncryptionService.encrypt(entry.text);
    final encryptedMood = await EncryptionService.encrypt(entry.mood);

    await _db!.insert(
      'journal_entries',
      {
        'id': entry.id,
        'ciphertext': encrypted['ciphertext']!,
        'iv': encrypted['iv']!,
        'mood': encryptedMood['ciphertext'],
        'mood_iv': encryptedMood['iv'],
        'created_at': entry.dateCreated.millisecondsSinceEpoch,
        'modified_at': entry.dateModified.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<JournalEntry>> getAllJournalEntries() async {
    if (!isInitialized) return [];

    final maps = await _db!.query('journal_entries', orderBy: 'created_at DESC');
    final List<JournalEntry> entries = [];

    for (final row in maps) {
      final text = await EncryptionService.decrypt(
        ciphertext: row['ciphertext'] as String,
        ivBase64: row['iv'] as String,
      );

      final moodIv = row['mood_iv'] as String?;
      final mood = moodIv == null || moodIv.isEmpty
          ? row['mood'] as String
          : await EncryptionService.decrypt(
              ciphertext: row['mood'] as String,
              ivBase64: moodIv,
            );

      entries.add(JournalEntry(
        id: row['id'] as String,
        text: text,
        mood: mood,
        dateCreated: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        dateModified: DateTime.fromMillisecondsSinceEpoch(row['modified_at'] as int),
      ));
    }

    return entries;
  }

  static Future<void> deleteJournalEntry(String entryId) async {
    if (!isInitialized) return;
    await _db!.delete('journal_entries', where: 'id = ?', whereArgs: [entryId]);
  }

  // ==================== USER PREFERENCES ====================

  static Future<void> savePreferences(UserPreference pref) async {
    if (!isInitialized) return;
    final rawJson = {
      'userName': pref.userName,
      'buddyPersonality': pref.buddyPersonality,
      'isDarkMode': pref.isDarkMode,
      'primaryColor': pref.primaryColor,
      'secondaryColor': pref.secondaryColor,
      'onboardingCompleted': pref.onboardingCompleted,
      'onboardingCompletedAt': pref.onboardingCompletedAt?.toIso8601String(),
    };

    final encrypted = await EncryptionService.encrypt(rawJson.toString());

    await _db!.insert(
      'user_preferences',
      {
        'id': 'current_user',
        'ciphertext': encrypted['ciphertext']!,
        'iv': encrypted['iv']!,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== MOOD LOGS ====================

  static Future<void> logMood(String mood, {String? note}) async {
    if (!isInitialized) return;
    final encrypted = note != null && note.isNotEmpty ? await EncryptionService.encrypt(note) : null;
    final encryptedMood = await EncryptionService.encrypt(mood);

    await _db!.insert(
      'mood_logs',
      {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'mood': encryptedMood['ciphertext'],
        'mood_iv': encryptedMood['iv'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'note_ciphertext': encrypted?['ciphertext'],
        'iv': encrypted?['iv'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getMoodHistory() async {
    if (!isInitialized) return [];
    final rows = await _db!.query('mood_logs', orderBy: 'timestamp DESC', limit: 30);
    final result = <Map<String, dynamic>>[];
    for (final source in rows) {
      final row = Map<String, dynamic>.from(source);
      final moodIv = row['mood_iv'] as String?;
      // Rows created before schema v2 stored mood labels in plaintext.
      if (moodIv != null && moodIv.isNotEmpty) {
        row['mood'] = await EncryptionService.decrypt(
          ciphertext: row['mood'] as String,
          ivBase64: moodIv,
        );
      }
      result.add(row);
    }
    return result;
  }

  // ==================== RAW-ROW HELPERS (for BackupService) ====================

  /// Returns raw encrypted rows from [chat_messages] without decrypting.
  static Future<List<Map<String, dynamic>>> getRawChatMessageRows() async {
    if (!isInitialized) return [];
    return await _db!.query('chat_messages', orderBy: 'timestamp ASC');
  }

  /// Returns raw encrypted rows from [journal_entries] without decrypting.
  static Future<List<Map<String, dynamic>>> getRawJournalEntryRows() async {
    if (!isInitialized) return [];
    return await _db!.query('journal_entries', orderBy: 'created_at DESC');
  }

  /// Generic INSERT OR REPLACE – used by BackupService during import to restore
  /// already-encrypted rows without re-encrypting them.
  static Future<void> insertRawRow({
    required String table,
    required Map<String, dynamic> row,
  }) async {
    if (!isInitialized) return;
    await _db!.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Saves a raw encrypted chat message row directly into the `chat_messages`
  /// table without decrypting it. Used by BackupService during import.
  static Future<void> saveRawChatMessageMap(Map<String, dynamic> row) async {
    await insertRawRow(table: 'chat_messages', row: row);
  }
}
