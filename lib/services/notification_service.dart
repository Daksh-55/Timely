import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' as math;
import '../models/date_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(initializationSettings);
    
    // Request permissions for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final platform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (platform != null) {
      await platform.requestNotificationsPermission();
      await platform.requestExactAlarmsPermission();
    }
  }

  Future<List<int>> scheduleNotifications(ImportantDate date) async {
    final List<int> notificationIds = [];
    
    if (!date.isNotificationEnabled) return notificationIds;

    final eventDate = tz.TZDateTime.from(date.date, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    // Generate unique notification IDs
    final baseId = _generateUniqueId();
    
    // Schedule 1 week before
    final weekBefore = eventDate.subtract(const Duration(days: 7));
    if (weekBefore.isAfter(now)) {
      final weekId = baseId;
      await _scheduleNotification(
        id: weekId,
        title: '📅 Reminder: ${date.title}',
        body: 'Your important date is coming up in 1 week!',
        scheduledDate: weekBefore,
      );
      notificationIds.add(weekId);
    }

    // Schedule 1 day before
    final dayBefore = eventDate.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(now)) {
      final dayId = baseId + 1;
      await _scheduleNotification(
        id: dayId,
        title: '⏰ Tomorrow: ${date.title}',
        body: 'Don\'t forget! Your important date is tomorrow.',
        scheduledDate: dayBefore,
      );
      notificationIds.add(dayId);
    }

    // Schedule on the day (morning notification)
    if (eventDate.isAfter(now)) {
      final morningOfEvent = tz.TZDateTime(
        tz.local,
        eventDate.year,
        eventDate.month,
        eventDate.day,
        9, // 9 AM
      );
      
      if (morningOfEvent.isAfter(now)) {
        final eventId = baseId + 2;
        await _scheduleNotification(
          id: eventId,
          title: '🎉 Today: ${date.title}',
          body: 'Your special day is here!',
          scheduledDate: morningOfEvent,
        );
        notificationIds.add(eventId);
      }
    }

    return notificationIds;
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'timely_reminders',
      'Event Reminders',
      channelDescription: 'Notifications for upcoming important dates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotifications(List<int> notificationIds) async {
    for (final id in notificationIds) {
      await _notifications.cancel(id);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  int _generateUniqueId() {
    //return DateTime.now().millisecondsSinceEpoch + math.Random().nextInt(1000);
    return math.Random().nextInt(2147483647);
  }

  // Test notification (for debugging)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'timely_test',
      'Test Notifications',
      channelDescription: 'Test notifications for Timely app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification from Timely!',
      notificationDetails,
    );
  }
}