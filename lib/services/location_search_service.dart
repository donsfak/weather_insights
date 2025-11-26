import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationSearchService {
  final http.Client client;
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  LocationSearchService({http.Client? client})
    : client = client ?? http.Client();

  /// Search for locations by name
  /// Returns list of locations with city, state, country, lat, lon
  Future<List<LocationResult>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$_apiKey',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LocationResult.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      // ignore: avoid_print
      print('[LocationSearchService] Error: $e');
      return [];
    }
  }
}

class LocationResult {
  final String name;
  final String? state;
  final String country;
  final double lat;
  final double lon;

  LocationResult({
    required this.name,
    this.state,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      name: json['name'],
      state: json['state'],
      country: json['country'],
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }
}
