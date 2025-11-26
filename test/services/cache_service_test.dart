import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:weather_insights_app/models/cache_models.dart';
import 'package:weather_insights_app/models/weather_model.dart';
import 'package:weather_insights_app/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CachedWeatherAdapter());
      }
    });

    setUp(() async {
      await Hive.deleteFromDisk();
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    test('saveWeather and getCachedWeather work correctly', () async {
      final weather = WeatherModel(
        city: 'Test City',
        lat: 0,
        lon: 0,
        daily: [],
        hourly: [],
        alerts: [],
      );

      await CacheService.saveWeather('Test City', weather);
      final cached = await CacheService.getCachedWeather('Test City');

      expect(cached, isNotNull);
      expect(cached!.city, 'Test City');
    });

    test('getCachedWeather returns null for non-existent city', () async {
      final cached = await CacheService.getCachedWeather('NonExistent');
      expect(cached, isNull);
    });

    test('clearCache removes all data', () async {
      final weather = WeatherModel(
        city: 'Test City',
        lat: 0,
        lon: 0,
        daily: [],
        hourly: [],
        alerts: [],
      );

      await CacheService.saveWeather('Test City', weather);
      await CacheService.clearCache();
      final cached = await CacheService.getCachedWeather('Test City');

      expect(cached, isNull);
    });
  });
}
