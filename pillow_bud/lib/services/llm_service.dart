import 'package:pillow_bud/config/ai_config.dart';
import 'package:pillow_bud/services/emotion_detector.dart';
import 'package:pillow_bud/services/system_prompt_generator.dart';
import 'package:pillow_bud/services/crisis_detector.dart';

class LLMService {
  /// Conversation history for context.
  final List<Map<String, String>> conversationHistory = [];

  /// Get emotionally intelligent Bud response.
  Future<String> getEmotionalBudResponse({
    required String userMessage,
    required String userName,
    required String personalityMode,
  }) async {
    final analysis = EmotionDetector.analyze(userMessage);
    final detectedEmotion = analysis['emotion'] as String;
    final emotionIntensity = analysis['intensity'] as double;

    if (CrisisDetector.detectCrisis(userMessage)) {
      return CrisisDetector.getCrisisResourceMessage();
    }

    SystemPromptGenerator.generatePrompt(
      userName: userName,
      personalityMode: personalityMode,
      detectedEmotion: detectedEmotion,
      emotionIntensity: emotionIntensity,
      recentContext: _getRecentContext(),
    );

    final response = await _generateResponse(
      detectedEmotion: detectedEmotion,
      emotionIntensity: emotionIntensity,
      personalityMode: personalityMode,
    );

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

    if (conversationHistory.length > 20) {
      conversationHistory.removeRange(0, 2);
    }

    return response;
  }

  /// Generate response (currently mock, ready for real Llama).
  Future<String> _generateResponse({
    required String detectedEmotion,
    required double emotionIntensity,
    required String personalityMode,
  }) async {
    await Future.delayed(
      Duration(milliseconds: AIConfig.thinkingDelay),
    );

    final response = _getMockEmotionalResponse(
      emotion: detectedEmotion,
      personalityMode: personalityMode,
    );

    return _sanitizeResponse(response);
  }

  /// Mock emotionally intelligent responses (Phase 1).
  String _getMockEmotionalResponse({
    required String emotion,
    required String personalityMode,
  }) {
    final lead = _getLead(personalityMode);
    final emotionResponse = _emotionResponseFor(
      emotion: emotion,
      personalityMode: personalityMode,
    );
    final followUp = _followUpFor(
      emotion: emotion,
      personalityMode: personalityMode,
    );

    return '$lead $emotionResponse $followUp'.trim();
  }

  String _getLead(String personalityMode) {
    switch (personalityMode) {
      case 'gentle':
        return 'That feels tender, and it deserves a careful response.';
      case 'curious':
        return 'There is a pattern here worth looking at more closely.';
      case 'wise':
        return 'This seems to be pointing toward something deeper than the surface detail.';
      case 'balanced':
      default:
        return 'That makes sense, and we can work through it with care.';
    }
  }

  String _followUpFor({
    required String emotion,
    required String personalityMode,
  }) {
    switch (personalityMode) {
      case 'gentle':
        return switch (emotion) {
          'sad' => 'What part has been heaviest to carry?',
          'lonely' => 'What kind of support would feel most reassuring right now?',
          'anxious' => 'Would it help to slow down and look at one small piece?',
          _ => 'What would feel most steady from here?',
        };
      case 'curious':
        return switch (emotion) {
          'confused' => 'What part feels hardest to make sense of?',
          'uncertain' => 'What would make this feel a little more defined?',
          'stressed' => 'What is asking for the most attention here?',
          _ => 'What stands out most to you in this?',
        };
      case 'wise':
        return switch (emotion) {
          'overwhelmed' => 'What changes if we reduce this to one priority?',
          'angry' => 'What value or boundary feels crossed here?',
          'sad' => 'What do you think this feeling is trying to protect?',
          _ => 'What perspective would help most right now?',
        };
      case 'balanced':
      default:
        return switch (emotion) {
          'anxious' => 'What feels most true in this moment?',
          'hopeful' => 'What shifted that made this feel possible?',
          'calm' => 'What seems to be supporting this calm?',
          _ => 'What would help most from here?',
        };
    }
  }

  String _emotionResponseFor({
    required String emotion,
    required String personalityMode,
  }) {
    switch (emotion) {
      case 'overwhelmed':
        return switch (personalityMode) {
          'wise' => 'There is too much pressure in too many directions, and that naturally frays focus.',
          'curious' => 'A lot is competing for your attention at once. Which piece is loudest?',
          'gentle' => 'You are carrying more than feels reasonable, and that can be exhausting.',
          _ => 'This is a lot to hold at once, especially when everything feels urgent.',
        };
      case 'anxious':
        return switch (personalityMode) {
          'wise' => 'Anxiety can blur the line between possibility and fact, so it helps to come back to what is actually here.',
          'curious' => 'The worry is showing up clearly. What is the fear underneath it?',
          'gentle' => 'That worry makes sense. You do not need to solve the whole thing right now.',
          _ => 'That worry makes sense, and it may help to return to what is true right now.',
        };
      case 'sad':
        return switch (personalityMode) {
          'wise' => 'Sadness often points toward something meaningful that has been lost or changed.',
          'curious' => 'There is a real ache here. What part hurts most?',
          'gentle' => 'That sadness is real, and it does not need to be rushed.',
          _ => 'This sounds painful, and it deserves to be treated with care.',
        };
      case 'lonely':
        return switch (personalityMode) {
          'wise' => 'Loneliness has a way of showing how deeply connection matters.',
          'curious' => 'What kind of connection would feel most supportive right now?',
          'gentle' => 'This feeling is understandable, and it can be heavy to sit with.',
          _ => 'Loneliness can feel isolating, and we can stay with it together.',
        };
      case 'stressed':
        return switch (personalityMode) {
          'wise' => 'Stress often means something important needs attention, but not all of it needs attention at once.',
          'curious' => 'What is the biggest source of pressure here?',
          'gentle' => 'That is a real amount of pressure to be holding.',
          _ => 'That sounds stressful, and it may help to sort what matters now from what can wait.',
        };
      case 'confused':
        return switch (personalityMode) {
          'wise' => 'Confusion can be the point where clarity is trying to form.',
          'curious' => 'Let us untangle it. What part feels most unclear?',
          'gentle' => 'It is okay to feel unsure while things are still taking shape.',
          _ => 'It makes sense that this feels unclear. We can slow it down together.',
        };
      case 'hopeful':
        return switch (personalityMode) {
          'wise' => 'That hope matters. It can be a signal that something is changing.',
          'curious' => 'What seems to be opening up for you?',
          'gentle' => 'That is a meaningful shift, and it is good to notice it.',
          _ => 'That is encouraging, and it may be worth leaning into.',
        };
      case 'calm':
        return switch (personalityMode) {
          'wise' => 'That calm is worth protecting; it often reflects something working well.',
          'curious' => 'What seems to be supporting this sense of calm?',
          'gentle' => 'That sounds steady and restorative.',
          _ => 'That is a good place to pause and appreciate.',
        };
      case 'angry':
        return switch (personalityMode) {
          'wise' => 'Anger often signals that a boundary, value, or expectation has been crossed.',
          'curious' => 'What feels most important underneath the anger?',
          'gentle' => 'That anger makes sense, and it deserves space rather than judgment.',
          _ => 'That sounds frustrating, and it may help to name what needs to change.',
        };
      case 'uncertain':
        return switch (personalityMode) {
          'wise' => 'Uncertainty is uncomfortable, but it also leaves room for clarity to emerge.',
          'curious' => 'What part of the uncertainty matters most right now?',
          'gentle' => 'It is okay not to know yet.',
          _ => 'Not knowing can be difficult, and we can work with that carefully.',
        };
      default:
        return switch (personalityMode) {
          'wise' => 'We can look at this with a steady mind.',
          'curious' => 'Tell me a little more so I can understand what is happening.',
          'gentle' => 'We can stay with this together.',
          _ => 'We can take this one step at a time.',
        };
    }
  }

  String _sanitizeResponse(String response) {
    var cleaned = response.trim();

    cleaned = cleaned.replaceFirst(
      RegExp(r'^(bud|assistant|bot)\s*[:\-\u2013\u2014]\s*',
          caseSensitive: false),
      '',
    );

    cleaned = cleaned.replaceFirst(
      RegExp(r'^(sure|of course|absolutely|certainly)\s*,?\s*',
          caseSensitive: false),
      '',
    );

    cleaned = cleaned.replaceFirst(
      RegExp(r"^(i\s+(understand|hear you|see)|i['’]?m here to help|i can help)\s*,?\s*",
          caseSensitive: false),
      '',
    );

    cleaned = cleaned.replaceFirst(
      RegExp(r'^[\-\u2013\u2014]\s*'),
      '',
    );

    return cleaned.trim();
  }

  /// Get recent conversation context for continuity.
  String _getRecentContext() {
    if (conversationHistory.isEmpty) return '';

    final recent = conversationHistory
        .skip(
          conversationHistory.length > 8 ? conversationHistory.length - 8 : 0,
        )
        .toList();

    return recent.map((msg) => '${msg['role']}: ${msg['content']}').join('\n');
  }

  /// Clear conversation history.
  void clearHistory() {
    conversationHistory.clear();
  }

  /// Get conversation history for saving.
  List<Map<String, String>> getHistory() {
    return List.from(conversationHistory);
  }
}
