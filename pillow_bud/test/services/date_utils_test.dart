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

    test('returns zero for a streak that ended more than one day ago', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 3));
      expect(app_dates.DateUtils.calculateStreak([oldDate]), 0);
    });

    test('returns zero when there are no check-ins', () {
      expect(app_dates.DateUtils.calculateStreak([]), 0);
    });
  });
}
