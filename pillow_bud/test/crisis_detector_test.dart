import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/crisis_detector.dart';

void main() {
  group('CrisisDetector Tests', () {
    test('Detects direct crisis triggers', () {
      expect(CrisisDetector.detect('I want to die'), isTrue);
      expect(CrisisDetector.detect('thinking about suicide'), isTrue);
      expect(CrisisDetector.detect('I want to kill myself'), isTrue);
      expect(CrisisDetector.detect('I feel like hurt myself tonight'), isTrue);
      expect(CrisisDetector.detect('I am better off dead'), isTrue);
      expect(CrisisDetector.detect('There is no way out and I can\'t go on'), isTrue);
    });

    test('Non-crisis everyday message returns false', () {
      expect(CrisisDetector.detect('I had a busy day at work and need to sleep'), isFalse);
      expect(CrisisDetector.detect('Hello Bud, how are you?'), isFalse);
      expect(CrisisDetector.detect('I am a bit tired'), isFalse);
    });

    test('Crisis resource message includes Indian helplines and contact numbers', () {
      final msg = CrisisDetector.getCrisisResourceMessage();
      expect(msg.contains('iCall'), isTrue);
      expect(msg.contains('022-25521111'), isTrue);
      expect(msg.contains('Vandrevala'), isTrue);
      expect(msg.contains('AASRA'), isTrue);
      expect(msg.contains('9820466726'), isTrue);
      expect(msg.contains('Tele-MANAS'), isTrue);
    });

    test('Structured resources list contains expected entries', () {
      final resources = CrisisDetector.getResources();
      expect(resources.length, greaterThanOrEqualTo(5));
      expect(resources.any((r) => r['name']!.contains('iCALL')), isTrue);
      expect(resources.any((r) => r['number'] == '02225521111'), isTrue);
      expect(resources.any((r) => r['number'] == '9820466726'), isTrue);
      expect(resources.any((r) => r['name']!.contains('iCall')), isTrue);
      expect(resources.any((r) => r['name']!.contains('Vandrevala')), isTrue);
      expect(resources.any((r) => r['name']!.contains('AASRA')), isTrue);
    });
  });
}
