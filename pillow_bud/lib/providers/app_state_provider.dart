import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/chat_message.dart';
import 'package:pillow_bud/models/journal_entry.dart';
import 'package:pillow_bud/models/user_preference.dart';

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

final currentChatIdProvider = StateProvider<String>((ref) => '');

// Journal State
final journalEntriesProvider = StateProvider<List<JournalEntry>>((ref) => []);

// UI State
final isDarkModeProvider = StateProvider<bool>((ref) => true);

final isModelLoadingProvider = StateProvider<bool>((ref) => true);

final modelLoadingProgressProvider = StateProvider<double>((ref) => 0.0);
