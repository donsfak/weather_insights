import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/air_quality_model.dart';
import 'package:flutter/foundation.dart';

class AirQualityService {
  final String baseUrl =
      'https://api.openweathermap.org/data/2.5/air_pollution';

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
      debugPrint('[AirQualityService] OPENWEATHER_API_KEY is not set');
      return null;
    }

    try {
      final url = Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$key');
      debugPrint(
        '[AirQualityService] GET ${url.toString().replaceAll(key, '***')}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['list'] != null && (data['list'] as List).isNotEmpty) {
          return AirQualityModel.fromJson(data['list'][0]);
        }
      } else {
        debugPrint('[AirQualityService] HTTP ${response.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('[AirQualityService] Error: $e');
      return null;
    }
  }
}
