import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _kLastWeatherJson = 'last_weather_json';
  static const _kTempUnit = 'temp_unit'; // "metric" or "imperial"
  static const _kLastFetchTs = 'last_fetch_ts';

  static Future<void> saveLastWeatherJson(String json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLastWeatherJson, json);
    await sp.setInt(_kLastFetchTs, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> getLastWeatherJson() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kLastWeatherJson);
  }

  static Future<DateTime?> getLastFetchTime() async {
    final sp = await SharedPreferences.getInstance();
    final ts = sp.getInt(_kLastFetchTs);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  static Future<void> saveTempUnit(String unit) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTempUnit, unit);
  }

  static Future<String> getTempUnit() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kTempUnit) ?? 'metric';
  }
}
