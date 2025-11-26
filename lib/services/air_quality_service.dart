import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/air_quality_model.dart';
import '../utils/exceptions.dart';
import '../utils/retry_utils.dart';
import 'cache_service.dart';

class AirQualityService {
  final String baseUrl =
      'https://api.openweathermap.org/data/2.5/air_pollution';
  final http.Client client;

  AirQualityService({http.Client? client}) : client = client ?? http.Client();

  String? _apiKey() {
    final envKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) return envKey;
    final compileKey = const String.fromEnvironment('OPENWEATHER_API_KEY');
    if (compileKey.isNotEmpty) return compileKey;
    return null;
  }

  Future<AirQualityModel?> fetchAirQuality(double lat, double lon) async {
    final key = _apiKey();
    if (key == null) {
      throw WeatherException('API key not configured');
    }

    try {
      final url = Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$key');
      // ignore: avoid_print
      print('[AirQualityService] GET ${url.toString().replaceAll(key, '***')}');

      // Try to get cached data first
      final cached = await CacheService.getCachedAirQuality(lat, lon);
      if (cached != null) {
        // ignore: avoid_print
        print('[AirQualityService] Returning cached data for $lat, $lon');
        return cached;
      }

      final response = await RetryUtils.retry(
        () => client.get(url),
        shouldRetry: (e) => e is SocketException || e is http.ClientException,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aqi = AirQualityModel.fromJson(data);

        // Cache the result
        try {
          await CacheService.saveAirQuality(lat, lon, aqi);
        } catch (e) {
          // ignore: avoid_print
          print('[AirQualityService] Cache save error: $e');
        }

        return aqi;
      } else {
        throw ApiException(
          response.statusCode,
          'Failed to fetch air quality data',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Unexpected error: $e');
    }
  }
}
