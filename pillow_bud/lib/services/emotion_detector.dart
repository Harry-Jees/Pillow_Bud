import 'dart:math';

/// Detects emotional states from text as defined in Part 6 of the Master Prompt.
class EmotionDetector {
  static final Map<String, List<String>> _emotionKeywords = {
    'overwhelmed': [
      'overwhelmed',
      'too much',
      'can\'t handle',
      'drowning',
      'everything at once',
      'stressed out',
      'can\'t cope',
    ],
    'anxious': ['anxious', 'nervous', 'worried', 'scared', 'afraid', 'panic', 'what if'],
    'sad': ['sad', 'depressed', 'down', 'empty', 'numb', 'lonely', 'hurts'],
    'lonely': ['alone', 'isolated', 'disconnected', 'left out', 'nobody', 'lonely'],
    'stressed': ['stressed', 'pressure', 'deadlines', 'busy', 'tense', 'frustrated'],
    'confused': ['confused', 'lost', 'uncertain', 'don\'t know', 'unclear', 'mixed up'],
    'hopeful': ['hopeful', 'optimistic', 'improving', 'better', 'looking forward'],
    'calm': ['calm', 'peaceful', 'centered', 'grounded', 'relaxed', 'serene'],
    'angry': ['angry', 'furious', 'mad', 'resentful', 'irritated', 'pissed'],
    'uncertain': ['unsure', 'uncertain', 'indecisive', 'torn', 'maybe'],
  };

  static final Map<String, double> _intensityMarkers = {
    'unbearable': 1.8,
    'extremely': 1.7,
    'absolute': 1.6,
    'intense': 1.6,
    'very': 1.5,
    'completely': 1.5,
    'total': 1.5,
    'so': 1.3,
    'can\'t': 1.3,
    'really': 1.2,
  };

  /// Analyzes a message to return a primary emotion and intensity (0.0 - 1.0).
  static Map<String, dynamic> analyze(String message) {
    final normalizedMessage = _normalize(message);
    String detectedEmotion = 'neutral';
    double baseIntensity = 0.0;

    int maxMatches = 0;
    _emotionKeywords.forEach((emotion, keywords) {
      var matches = 0;
      for (final keyword in keywords) {
        if (_containsTerm(normalizedMessage, keyword)) {
          matches++;
        }
      }

      if (matches > maxMatches) {
        maxMatches = matches;
        detectedEmotion = emotion;
        baseIntensity = 0.3 + (matches * 0.1); // Start with a base and add per match
      }
    });

    var multiplier = 1.0;
    _intensityMarkers.forEach((marker, value) {
      if (_containsTerm(normalizedMessage, marker)) {
        multiplier = max(multiplier, value);
      }
    });

    final intensity = (baseIntensity * multiplier).clamp(0.1, 1.0);

    return {
      'emotion': detectedEmotion,
      'intensity': maxMatches == 0 ? 0.5 : intensity, // If no emotion, return neutral intensity
    };
  }

  /// Maps emotions to recommended personality mode per spec 6.2.
  static String getRecommendedMode(String emotion) {
    switch (emotion) {
      case 'overwhelmed':
      case 'anxious':
      case 'angry':
      case 'stressed':
        return 'gentle';
      case 'lonely':
      case 'confused':
      case 'uncertain':
        return 'curious';
      case 'sad':
      case 'calm':
        return 'wise';
      case 'hopeful':
      default:
        return 'balanced';
    }
  }

  static String _normalize(String message) {
    return message
        .toLowerCase()
        .replaceAll(RegExp(r'[\u201C\u201D]'), '"')
        .replaceAll(RegExp(r"[\u2018\u2019`]", unicode: true), "'")
        .replaceAll(RegExp(r'[^a-z0-9\'\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _containsTerm(String text, String term) {
    final normalizedTerm = term
        .toLowerCase()
        .replaceAll(RegExp(r'[\u201C\u201D]'), '"')
        .replaceAll(RegExp(r"[\u2018\u2019`]", unicode: true), "'")
        .replaceAll(RegExp(r'[^a-z0-9\'\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalizedTerm.isEmpty) return false;

    final pattern = RegExp(
      r'(^|\s)' + RegExp.escape(normalizedTerm) + r'($|\s)',
      caseSensitive: false,
    );
    return pattern.hasMatch(text);
  }
}
