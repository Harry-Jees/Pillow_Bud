import 'package:pillow_bud/config/constants.dart';

class CrisisDetector {
  static const List<String> _localTriggers = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'don\'t want to be here',
    'hurt myself',
    'self-harm',
    'cutting',
    'overdose',
    'better off dead',
    'no way out',
    'hopeless',
    'giving up',
    'goodbye everyone',
    'can\'t go on',
  ];

  /// Backwards-compatible entrypoint
  static bool detectCrisis(String message) => detect(message);

  /// Detects if the message contains crisis-related keywords
  static bool detect(String message) {
    final lower = message.toLowerCase();

    final triggers = <String>{...Constants.crisisTriggers, ..._localTriggers};
    for (final trigger in triggers) {
      if (lower.contains(trigger.toLowerCase())) return true;
    }

    return false;
  }

  /// Returns the formatted crisis resource message as specified in Part 3.7
  static String getCrisisResourceMessage() {
    return '''I'm sensing that you're going through an incredibly difficult time right now.
Please know that you aren't alone and there are people who want to support you.

Please reach out to someone right now:
Here are some resources where you can find immediate help:

🆘 ${Constants.icallName}
   ${Constants.icallNumber}
📞 ${Constants.icallName}: ${Constants.icallNumber}
📞 ${Constants.vandrevalaName}: ${Constants.vandrevalaNumber}
📞 ${Constants.aasraName}: ${Constants.aasraNumber}

🆘 ${Constants.vandrevalaName}
   ${Constants.vandrevalaNumber}

🆘 ${Constants.aasraName}
   ${Constants.aasraNumber}

You deserve real, professional support.
Please call now. 💙
''';
  }

  /// Returns a structured list for the Profile screen
  static List<Map<String, String>> getResources() {
    return [
      {
        'name': Constants.icallName,
        'number': Constants.icallNumber,
        'desc': 'iCall - Psychosocial Helpline',
      },
      {
        'name': Constants.vandrevalaName,
        'number': Constants.vandrevalaNumber,
        'desc': 'Free mental health support',
      },
      {
        'name': Constants.aasraName,
        'number': Constants.aasraNumber,
        'desc': '24/7 Suicide Prevention',
      },
    ];
  }
}

