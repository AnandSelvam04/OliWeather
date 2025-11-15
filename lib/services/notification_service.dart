import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show high rain chance alert
  Future<void> showHighRainAlert(int rainChance) async {
    if (rainChance < 70) return; // Only alert if 70% or higher

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'rain_alerts',
          'Rain Alerts',
          channelDescription: 'Notifications for high rain chances',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1,
      '⚠️ High Rain Alert',
      'Rain chance is $rainChance%! Heavy rain expected today.',
      details,
      payload: 'high_rain_alert',
    );
  }

  /// Show umbrella warning
  Future<void> showUmbrellaWarning(int rainChance, double totalRain) async {
    if (rainChance < 40) return; // Only alert if 40% or higher

    String message;
    if (rainChance >= 70) {
      message =
          '☂️ Don\'t forget your umbrella! $rainChance% rain chance, ${totalRain.toStringAsFixed(1)}mm expected.';
    } else {
      message =
          '☂️ You might need an umbrella today. $rainChance% rain chance.';
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'umbrella_warnings',
          'Umbrella Warnings',
          channelDescription: 'Reminders to carry an umbrella',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      2,
      'Umbrella Reminder',
      message,
      details,
      payload: 'umbrella_warning',
    );
  }

  /// Show heavy rain notification
  Future<void> showHeavyRainNotification(double rainAmount) async {
    if (rainAmount < 10.0) return; // Only alert if 10mm or more

    String severity;
    if (rainAmount >= 50) {
      severity = 'Very Heavy';
    } else if (rainAmount >= 25) {
      severity = 'Heavy';
    } else {
      severity = 'Moderate';
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'heavy_rain',
          'Heavy Rain Alerts',
          channelDescription: 'Notifications for heavy rainfall',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      3,
      '🌧️ $severity Rain Alert',
      '${rainAmount.toStringAsFixed(1)}mm of rain expected today. Stay safe!',
      details,
      payload: 'heavy_rain_alert',
    );
  }

  /// Check weather and send appropriate notifications
  Future<void> checkAndNotify({
    required int rainChance,
    required double totalRain,
  }) async {
    await initialize();

    // Show heavy rain notification first (highest priority)
    if (totalRain >= 10.0) {
      await showHeavyRainNotification(totalRain);
    }
    // Then high rain alert
    else if (rainChance >= 70) {
      await showHighRainAlert(rainChance);
    }
    // Then umbrella warning
    else if (rainChance >= 40) {
      await showUmbrellaWarning(rainChance, totalRain);
    }
  }

  /// Schedule morning umbrella reminder (8 AM)
  Future<void> scheduleMorningReminder(int rainChance, double totalRain) async {
    await initialize();

    if (rainChance < 30) return; // Only schedule if rain is likely

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0);

    // If it's already past 8 AM, schedule for tomorrow
    if (now.hour >= 8) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'morning_reminder',
          'Morning Reminders',
          channelDescription: 'Daily morning weather reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      4,
      '🌤️ Good Morning!',
      'Rain chance today: $rainChance%. ${rainChance >= 50 ? "Don't forget your umbrella! ☂️" : "Have a great day!"}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'morning_reminder',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation
          .requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }
}
