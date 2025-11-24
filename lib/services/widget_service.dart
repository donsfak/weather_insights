import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../managers/settings_manager.dart';

import 'package:flutter/foundation.dart';
import 'dart:io';

class WidgetService {
  static const String _widgetName = 'WeatherWidget';

  /// Initialize the widget service
  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      await HomeWidget.setAppGroupId('group.weather.insights');
      debugPrint('[WidgetService] Initialized');
    } catch (e) {
      debugPrint('[WidgetService] Error initializing: $e');
    }
  }

  /// Update widget with current weather data
  static Future<void> updateWidget(WeatherModel? weather) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    if (weather == null) {
      debugPrint('[WidgetService] No weather data to update widget');
      return;
    }

    try {
      final currentDay = weather.daily.first;
      final temp = SettingsManager().convertTemp(currentDay.temp);
      final tempUnit = SettingsManager().tempUnit;

      // Save data to shared preferences for widget
      await HomeWidget.saveWidgetData<String>('city', weather.city);
      await HomeWidget.saveWidgetData<String>(
        'temperature',
        '${temp.toStringAsFixed(0)}$tempUnit',
      );
      await HomeWidget.saveWidgetData<String>(
        'condition',
        currentDay.condition,
      );
      await HomeWidget.saveWidgetData<String>(
        'feelsLike',
        '${SettingsManager().convertTemp(currentDay.feelsLike).toStringAsFixed(0)}$tempUnit',
      );
      await HomeWidget.saveWidgetData<int>('humidity', currentDay.humidity);
      await HomeWidget.saveWidgetData<String>(
        'wind',
        '${currentDay.wind.toStringAsFixed(1)} ${SettingsManager().speedUnit}',
      );

      // Save 3-day forecast for medium widget
      for (int i = 0; i < 3 && i < weather.daily.length; i++) {
        final day = weather.daily[i];
        final dayTemp = SettingsManager().convertTemp(day.temp);
        await HomeWidget.saveWidgetData<String>(
          'day${i}_temp',
          '${dayTemp.toStringAsFixed(0)}$tempUnit',
        );
        await HomeWidget.saveWidgetData<String>(
          'day${i}_condition',
          day.condition,
        );
        await HomeWidget.saveWidgetData<String>(
          'day${i}_date',
          _formatDate(day.date, i),
        );
      }

      // Save last update time
      await HomeWidget.saveWidgetData<String>(
        'lastUpdate',
        _formatTime(DateTime.now()),
      );

      // Update the widget
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );

      debugPrint('[WidgetService] Widget updated successfully');
    } catch (e) {
      debugPrint('[WidgetService] Error updating widget: $e');
    }
  }

  /// Format date for display
  static String _formatDate(DateTime date, int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';

    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  /// Format time for display
  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get weather icon based on condition
  static String getWeatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('clear') || lower.contains('sunny')) return '☀️';
    if (lower.contains('cloud')) return '☁️';
    if (lower.contains('rain') || lower.contains('drizzle')) return '🌧️';
    if (lower.contains('thunder') || lower.contains('storm')) return '⛈️';
    if (lower.contains('snow')) return '❄️';
    if (lower.contains('mist') || lower.contains('fog')) return '🌫️';
    if (lower.contains('wind')) return '💨';
    return '🌤️';
  }
}
