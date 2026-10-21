import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/date_utils.dart' as app_dates;

void main() {
  group('DateUtils.calculateStreak', () {
    test('deduplicates multiple check-ins on the same day', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final dates = [
        today,
        DateTime(today.year, today.month, today.day, 8),
        yesterday,
      ];

      expect(app_dates.DateUtils.calculateStreak(dates), 2);
    });

    test('counts consecutive calendar days across month boundaries', () {
      final today = DateTime.now();
      final currentDay = DateTime.utc(today.year, today.month, today.day);
      final yesterday = currentDay.subtract(const Duration(days: 1));
      final twoDaysAgo = currentDay.subtract(const Duration(days: 2));

      expect(
        app_dates.DateUtils.calculateStreak([
          DateTime(today.year, today.month, today.day),
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59),
          DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 12),
        ]),
        3,
      );
    });

    test('returns zero for a streak that ended more than one day ago', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 3));
      expect(app_dates.DateUtils.calculateStreak([oldDate]), 0);
    });

    test('returns zero when there are no check-ins', () {
      expect(app_dates.DateUtils.calculateStreak([]), 0);
    });
  });

  group('DateUtils.formatTime', () {
    test('labels the previous calendar date as Yesterday', () {
      final now = DateTime.now();
      final yesterday = DateTime.utc(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      final localYesterday = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        23,
        59,
      );

      expect(app_dates.DateUtils.formatTime(localYesterday), 'Yesterday');
    });
  });
}
