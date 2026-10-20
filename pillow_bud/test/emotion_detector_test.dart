import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/emotion_detector.dart';

void main() {
  group('EmotionDetector Tests', () {
    test('Detects overwhelmed emotion and intensity', () {
      final res = EmotionDetector.analyze('I am feeling so overwhelmed with everything at once');
      expect(res['emotion'], equals('overwhelmed'));
      expect(res['intensity'], greaterThanOrEqualTo(0.5));
    });

    test('Detects anxious emotion', () {
      final res = EmotionDetector.analyze('I am very anxious and worried about tomorrow');
      expect(res['emotion'], equals('anxious'));
      expect(res['intensity'], greaterThanOrEqualTo(0.6));
    });

    test('Detects sad emotion', () {
      final res = EmotionDetector.analyze('I feel so sad and heartbroken today');
      expect(res['emotion'], equals('sad'));
    });

    test('Detects lonely emotion', () {
      final res = EmotionDetector.analyze('I feel completely alone and isolated');
      expect(res['emotion'], equals('lonely'));
      expect(res['intensity'], greaterThanOrEqualTo(0.7));
    });

    test('Detects stressed emotion', () {
      final res = EmotionDetector.analyze('Work pressure is giving me burnout and stress');
      expect(res['emotion'], equals('stressed'));
    });

    test('Detects confused emotion', () {
      final res = EmotionDetector.analyze('I don\'t know what to do, I am so confused');
      expect(res['emotion'], equals('confused'));
    });

    test('Detects hopeful emotion', () {
      final res = EmotionDetector.analyze('I am feeling hopeful and optimistic about things getting better');
      expect(res['emotion'], equals('hopeful'));
    });

    test('Detects calm emotion', () {
      final res = EmotionDetector.analyze('Today was peaceful and I feel relaxed and calm');
      expect(res['emotion'], equals('calm'));
    });

    test('Detects angry emotion', () {
      final res = EmotionDetector.analyze('I am really angry and furious about what happened');
      expect(res['emotion'], equals('angry'));
    });

    test('Detects uncertain emotion', () {
      final res = EmotionDetector.analyze('I am unsure and torn about which decision to make');
      expect(res['emotion'], equals('uncertain'));
    });

    test('Intensity is properly clamped between 0.0 and 1.0', () {
      final res = EmotionDetector.analyze('I am unbearable extremely completely overwhelmed');
      expect(res['intensity'], lessThanOrEqualTo(1.0));
      expect(res['intensity'], greaterThanOrEqualTo(0.0));
    });

    test('Recommended personality mode mapping matches specification', () {
      expect(EmotionDetector.getRecommendedMode('overwhelmed'), equals('gentle'));
      expect(EmotionDetector.getRecommendedMode('anxious'), equals('gentle'));
      expect(EmotionDetector.getRecommendedMode('lonely'), equals('curious'));
      expect(EmotionDetector.getRecommendedMode('sad'), equals('wise'));
      expect(EmotionDetector.getRecommendedMode('calm'), equals('wise'));
      expect(EmotionDetector.getRecommendedMode('hopeful'), equals('balanced'));
    });
  });
}
