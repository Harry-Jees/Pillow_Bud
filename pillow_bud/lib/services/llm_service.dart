import 'package:pillow_bud/config/ai_config.dart';
import 'package:pillow_bud/services/emotion_detector.dart';
import 'package:pillow_bud/services/system_prompt_generator.dart';
import 'package:pillow_bud/services/crisis_detector.dart';
import 'package:uuid/uuid.dart';

class LLMService {
  static final uuid = Uuid();

  // Conversation history for context
  final List<Map<String, String>> conversationHistory = [];

  /// Get emotionally intelligent Bud response
  Future<String> getEmotionalBudResponse({
    required String userMessage,
    required String userName,
    required String personalityMode,
  }) async {
    // Step 1: Detect emotion and intensity
    final analysis = EmotionDetector.analyze(userMessage);
    final detectedEmotion = analysis['emotion'] as String;
    final emotionIntensity = analysis['intensity'] as double;


    // Step 2: Check for crisis
    if (CrisisDetector.detectCrisis(userMessage)) {
      return CrisisDetector.getCrisisResourceMessage();
    }

    // Step 3: Generate emotionally intelligent system prompt
    final systemPrompt = SystemPromptGenerator.generatePrompt(
      userName: userName,
      personalityMode: personalityMode,
      detectedEmotion: detectedEmotion,
      emotionIntensity: emotionIntensity,
      recentContext: _getRecentContext(),
    );

    // Step 4: Get response (mock or real Llama)
    final response = await _generateResponse(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      detectedEmotion: detectedEmotion,
      emotionIntensity: emotionIntensity,
    );

    // Step 5: Store in conversation history
    conversationHistory.add({
      'role': 'user',
      'content': userMessage,
      'emotion': detectedEmotion,
      'intensity': emotionIntensity.toString(),
    });
    conversationHistory.add({
      'role': 'assistant',
      'content': response,
    });

    // Keep conversation history to last 10 exchanges to save context
    if (conversationHistory.length > 20) {
      conversationHistory.removeRange(0, 2);
    }

    return response;
  }

  /// Generate response (currently mock, ready for real Llama)
  Future<String> _generateResponse({
    required String systemPrompt,
    required String userMessage,
    required String detectedEmotion,
    required double emotionIntensity,
  }) async {
    // TODO: Replace with real Llama 3.2 1B when flutter_gemma is ready
    // For now, return contextual mock responses

    // Simulate thinking time
    await Future.delayed(
      Duration(milliseconds: AIConfig.thinkingDelay),
    );

    return _getMockEmotionalResponse(
      userMessage: userMessage,
      emotion: detectedEmotion,
      intensity: emotionIntensity,
    );
  }

  /// Mock emotionally intelligent responses (Phase 1)
  String _getMockEmotionalResponse({
    required String userMessage,
    required String emotion,
    required double intensity,
  }) {
    final responses = <String, List<String>>{
      'overwhelmed': [
        'That sounds like a lot to carry right now. You\'re handling more than one person should have to.',
        'When everything feels like too much, it helps to focus on just the next small step.',
        'What you\'re feeling makes complete sense. This is genuinely overwhelming.',
        'It\'s okay to feel this way when you\'re dealing with this much.',
      ],
      'anxious': [
        'Anxiety can feel so real even when we\'re not sure what will happen. What worries you most right now?',
        'That worry makes sense. Let me ask: what\'s actually happening right now, in this moment?',
        'Anxiety can trick us into thinking something will go wrong. What does your gut tell you?',
        'It\'s hard to sit with this uncertainty. But you\'re safe right now.',
      ],
      'sad': [
        'Sadness is how we process loss and pain. Whatever you\'re grieving deserves to be felt.',
        'That\'s worth feeling sad about. Tell me what you\'re missing or what hurts.',
        'Sometimes sadness is the truest response to what\'s happening. That\'s okay.',
        'You\'re allowed to sit with this sadness for as long as you need.',
      ],
      'lonely': [
        'Loneliness is one of the hardest feelings. I\'m here, and you\'re not alone right now.',
        'The fact that you feel lonely means you value connection. That\'s actually beautiful.',
        'Who do you think you could reach out to? Even one person?',
        'You matter, and your presence in the world matters. I see you.',
      ],
      'stressed': [
        'That\'s stressful, and your stress is valid. What\'s the thing that feels most urgent right now?',
        'When everything feels urgent, nothing is actually urgent. What can wait?',
        'Stress is your system telling you something matters. What\'s important to you here?',
        'You\'re dealing with a lot. What\'s one thing you could let go of or ask for help with?',
      ],
      'confused': [
        'Confusion is okay. Let\'s untangle this together. What\'s the most confusing part?',
        'You don\'t have to have all the answers right now. What\'s one thing you know for sure?',
        'Tell me more about what\'s unclear. Sometimes talking it through helps.',
        'It\'s normal to not know what to do. What would help you figure this out?',
      ],
      'hopeful': [
        'That\'s wonderful. Hold onto that feeling. What changed for you?',
        'Hope is powerful. What are you hopeful about?',
        'I love that shift. Tell me more about what you\'re looking forward to.',
        'You\'re moving toward something. Keep going.',
      ],
      'calm': [
        'That peace is something to protect. What helped you get here?',
        'Calm is rare and precious. Sit with it for a moment.',
        'You found your center. What do you notice when you\'re this calm?',
        'This quiet strength you\'re feeling—hold onto it.',
      ],
      'angry': [
        'Your anger makes sense. What happened that made you feel this way?',
        'Anger is often a sign that something important was violated. What is it?',
        'Don\'t minimize your anger. It\'s telling you something matters.',
        'I hear your frustration. What do you need right now?',
      ],
      'uncertain': [
        'Uncertainty is uncomfortable but normal. What would help you sit with the not-knowing?',
        'You don\'t have to decide everything right now. What\'s one small thing you do know?',
        'The not-knowing is hard, but it\'s also where possibility lives.',
        'What would help you accept this uncertainty, even if you can\'t resolve it?',
      ],
    };

    // Get responses for detected emotion
    final emotionResponses = responses[emotion] ?? responses['uncertain']!;

    // Select response based on conversation history
    final index = conversationHistory.length % emotionResponses.length;
    return emotionResponses[index];
  }

  /// Get recent conversation context for continuity
  String _getRecentContext() {
    if (conversationHistory.isEmpty) return '';

    // Get last 4 exchanges (8 messages)
    final recent = conversationHistory
        .skip(
          conversationHistory.length > 8 ? conversationHistory.length - 8 : 0,
        )
        .toList();

    return recent.map((msg) => '${msg['role']}: ${msg['content']}').join('\n');
  }

  /// Clear conversation history (for new session)
  void clearHistory() {
    conversationHistory.clear();
  }

  /// Get conversation history for saving
  List<Map<String, String>> getHistory() {
    return List.from(conversationHistory);
  }
}
