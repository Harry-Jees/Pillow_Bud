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
  });
}
