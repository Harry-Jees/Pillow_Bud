import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class DateUtils {
  static DateTime _calendarDay(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  static String formatTime(DateTime dt) {
    final now = DateTime.now();
    final day = _calendarDay(dt);
    final today = _calendarDay(now);

    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return DateFormat('MMM d').format(dt);
  }

  static String formatTimeOfDay(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  static String formatDateTime(DateTime dt) {
    final now = DateTime.now();

    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return 'Today at ${DateFormat("h:mm a").format(dt)}';
    }

    return DateFormat('MMM d, yyyy').format(dt);
  }

  static int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    try {
      // UTC calendar-day keys avoid daylight-saving duration anomalies.
      final uniqueDays = dates.map(_calendarDay).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      final today = _calendarDay(DateTime.now());
      final mostRecent = uniqueDays.first;

      // An old streak is not presented as current after the user has been away.
      final daysSinceLastCheckIn = today.difference(mostRecent).inDays;
      if (daysSinceLastCheckIn < 0 || daysSinceLastCheckIn > 1) return 0;

      var streak = 1;
      var previous = mostRecent;
      for (final day in uniqueDays.skip(1)) {
        if (previous.difference(day).inDays != 1) break;
        streak++;
        previous = day;
      }
      return streak;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return 0;
    }
  }

  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.day == now.day && dt.month == now.month && dt.year == now.year;
  }
}
