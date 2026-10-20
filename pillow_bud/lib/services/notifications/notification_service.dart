import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

/// Manages daily check-in notifications for Pillow Bud.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _enabledKey = 'notifications_enabled';
  static const _hourKey = 'notification_hour';
  static const _minuteKey = 'notification_minute';
  static const int _dailyCheckInId = 1;

  static bool _initialized = false;

  /// Must be called once at app start.
  static Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Requests notification permission (required on Android 13+, iOS).
  static Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;
    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? false;
    }
    if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return granted;
  }

  /// Returns whether notifications are enabled by the user.
  static Future<bool> isEnabled() async {
    final val = await SecureKeyStorage.read(_enabledKey);
    return val == 'true';
  }

  /// Persists user preference and schedules/cancels accordingly.
  static Future<void> setEnabled(bool enabled, {TimeOfDay? time}) async {
    await SecureKeyStorage.write(_enabledKey, enabled.toString());
    if (enabled) {
      final t = time ?? const TimeOfDay(hour: 20, minute: 0);
      await scheduleDailyReminder(t);
    } else {
      await cancelDailyReminder();
    }
  }

  /// Gets the persisted reminder time, defaulting to 8 PM.
  static Future<TimeOfDay> getReminderTime() async {
    final h = int.tryParse(await SecureKeyStorage.read(_hourKey) ?? '20') ?? 20;
    final m = int.tryParse(await SecureKeyStorage.read(_minuteKey) ?? '0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  /// Schedules a daily notification at the given time.
  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await SecureKeyStorage.write(_hourKey, time.hour.toString());
    await SecureKeyStorage.write(_minuteKey, time.minute.toString());

    const androidDetails = AndroidNotificationDetails(
      'daily_checkin',
      'Daily Check-In',
      channelDescription: 'Gentle daily nudge to reflect on your day with Bud',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.periodicallyShow(
      _dailyCheckInId,
      'Hey, how was your day? 🌸',
      'Bud is here whenever you want to share your thoughts.',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancels the daily reminder.
  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyCheckInId);
  }
}
