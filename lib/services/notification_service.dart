import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[NotificationService] Tapped: ${details.payload}');
      },
    );

    _initialized = true;
    debugPrint('[NotificationService] Initialized');
  }

  static Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
  }

  /// Show weather alert notification
  static Future<void> showWeatherAlert(WeatherAlert alert) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Severe weather warnings and alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      alert.hashCode,
      '⚠️ ${alert.event}',
      alert.description.length > 100
          ? '${alert.description.substring(0, 100)}...'
          : alert.description,
      details,
      payload: 'alert:${alert.event}',
    );

    debugPrint('[NotificationService] Showed alert: ${alert.event}');
  }

  /// Show daily weather summary
  static Future<void> showDailySummary(WeatherModel weather) async {
    final today = weather.daily.first;
    final temp = today.temp.toStringAsFixed(0);

    const androidDetails = AndroidNotificationDetails(
      'daily_weather',
      'Daily Weather',
      channelDescription: 'Daily weather forecast summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      '🌤️ Weather in ${weather.city}',
      '$temp°C, ${today.condition}',
      details,
      payload: 'daily_summary',
    );

    debugPrint('[NotificationService] Showed daily summary');
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('[NotificationService] Cancelled all notifications');
  }
}
