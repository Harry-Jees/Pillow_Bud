import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores user personalization data for emotional intelligence
class PersonalizationService {
  // Emotional patterns
  static Future<void> saveEmotionalPattern({
    required String emotion,
    required int frequency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('emotion_$emotion', frequency);
  }

  static Future<int> getEmotionFrequency(String emotion) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('emotion_$emotion') ?? 0;
  }

  // Preferred response styles per emotion
  static Future<void> savePreferredStyle({
    required String emotion,
    required String style,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_style_$emotion', style);
  }

  static Future<String?> getPreferredStyle(String emotion) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_style_$emotion');
  }

  // User feedback on Bud responses
  static Future<void> saveResponseFeedback({
    required String messageId,
    required bool helpful,
    required String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final feedback = {
      'helpful': helpful,
      'notes': notes ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString('feedback_$messageId', jsonEncode(feedback));
  }

  // Personality preference
  static Future<void> setPersonalityMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('personality_mode', mode);
  }

  static Future<String> getPersonalityMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('personality_mode') ?? 'balanced';
  }
}
