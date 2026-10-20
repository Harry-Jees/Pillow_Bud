import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pillow_bud/models/chat_message.dart';
import 'package:pillow_bud/models/journal_entry.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('StorageService must be initialized before use. Call StorageService.init() first.');
    }
  }

  // User Data
  static Future<void> setUserName(String name) async {
    _ensureInitialized();
    await _prefs.setString('userName', name);
  }

  static String? getUserName() {
    _ensureInitialized();
    return _prefs.getString('userName');
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    _ensureInitialized();
    await _prefs.setBool('onboardingCompleted', completed);
  }

  static bool isOnboardingCompleted() {
    _ensureInitialized();
    return _prefs.getBool('onboardingCompleted') ?? false;
  }

  // Theme
  static Future<void> setDarkMode(bool isDark) async {
    _ensureInitialized();
    await _prefs.setBool('isDarkMode', isDark);
  }

  static bool isDarkMode() {
    _ensureInitialized();
    return _prefs.getBool('isDarkMode') ?? true;
  }

  static Future<void> setTheme(String theme) async {
    _ensureInitialized();
    await _prefs.setString('theme', theme);
  }

  static Future<void> saveTheme(String theme) => setTheme(theme);

  static String getTheme() {
    _ensureInitialized();
    return _prefs.getString('theme') ?? 'lavender';
  }

  // Buddy Personality
  static Future<void> setBuddyPersonality(String personality) async {
    _ensureInitialized();
    await _prefs.setString('buddyPersonality', personality);
  }

  static String getBuddyPersonality() {
    _ensureInitialized();
    return _prefs.getString('buddyPersonality') ?? 'balanced';
  }

  static Future<void> setOnboardingCompletedAt(DateTime dateTime) async {
    _ensureInitialized();
    await _prefs.setString('onboardingCompletedAt', dateTime.toIso8601String());
  }

  static DateTime? getOnboardingCompletedAt() {
    _ensureInitialized();
    final value = _prefs.getString('onboardingCompletedAt');
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // Chat persistence
  static Future<void> saveChatMessages(List<ChatMessage> messages) async {
    _ensureInitialized();
    final payload = jsonEncode(messages.map((e) => e.toJson()).toList());
    await _prefs.setString('chatMessages', payload);
  }

  static List<ChatMessage> getChatMessages() {
    _ensureInitialized();
    final jsonString = _prefs.getString('chatMessages');
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Journal persistence
  static Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    _ensureInitialized();
    final payload = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString('journalEntries', payload);
  }

  static List<JournalEntry> getJournalEntries() {
    _ensureInitialized();
    final jsonString = _prefs.getString('journalEntries');
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => JournalEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    _ensureInitialized();
    await _prefs.clear();
  }
}
