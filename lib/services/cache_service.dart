import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/cache_models.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String WEATHER_BOX = 'weather_cache';
  static const String AQI_BOX = 'aqi_cache';
  static const String _kTempUnit = 'temp_unit';

  /// Save weather data to Hive cache
  static Future<void> saveWeather(String city, WeatherModel weather) async {
    final box = await Hive.openBox<CachedWeather>(WEATHER_BOX);
    final jsonData = jsonEncode(weather.toJson());

    await box.put(
      city.toLowerCase(),
      CachedWeather(city: city, jsonData: jsonData, timestamp: DateTime.now()),
    );
  }

  /// Get cached weather data if available and not expired
  static Future<WeatherModel?> getCachedWeather(String city) async {
    try {
      final box = await Hive.openBox<CachedWeather>(WEATHER_BOX);
      final cached = box.get(city.toLowerCase());

      if (cached == null) return null;

      if (cached.isExpired) {
        await box.delete(city.toLowerCase());
        return null;
      }

      final data = jsonDecode(cached.jsonData);
      return WeatherModel.fromCacheJson(data);
    } catch (e) {
      // ignore: avoid_print
      print('Cache error: $e');
      return null;
    }
  }

  /// Save air quality data to Hive cache
  static Future<void> saveAirQuality(
    double lat,
    double lon,
    AirQualityModel aqi,
  ) async {
    final box = await Hive.openBox<CachedAirQuality>(AQI_BOX);
    final jsonData = jsonEncode(aqi.toJson());
    final key = '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';

    await box.put(
      key,
      CachedAirQuality(
        lat: lat,
        lon: lon,
        jsonData: jsonData,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Get cached air quality data
  static Future<AirQualityModel?> getCachedAirQuality(
    double lat,
    double lon,
  ) async {
    try {
      final box = await Hive.openBox<CachedAirQuality>(AQI_BOX);
      final key = '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
      final cached = box.get(key);

      if (cached == null) return null;

      if (cached.isExpired) {
        await box.delete(key);
        return null;
      }

      final data = jsonDecode(cached.jsonData);
      return AirQualityModel.fromJson(data);
    } catch (e) {
      // ignore: avoid_print
      print('AQI Cache error: $e');
      return null;
    }
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    final weatherBox = await Hive.openBox<CachedWeather>(WEATHER_BOX);
    await weatherBox.clear();
    final aqiBox = await Hive.openBox<CachedAirQuality>(AQI_BOX);
    await aqiBox.clear();
  }

  // Legacy method support
  static Future<void> saveLastWeatherJson(String json) async {
    // We can optionally save to Hive here too if needed for backward compat
    // But for now, we'll leave it empty or redirect to new logic if possible
    // Since WeatherService calls this, we should probably update WeatherService instead
  }
  static Future<String?> getLastWeatherJson() async {
    return null;
  }

  // Temp Unit support (keeping SharedPreferences for this specific simple setting if needed,
  // or we can migrate. For now, let's keep it working as it was likely used)
  static Future<void> saveTempUnit(String unit) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTempUnit, unit);
  }

  static Future<String> getTempUnit() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kTempUnit) ?? 'metric';
  }
}
