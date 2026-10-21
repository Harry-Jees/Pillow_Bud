import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class DateUtils {
  static String formatTime(DateTime dt) {
    final now = DateTime.now();

    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return 'Today';
    }

    if (dt.day == now.day - 1) {
      return 'Yesterday';
    }

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
      // Normalize to calendar days and deduplicate multiple check-ins on one day.
      final uniqueDays = dates
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final mostRecent = uniqueDays.first;

      // An old streak is not presented as current after the user has been away.
      final daysSinceLastCheckIn = todayOnly.difference(mostRecent).inDays;
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
