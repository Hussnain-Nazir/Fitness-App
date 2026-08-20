// notification_service.dart
// Wraps flutter_local_notifications to provide REAL device notifications
// (not a UI simulation). This is the file to link for the "notification
// configure" / notification implementation checklist items.
//
// Two capabilities are exposed:
//   1. showInstant()   -> fires a notification immediately (great for a
//                         quick "does it work" screenshot).
//   2. scheduleReminder() -> schedules a real notification N seconds/minutes
//                            in the future using the device's local timezone.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Call once, early in main(), before runApp().
  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Using UTC as a safe default. Swap in a device-timezone package
    // (e.g. flutter_timezone) if you need exact local-time scheduling.
    tz.setLocalLocation(tz.UTC);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Requests notification permission (required on Android 13+ and iOS).
  /// Call this from a button tap so the OS permission dialog has a clear
  /// user gesture behind it.
  static Future<void> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'fitness_tracker_channel',
    'Fitness Tracker Reminders',
    channelDescription: 'Workout and habit reminders',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  /// Fires a notification immediately. Useful to verify notifications work
  /// at all on the current device/emulator.
  static Future<void> showInstant({
    required String title,
    required String body,
  }) async {
    await _plugin.show(0, title, body, _details);
  }

  /// Schedules a real notification `secondsFromNow` seconds in the future.
  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required int secondsFromNow,
  }) async {
    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ---------- Vexon daily reminders ----------
  // Fixed ids so each reminder type can be toggled independently without
  // stacking duplicate notifications.
  static const int _workoutReminderId = 101;
  static const int _waterReminderId = 102;
  static const int _mealReminderId = 103;

  /// Schedules a recurring daily reminder at [hour]:[minute] local time.
  /// Repeats automatically via [DateTimeComponents.time] - a lightweight
  /// approach that needs no background job or server.
  static Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    var scheduled = tz.TZDateTime(
      tz.local,
      tz.TZDateTime.now(tz.local).year,
      tz.TZDateTime.now(tz.local).month,
      tz.TZDateTime.now(tz.local).day,
      hour,
      minute,
    );
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleWorkoutReminder({int hour = 18, int minute = 0}) =>
      _scheduleDaily(
        id: _workoutReminderId,
        title: 'Time to train',
        body: 'Nox is waiting - get today\'s workout in.',
        hour: hour,
        minute: minute,
      );

  static Future<void> scheduleWaterReminder({int hour = 14, int minute = 0}) =>
      _scheduleDaily(
        id: _waterReminderId,
        title: 'Hydration check',
        body: 'Log your water intake for the day.',
        hour: hour,
        minute: minute,
      );

  static Future<void> scheduleMealReminder({int hour = 12, int minute = 30}) =>
      _scheduleDaily(
        id: _mealReminderId,
        title: 'Meal reminder',
        body: 'Log your meal to stay on top of today\'s calorie target.',
        hour: hour,
        minute: minute,
      );

  static Future<void> cancelWorkoutReminder() => _plugin.cancel(_workoutReminderId);
  static Future<void> cancelWaterReminder() => _plugin.cancel(_waterReminderId);
  static Future<void> cancelMealReminder() => _plugin.cancel(_mealReminderId);
}
