import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  String? _apiKey() {
    final envKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) return envKey;
    final compileKey = const String.fromEnvironment('OPENWEATHER_API_KEY');
    if (compileKey.isNotEmpty) return compileKey;
    return null;
  }

  /// If [lat] and [lon] are provided, query by coordinates; otherwise use city name.
  Future<WeatherModel?> fetchWeather(
    String city, {
    double? lat,
    double? lon,
  }) async {
    final key = _apiKey();
    if (key == null) {
      // no key configured
      // Do not print API key. Print a helpful debug line instead.
      // Caller/UI should show a user-friendly message.
      // ignore: avoid_print
      print('[WeatherService] OPENWEATHER_API_KEY is not set');
      return null;
    }

    final url = (lat != null && lon != null)
        ? Uri.parse(
            '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$key&units=metric',
          )
        : Uri.parse('$baseUrl/forecast?q=$city&appid=$key&units=metric');
    // ignore: avoid_print
    print('[WeatherService] GET ${url.toString().replaceAll(key, '***')}');

    final response = await http.get(url);

    // debug the response code and a short excerpt if not 200
    if (response.statusCode != 200) {
      // ignore: avoid_print
      print(
        '[WeatherService] HTTP ${response.statusCode} - ${response.body.length} bytes',
      );
      return null;
    }

    // cache the last successful response
    try {
      await CacheService.saveLastWeatherJson(response.body);
    } catch (_) {}

    return WeatherModel.fromJson(jsonDecode(response.body));
  }

  /// Try to return the last cached weather JSON parsed into a model.
  Future<WeatherModel?> fetchLastCached() async {
    final cached = await CacheService.getLastWeatherJson();
    if (cached == null) return null;
    try {
      return WeatherModel.fromJson(jsonDecode(cached));
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching weather: $e');
      return null;
    }
  }

  Future<WeatherModel?> fetchWeatherByCoords(double lat, double lon) async {
    final key = _apiKey();
    if (key == null) {
      // ignore: avoid_print
      print(
        '[WeatherService] OPENWEATHER_API_KEY is not set for fetchWeatherByCoords',
      );
      return null;
    }

    try {
      final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$key&units=metric',
      );

      // ignore: avoid_print
      print(
        '[WeatherService] GET ${forecastUrl.toString().replaceAll(key, '***')}',
      );

      final response = await http.get(forecastUrl);

      if (response.statusCode == 200) {
        // cache the last successful response
        try {
          await CacheService.saveLastWeatherJson(response.body);
        } catch (_) {}

        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        // ignore: avoid_print
        print(
          '[WeatherService] HTTP ${response.statusCode} - ${response.body.length} bytes for fetchWeatherByCoords',
        );
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching weather by coords: $e');
      return null;
    }
  }
}
