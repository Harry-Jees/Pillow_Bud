import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pillow_bud/models/isar/chat_message_isar.dart';
import 'package:pillow_bud/models/isar/journal_entry_isar.dart';
import 'package:pillow_bud/models/isar/user_preferences_isar.dart';

class IsarService {
  static Isar? _isar;

  static Future<void> init() async {
    if (_isar != null) return;
    final dir = await getApplicationSupportDirectory();
    _isar = await Isar.open(
      [ChatMessageIsarSchema, JournalEntryIsarSchema, UserPreferencesIsarSchema],
      directory: dir.path,
    );
  }

  static Isar get instance {
    if (_isar == null) throw Exception('Isar not initialized');
    return _isar!;
  }

  // Chat CRUD examples
  static Future<void> saveChatMessage(ChatMessageIsar message) async {
    await instance.writeTxn(() async {
      await instance.chatMessageIsars.put(message);
    });
  }

  static Future<List<ChatMessageIsar>> getMessagesForSession(String sessionId) async {
    return await instance.chatMessageIsars.filter().sessionIdEqualTo(sessionId).findAll();
  }

  // Journal CRUD examples
  static Future<void> saveJournalEntry(JournalEntryIsar entry) async {
    await instance.writeTxn(() async {
      await instance.journalEntryIsars.put(entry);
    });
  }

  static Future<List<JournalEntryIsar>> getAllJournalEntries() async {
    return await instance.journalEntryIsars.where().findAll();
  }

  // Preferences
  static Future<void> savePreferences(UserPreferencesIsar prefs) async {
    await instance.writeTxn(() async {
      await instance.userPreferencesIsars.put(prefs);
    });
  }

  static Future<List<UserPreferencesIsar>> getPreferences() async {
    return await instance.userPreferencesIsars.where().findAll();
  }
}
