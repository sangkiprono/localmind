import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../../domain/entities/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  void _onNotificationTap(NotificationResponse response) {}

  Future<void> scheduleReminder(Reminder reminder) async {
    final scheduledDate = tz.TZDateTime.from(reminder.scheduledAt, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Tap to view',
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _repeatComponent(reminder.repeatType),
    );
  }

  Future<void> cancelReminder(String id) async {
    await _plugin.cancel(id.hashCode);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> snoozeReminder(Reminder reminder, {int minutes = 10}) async {
    await cancelReminder(reminder.id);
    final snoozed = reminder.scheduledAt.add(Duration(minutes: minutes));
    await scheduleReminder(Reminder(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      scheduledAt: snoozed,
      isAllDay: reminder.isAllDay,
      priority: reminder.priority,
      repeatType: reminder.repeatType,
      categoryId: reminder.categoryId,
      isCompleted: reminder.isCompleted,
      isSnoozed: true,
      createdAt: reminder.createdAt,
      updatedAt: DateTime.now(),
    ));
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'localmind_channel',
        'LocalMind Reminders',
        channelDescription: 'Reminder notifications from LocalMind',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        actions: [
          AndroidNotificationAction('complete', 'Complete'),
          AndroidNotificationAction('snooze', 'Snooze'),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  DateTimeComponents? _repeatComponent(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return DateTimeComponents.time;
      case RepeatType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        return null;
    }
  }
}