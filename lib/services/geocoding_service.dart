import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final String displayName;
  final double lat;
  final double lon;

  GeocodingResult({required this.displayName, required this.lat, required this.lon});
}

class GeocodingService {
  /// Search Nominatim for a city/place. Returns empty list on failure.
  static Future<List<GeocodingResult>> search(String query, {int limit = 5}) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search')
        .replace(queryParameters: {
      'q': query,
      'format': 'json',
      'limit': limit.toString(),
    });

    try {
      final resp = await http.get(url, headers: {
        'User-Agent': 'weather_insights_app/1.0 (contact@example.com)'
      });
      if (resp.statusCode != 200) return [];
      final List<dynamic> body = jsonDecode(resp.body);
      return body.map((e) => GeocodingResult(
        displayName: e['display_name'] as String,
        lat: double.parse(e['lat'] as String),
        lon: double.parse(e['lon'] as String),
      )).toList();
    } catch (e) {
      // ignore: avoid_print
      print('[GeocodingService] search error: $e');
      return [];
    }
  }
}
