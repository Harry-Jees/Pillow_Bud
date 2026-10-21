import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/crisis_detector.dart';

void main() {
  group('CrisisDetector', () {
    test('recognizes explicit high-risk phrases', () {
      expect(CrisisDetector.detect('I want to end my life'), isTrue);
      expect(CrisisDetector.detect('I might hurt myself'), isTrue);
      expect(CrisisDetector.detect('I took an overdose'), isTrue);
    });

    test('does not match unrelated words as substrings', () {
      expect(CrisisDetector.detect('I am cutting vegetables'), isFalse);
      expect(CrisisDetector.detect('I want to jump into the pool'), isFalse);
    });

    test('matches phrase boundaries regardless of capitalization', () {
      expect(CrisisDetector.detect('I WANT TO DIE'), isTrue);
    });

    test('recognizes indirect safety-risk language', () {
      expect(CrisisDetector.detect("I can't keep myself safe"), isTrue);
      expect(CrisisDetector.detect('I have a plan to end my life'), isTrue);
    });

    test('does not raise the crisis overlay for a standalone denial', () {
      expect(CrisisDetector.detect("I don't want to hurt myself"), isFalse);
      expect(CrisisDetector.detect('I am not suicidal'), isFalse);
    });
  });
}
