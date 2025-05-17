import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotifierHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tododo_channel',
    'Tododo Notifications',
    description: 'Notifikasi alarm dan pengingat Tododo',
    importance: Importance.max,
    playSound: true,
  );

  /// Inisialisasi plugin notifikasi lokal.
  static Future<void> initializeNotificationPlugin() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Buat channel untuk Android
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Request permission untuk iOS
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Menjadwalkan notifikasi pada waktu tertentu.
  static Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    // Jangan jadwalkan jika waktu sudah lewat
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('Scheduled time sudah lewat, notifikasi tidak dijadwalkan.');
      return;
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Membatalkan notifikasi berdasarkan id.
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
