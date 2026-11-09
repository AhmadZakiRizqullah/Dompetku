import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint('Failed to set Asia/Jakarta timezone: $e');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // App opened from notification
      },
    );

    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await init();
    await _notificationsPlugin.cancel(id: 1001);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Pengingat Harian',
      channelDescription:
          'Pengingat harian untuk mencatat transaksi keuangan di Dompetku',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _notificationsPlugin.zonedSchedule(
      id: 1001,
      title: 'Yuk, Catat Keuanganmu! 📝',
      body: 'Sudah mencatat pengeluaran dan pemasukan hari ini di Dompetku?',
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(id: 1001);
  }

  Future<void> showTestNotification() async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Notifikasi Pengujian',
      channelDescription: 'Pengujian notifikasi Dompetku',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _notificationsPlugin.show(
      id: 9999,
      title: 'Pengingat Dompetku Aktif! ✨',
      body: 'Notifikasi pengingat harian berhasil diatur. Catat terus keuanganmu ya!',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }
}
