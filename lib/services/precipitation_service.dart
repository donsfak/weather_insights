import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/exceptions.dart';

/// Model for a single precipitation frame
class PrecipitationFrame {
  final int timestamp;
  final String path;

  PrecipitationFrame({required this.timestamp, required this.path});

  factory PrecipitationFrame.fromJson(Map<String, dynamic> json) {
    return PrecipitationFrame(
      timestamp: json['time'] as int,
      path: json['path'] as String,
    );
  }
}

/// Service to fetch RainViewer precipitation data
class PrecipitationService {
  static const String _apiUrl =
      'https://api.rainviewer.com/public/weather-maps.json';
  static const String _tileHost = 'https://tilecache.rainviewer.com';

  final http.Client client;

  PrecipitationService({http.Client? client})
    : client = client ?? http.Client();

  /// Fetch precipitation frames (past and future)
  Future<List<PrecipitationFrame>> fetchFrames() async {
    try {
      final response = await client.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<PrecipitationFrame> frames = [];

        // Get past radar frames (last 2 hours)
        if (data['radar'] != null && data['radar']['past'] != null) {
          final past = data['radar']['past'] as List;
          // Take last 8 frames (2 hours at 15-min intervals)
          final recentPast = past.length > 8
              ? past.sublist(past.length - 8)
              : past;
          frames.addAll(
            recentPast.map((frame) => PrecipitationFrame.fromJson(frame)),
          );
        }

        // Get nowcast frames (next 30-60 minutes)
        if (data['radar'] != null && data['radar']['nowcast'] != null) {
          final nowcast = data['radar']['nowcast'] as List;
          frames.addAll(
            nowcast.map((frame) => PrecipitationFrame.fromJson(frame)),
          );
        }

        // ignore: avoid_print
        print('[PrecipitationService] Fetched ${frames.length} frames');
        return frames;
      } else {
        throw ApiException(
          response.statusCode,
          'Failed to fetch precipitation data',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Unexpected error: $e');
    }
  }

  /// Build tile URL for a given frame
  static String getTileUrl(String path, int z, int x, int y) {
    return '$_tileHost$path/256/$z/$x/$y/2/1_1.png';
  }
}
