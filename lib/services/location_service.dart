import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Request permission and return current device position.
  /// Returns null on failure or if permissions are denied.
  static Future<Position?> getCurrentPosition({LocationAccuracy accuracy = LocationAccuracy.low}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return null;
    }

    try {
      // `desiredAccuracy` is deprecated; use `locationSettings` instead.
      // Use a generic LocationSettings which works across platforms.
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      );
      return pos;
    } catch (e) {
      // ignore: avoid_print
      print('[LocationService] getCurrentPosition error: $e');
      return null;
    }
  }
}
