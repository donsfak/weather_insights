import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  Future<WeatherModel?> fetchWeather(String city) async {
    final key = _apiKey();
    if (key == null) {
      // no key configured
      // Do not print API key. Print a helpful debug line instead.
      // Caller/UI should show a user-friendly message.
      // ignore: avoid_print
      print('[WeatherService] OPENWEATHER_API_KEY is not set');
      return null;
    }

    final url = Uri.parse('$baseUrl/forecast?q=$city&appid=$key&units=metric');
    // ignore: avoid_print
    print('[WeatherService] GET ${url.toString().replaceAll(key, '***')}');

    final response = await http.get(url);

    // debug the response code and a short excerpt if not 200
    if (response.statusCode != 200) {
      // ignore: avoid_print
      print('[WeatherService] HTTP ${response.statusCode} - ${response.body.length} bytes');
      return null;
    }

    return WeatherModel.fromJson(jsonDecode(response.body));
  }
}
