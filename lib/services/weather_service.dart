import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';
import '../models/weather_model.dart';
import '../utils/exceptions.dart';
import '../utils/retry_utils.dart';

class WeatherService {
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final http.Client client;

  WeatherService({http.Client? client}) : client = client ?? http.Client();

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
      throw WeatherException('API key not configured');
    }

    final url = (lat != null && lon != null)
        ? Uri.parse(
            '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$key&units=metric',
          )
        : Uri.parse('$baseUrl/forecast?q=$city&appid=$key&units=metric');

    // ignore: avoid_print
    print('[WeatherService] GET ${url.toString().replaceAll(key, '***')}');

    // Try to get cached data first
    if (city.isNotEmpty) {
      final cached = await CacheService.getCachedWeather(city);
      if (cached != null) {
        // ignore: avoid_print
        print('[WeatherService] Returning cached data for $city');
        return cached;
      }
    }

    try {
      final response = await RetryUtils.retry(
        () => client.get(url),
        shouldRetry: (e) => e is SocketException || e is http.ClientException,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract coordinates from weather response to fetch UV index
        double? fetchedLat = lat;
        double? fetchedLon = lon;

        if (fetchedLat == null || fetchedLon == null) {
          try {
            final cityData = data['city'];
            if (cityData != null && cityData['coord'] != null) {
              fetchedLat = (cityData['coord']['lat'] as num).toDouble();
              fetchedLon = (cityData['coord']['lon'] as num).toDouble();
            }
          } catch (e) {
            // ignore: avoid_print
            print('[WeatherService] Failed to extract coords: $e');
          }
        }

        // Fetch UV index if we have coordinates
        double uvIndex = 0.0;
        if (fetchedLat != null && fetchedLon != null) {
          uvIndex = await _fetchUVIndex(fetchedLat, fetchedLon, city);
        }

        final weatherModel = WeatherModel.fromJson(
          data,
          uvIndexOverride: uvIndex,
        );

        // cache the successful response
        try {
          await CacheService.saveWeather(
            city.isEmpty ? 'current_location' : city,
            weatherModel,
          );
        } catch (e) {
          // ignore: avoid_print
          print('[WeatherService] Cache save error: $e');
        }

        return weatherModel;
      } else if (response.statusCode == 404) {
        return null; // City not found
      } else {
        throw ApiException(response.statusCode, 'Failed to fetch weather data');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Unexpected error: $e');
    }
  }

  Future<double> _fetchUVIndex(double? lat, double? lon, String city) async {
    try {
      // If we don't have coords, we can't easily get UV from Open-Meteo without geocoding.
      // For now, if no coords, return 0.0 or try to get coords from weather response (but that's circular).
      // However, fetchWeather usually has coords if called by location, or we rely on city search.
      // If city search, we might need to wait for weather response to get coords.
      // Strategy: If lat/lon provided, fetch UV. If not, we'll have to skip UV for now or do a 2-step process.
      // Actually, WeatherModel.fromJson parses the city coords.
      // Let's change strategy: Fetch weather first, get coords, then fetch UV if needed.
      // But to keep it fast, we'll only fetch UV if we have coords.

      if (lat == null || lon == null) {
        // If we are searching by city, we don't have coords yet.
        // We'll return 0.0 here and handle it after parsing weather?
        // Or better: Fetch weather, get coords from response, THEN fetch UV.
        return 0.0;
      }

      final uvUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=uv_index_max&timezone=auto&forecast_days=1',
      );

      final response = await client.get(uvUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['daily']['uv_index_max'][0] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Error fetching UV index: $e');
      return 0.0;
    }
  }

  Future<WeatherModel?> fetchWeatherByCoords(double lat, double lon) async {
    return fetchWeather('', lat: lat, lon: lon);
  }
}
