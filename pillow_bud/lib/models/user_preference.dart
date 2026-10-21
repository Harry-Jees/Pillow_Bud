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
      primaryColor: '#8B78D6',
      secondaryColor: '#76B8E8',
      onboardingCompleted: false,
    );
  }
}
