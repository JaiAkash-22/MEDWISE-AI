import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      final notifGranted = await androidImpl.requestNotificationsPermission();
      final alarmGranted = await androidImpl.requestExactAlarmsPermission();
      print('MedWise: notifications permission granted = $notifGranted');
      print('MedWise: exact alarms permission granted = $alarmGranted');
    }

    final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
    print('MedWise: battery optimization exemption = $batteryStatus');
  }

  Future<void> scheduleDaily({
    required int id,
    required String medicineName,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    print('MedWise: current time (tz.local) = $now');
    print('MedWise: scheduling reminder id=$id for = $scheduled');
    print('MedWise: minutes from now = ${scheduled.difference(now).inMinutes}');

    await _plugin.zonedSchedule(
      id,
      'Time for your medicine',
      'It\'s time to take $medicineName.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medwise_reminders',
          'Medicine Reminders',
          channelDescription: 'Daily medicine reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('MedWise: zonedSchedule call completed without throwing');

    final pending = await _plugin.pendingNotificationRequests();
    print('MedWise: pending notifications count = ${pending.length}');
    for (final p in pending) {
      print('MedWise: pending -> id=${p.id}, title=${p.title}');
    }
  }

  Future<void> showTestNotification() async {
    await _plugin.show(
      999,
      'Test Notification',
      'If you see this, notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medwise_reminders',
          'Medicine Reminders',
          channelDescription: 'Daily medicine reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}