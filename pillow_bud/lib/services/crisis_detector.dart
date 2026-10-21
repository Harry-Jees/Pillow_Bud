import 'package:pillow_bud/config/constants.dart';

/// Detects crisis markers and provides immediate emergency support resources
class CrisisDetector {
  static const List<String> _crisisTriggers = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'don\'t want to be here',
    'dont want to be here',
    'don\'t want to live',
    'dont want to live',
    'hurt myself',
    'self-harm',
    'self harm',
    'overdose',
    'better off dead',
    'no way out',
    'hopeless',
    'giving up',
    'goodbye everyone',
    'can\'t go on',
    'cant go on',
    'end it all',
    'no reason to live',
    'tired of living',
  ];

  /// Backwards-compatible entrypoint
  static bool detectCrisis(String message) => detect(message);

  /// Detects if the message contains crisis-related keywords
  static bool detect(String message) {
    final lower = message.toLowerCase();
    final allTriggers = <String>{...Constants.crisisTriggers, ..._crisisTriggers};
    for (final trigger in allTriggers) {
      final phrase = trigger.toLowerCase();
      final pattern = RegExp('(^|\\s)${RegExp.escape(phrase)}(\\s|$)');
      if (pattern.hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Returns the formatted crisis resource message as specified in Part 3.7
  static String getCrisisResourceMessage() {
    return '''I'm sensing that you're carrying a heavy burden and going through a painful moment right now.
Please know that your life matters, you are not alone, and there is real support available right this second.

Please reach out to one of these free, confidential helplines:

🆘 iCall Psychosocial Helpline: 9152987821 (Mon-Sat, 8am-10pm)
🆘 Vandrevala Foundation: +91 9999 666 555 / 1860-2662-345 (24/7)
🆘 AASRA Suicide Prevention: 9820466726 (24/7)
🆘 Tele-MANAS (Govt of India): 14416 (24/7 Toll-Free)

You deserve compassionate, professional support. Please reach out to them now. 💙''';
  }

  /// Returns a structured list for UI buttons and cards
  static List<Map<String, String>> getResources() {
    return [
      {
        'name': 'Tele-MANAS (National Mental Health Helpline)',
        'number': '14416',
        'desc': 'Free, 24/7 mental health support across India',
      },
      {
        'name': 'Vandrevala Foundation',
        'number': '9999666555',
        'desc': '24/7 Mental Health Helpline',
      },
      {
        'name': 'AASRA Helpline',
        'number': '9820466728',
        'desc': '24/7 Suicide Prevention & Crisis Intervention',
      },
      {
        'name': 'Emergency services (India)',
        'number': '112',
        'desc': 'Call if you or someone else is in immediate danger',
      },
    ];
  }
}
