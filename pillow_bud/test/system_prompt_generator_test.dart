import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/system_prompt_generator.dart';

void main() {
  group('SystemPromptGenerator Tests', () {
    test('Generates prompt with base rules, user name, and safety boundaries', () {
      final prompt = SystemPromptGenerator.generatePrompt(
        userName: 'Alex',
        personalityMode: 'balanced',
        detectedEmotion: 'anxious',
        emotionIntensity: 0.7,
        recentContext: null,
      );

      expect(prompt.contains('Alex'), isTrue);
      expect(prompt.contains('NOT:'), isTrue);
      expect(prompt.contains('A therapist'), isTrue);
      expect(prompt.contains('BALANCED MODE:'), isTrue);
      expect(prompt.contains('RESPONSE TO ANXIETY'), isTrue);
      expect(prompt.contains('CRISIS DETECTION:'), isTrue);
    });

    test('Personality modes change prompt guidance accurately', () {
      final gentlePrompt = SystemPromptGenerator.generatePrompt(
        userName: 'Sam',
        personalityMode: 'gentle',
        detectedEmotion: 'sad',
        emotionIntensity: 0.5,
        recentContext: null,
      );
      expect(gentlePrompt.contains('GENTLE MODE:'), isTrue);

      final curiousPrompt = SystemPromptGenerator.generatePrompt(
        userName: 'Sam',
        personalityMode: 'curious',
        detectedEmotion: 'sad',
        emotionIntensity: 0.5,
        recentContext: null,
      );
      expect(curiousPrompt.contains('CURIOUS MODE:'), isTrue);

      final wisePrompt = SystemPromptGenerator.generatePrompt(
        userName: 'Sam',
        personalityMode: 'wise',
        detectedEmotion: 'sad',
        emotionIntensity: 0.5,
        recentContext: null,
      );
      expect(wisePrompt.contains('WISE MODE:'), isTrue);
    });
  });
}
