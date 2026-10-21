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
    'can\'t go on',
    'cant go on',
    'end it all',
    'no reason to live',
    'tired of living',
    'i cannot keep myself safe',
    "i can't keep myself safe",
    'i have a plan to end my life',
    'i might not be here tomorrow',
    'i do not trust myself to stay safe',
    "i don't trust myself to stay safe",
  ];

  /// Backwards-compatible entrypoint
  static bool detectCrisis(String message) => detect(message);

  /// Detects selected high-signal crisis phrases. This heuristic is not a risk assessment.
  static bool detect(String message) {
    final lower = message
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r'[.,!?;:()"]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Avoid raising the emergency overlay for a standalone, explicit denial.
    // Any additional risk language in a longer message is still evaluated.
    const explicitDenials = [
      "i am not suicidal",
      "i'm not suicidal",
      "im not suicidal",
      "i don't want to hurt myself",
      "i do not want to hurt myself",
      "i don't want to kill myself",
      "i do not want to kill myself",
      "i am not going to hurt myself",
      "i'm not going to hurt myself",
    ];
    if (explicitDenials.contains(lower)) return false;

    final allTriggers = <String>{...Constants.crisisTriggers, ..._crisisTriggers};
    for (final trigger in allTriggers) {
      final phrase = trigger.toLowerCase();
      final pattern = RegExp(r'(^|\s)' + RegExp.escape(phrase) + r'(\s|$)');
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

🆘 Tele-MANAS (Govt. of India): 14416 or 1800-891-4416 (24/7, free)
🆘 Vandrevala Foundation: +91 9999 666 555 (24/7)
🆘 AASRA: 9820466728
🆘 Immediate danger in India: 112

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
