import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/system_prompt_generator.dart';

void main() {
  group('SystemPromptGenerator', () {
    test('Includes user context, voice rules, emotion, and safety guidance', () {
      final prompt = SystemPromptGenerator.generatePrompt(
        userName: 'Alex',
        personalityMode: 'balanced',
        detectedEmotion: 'anxious',
        emotionIntensity: 0.7,
        recentContext: null,
      );

      expect(prompt, contains('Alex'));
      expect(prompt, contains('VOICE DNA:'));
      expect(prompt, contains('Balanced mode:'));
      expect(prompt, contains('Emotion: anxious'));
      expect(prompt, contains('SAFETY:'));
      expect(prompt, contains('Do not diagnose'));
    });

    test('Personality modes change guidance accurately', () {
      for (final mode in ['gentle', 'curious', 'wise', 'balanced']) {
        final prompt = SystemPromptGenerator.generatePrompt(
          userName: 'Sam',
          personalityMode: mode,
          detectedEmotion: 'sad',
          emotionIntensity: 0.5,
          recentContext: null,
        );
        expect(prompt.toLowerCase(), contains('$mode mode:'));
      }
    });

    test('Includes recent context and uses None for absent context', () {
      final withContext = SystemPromptGenerator.generatePrompt(
        userName: 'Sam',
        personalityMode: 'balanced',
        detectedEmotion: 'calm',
        emotionIntensity: 0.2,
        recentContext: 'User: I had a hard day.',
      );
      expect(withContext, contains('RECENT CONTEXT:\nUser: I had a hard day.'));

      final withoutContext = SystemPromptGenerator.generatePrompt(
        userName: 'Sam',
        personalityMode: 'balanced',
        detectedEmotion: 'calm',
        emotionIntensity: 0.2,
        recentContext: null,
      );
      expect(withoutContext, contains('RECENT CONTEXT:\nNone'));
    });
  });
}
