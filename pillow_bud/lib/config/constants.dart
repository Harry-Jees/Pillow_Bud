class Constants {
  // Crisis resources (India-focused). Keep these aligned with
  // CrisisDetector.getResources() and periodically re-verify official sources.
  static const String icallNumber = '02225521111';
  static const String icallName = 'iCall India';

  static const String vandrevalaNumber = '9999666555';
  static const String vandrevalaName = 'Vandrevala Foundation';

  static const String aasraNumber = '9820466728';
  static const String aasraName = 'AASRA';

  // Crisis Trigger Phrases
  static const List<String> crisisTriggers = [
    'kill myself',
    'end my life',
    'suicide',
    'overdose',
    'want to die',
    'better off dead',
    'harm myself',
    'cut myself',
    'slit wrist',
    'not worth living',
    'no point in living',
    'should die',
    'wish i was dead',
  ];

  // App Info
  static const String appName = 'Pillow Bud';
  static const String appVersion = '1.0.0';
  static const String budPersonality = 'balanced';
}
