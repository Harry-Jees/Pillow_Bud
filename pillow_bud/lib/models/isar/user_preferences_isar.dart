import 'package:isar/isar.dart';

part 'user_preferences_isar.g.dart';

@Collection()
class UserPreferencesIsar {
  Id id = Isar.autoIncrement;

  late String userName;

  late String buddyPersonality;

  late bool onboardingCompleted;

  DateTime? onboardingCompletedAt;

  late bool isDarkMode;

  String? primaryColor;

  String? secondaryColor;
}
