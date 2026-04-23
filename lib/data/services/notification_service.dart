// lib/data/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Request notification permissions
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> showTaskNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'taskflow_channel',
          'TaskFlow',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    // For tasks with only date (no time), set due date to end of day
    final adjustedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59);

    final scheduledDate = tz.TZDateTime.from(
      adjustedDueDate.subtract(const Duration(days: 1)),
      tz.local,
    );

    // Schedule the main reminder notification (1 day before due date)
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _plugin.zonedSchedule(
        id,
        'Task Due Soon',
        '"$taskTitle" is due in 1 day',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails('taskflow_channel', 'TaskFlow'),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // For testing: Show an immediate notification when task is created
    // This helps verify notifications are working
    await _plugin.show(
      id + 1000000, // Use a different ID to avoid conflicts
      'Task Created',
      '"$taskTitle" has been created successfully!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'taskflow_channel',
          'TaskFlow',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
