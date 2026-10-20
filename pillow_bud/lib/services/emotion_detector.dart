import 'dart:math';

/// Detects emotional states and intensity from text as defined in Part 6 of the Master Prompt.
class EmotionDetector {
  static final Map<String, List<String>> _emotionKeywords = {
    'overwhelmed': [
      'overwhelmed',
      'too much',
      'can\'t handle',
      'cant handle',
      'drowning',
      'everything at once',
      'stressed out',
      'can\'t cope',
      'cant cope',
      'breaking point',
      'collapsing',
    ],
    'anxious': [
      'anxious',
      'anxiety',
      'nervous',
      'worried',
      'worry',
      'scared',
      'afraid',
      'panic',
      'what if',
      'dread',
      'freaking out',
    ],
    'sad': [
      'sad',
      'sadness',
      'depressed',
      'depression',
      'down',
      'empty',
      'numb',
      'hurts',
      'crying',
      'heartbroken',
      'unhappy',
      'miserable',
    ],
    'lonely': [
      'alone',
      'isolated',
      'disconnected',
      'left out',
      'nobody',
      'lonely',
      'loneliness',
      'no one cares',
    ],
    'stressed': [
      'stressed',
      'stress',
      'pressure',
      'deadlines',
      'busy',
      'tense',
      'exhausted',
      'burnout',
    ],
    'confused': [
      'confused',
      'confusion',
      'lost',
      'uncertain',
      'don\'t know',
      'dont know',
      'unclear',
      'mixed up',
      'perplexed',
    ],
    'hopeful': [
      'hopeful',
      'hope',
      'optimistic',
      'improving',
      'better',
      'looking forward',
      'positive',
      'excited',
    ],
    'calm': [
      'calm',
      'peaceful',
      'centered',
      'grounded',
      'relaxed',
      'serene',
      'tranquil',
      'content',
    ],
    'angry': [
      'angry',
      'anger',
      'furious',
      'mad',
      'resentful',
      'irritated',
      'pissed',
      'annoyed',
      'enraged',
    ],
    'uncertain': [
      'unsure',
      'uncertain',
      'uncertainty',
      'indecisive',
      'torn',
      'maybe',
      'hesitant',
    ],
  };

  static final Map<String, double> _intensityMarkers = {
    'unbearable': 1.8,
    'extremely': 1.7,
    'absolute': 1.6,
    'absolutely': 1.6,
    'intense': 1.6,
    'very': 1.5,
    'completely': 1.5,
    'total': 1.5,
    'totally': 1.5,
    'so': 1.3,
    'can\'t': 1.3,
    'cant': 1.3,
    'cannot': 1.3,
    'really': 1.2,
    'quite': 1.1,
  };

  /// Normalizes string for consistent token matching
  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\x27]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Analyzes message to return a primary emotion and intensity (0.0 - 1.0)
  static Map<String, dynamic> analyze(String message) {
    final normalized = _normalize(message);
    if (normalized.isEmpty) {
      return {'emotion': 'neutral', 'intensity': 0.5};
    }

    String detectedEmotion = 'neutral';
    double baseIntensity = 0.5;

    // 1. Detect Emotion by keyword score
    int maxMatches = 0;
    _emotionKeywords.forEach((emotion, keywords) {
      int matches = 0;
      for (final keyword in keywords) {
        final kwNorm = _normalize(keyword);
        if (normalized.contains(kwNorm)) {
          matches += (kwNorm.split(' ').length); // Multi-word matches get higher weight
        }
      }
      if (matches > maxMatches) {
        maxMatches = matches;
        detectedEmotion = emotion;
      }
    });

    // 2. Calculate Intensity Multiplier
    double multiplier = 1.0;
    _intensityMarkers.forEach((marker, value) {
      final markerNorm = _normalize(marker);
      final regex = RegExp(r'\b' + RegExp.escape(markerNorm) + r'\b');
      if (regex.hasMatch(normalized)) {
        multiplier = max(multiplier, value);
      }
    });

    final calculatedIntensity = (baseIntensity * multiplier).clamp(0.0, 1.0);

    return {
      'emotion': detectedEmotion,
      'intensity': calculatedIntensity,
    };
  }

  /// Map emotions to recommended personality mode per spec 6.2
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
}
