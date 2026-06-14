class UserPreference {
  final String userName;
  final String buddyPersonality; // gentle, curious, wise, balanced
  final bool isDarkMode;
  final String primaryColor; // hex format
  final String secondaryColor;
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;

  UserPreference({
    required this.userName,
    required this.buddyPersonality,
    required this.isDarkMode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onboardingCompleted,
    this.onboardingCompletedAt,
  });

  factory UserPreference.empty() {
    return UserPreference(
      userName: '',
      buddyPersonality: 'balanced',
      isDarkMode: true,
      primaryColor: '#C4A8F8',
      secondaryColor: '#89C4F8',
      onboardingCompleted: false,
    );
  }
}
