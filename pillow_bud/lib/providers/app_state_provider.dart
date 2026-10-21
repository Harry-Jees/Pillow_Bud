import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/chat_message.dart';
import 'package:pillow_bud/models/journal_entry.dart';
import 'package:pillow_bud/models/user_preference.dart';
import 'package:pillow_bud/services/database/database_service.dart';

// User State
final userNameProvider = StateProvider<String>((ref) => '');

final userPreferenceProvider =
    StateProvider<UserPreference>((ref) => UserPreference.empty());

final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

// Mood State
final currentMoodProvider = StateProvider<String>((ref) => '😌');

// Chat State
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

final isLoadingChatProvider = StateProvider<bool>((ref) => false);

final currentChatIdProvider = StateProvider<String>((ref) => 'default_session');

final currentChatEmotionProvider = StateProvider<String>((ref) => '');

// Journal State
final journalEntriesProvider = StateProvider<List<JournalEntry>>((ref) => []);

// UI & App State
final isDarkModeProvider = StateProvider<bool>((ref) => true);

final isModelLoadingProvider = StateProvider<bool>((ref) => false);

final modelLoadingProgressProvider = StateProvider<double>((ref) => 1.0);

/// Decrypted, recent mood check-ins for real trend summaries and insights.
final moodHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return DatabaseService.getMoodHistory();
});
