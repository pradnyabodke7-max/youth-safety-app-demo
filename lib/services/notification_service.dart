// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps flutter_local_notifications to show in-app alerts for
/// safety events (SOS triggered, journey expired, etc).
///
/// This is LOCAL notifications only — shown by this device, to this
/// device. It does not send push notifications to other users/devices,
/// since that requires a backend server (Cloud Functions), which is
/// not part of the current Spark (free) Firebase plan.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'youth_safety_alerts';
  static const String _channelName = 'Safety Alerts';
  static const String _channelDescription =
      'Notifications for SOS events and journey timer alerts';

  /// Call once, early in app startup (before runApp).
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request runtime notification permission (required on Android 13+).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Shows a local notification with the given title/body.
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}