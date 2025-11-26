import 'package:hive/hive.dart';

part 'cache_models.g.dart';

@HiveType(typeId: 0)
class CachedWeather extends HiveObject {
  @HiveField(0)
  final String city;

  @HiveField(1)
  final String jsonData;

  @HiveField(2)
  final DateTime timestamp;

  CachedWeather({
    required this.city,
    required this.jsonData,
    required this.timestamp,
  });

  bool get isExpired {
    // Cache expires after 1 hour
    return DateTime.now().difference(timestamp).inHours >= 1;
  }
}

@HiveType(typeId: 1)
class CachedAirQuality extends HiveObject {
  @HiveField(0)
  final double lat;

  @HiveField(1)
  final double lon;

  @HiveField(2)
  final String jsonData;

  @HiveField(3)
  final DateTime timestamp;

  CachedAirQuality({
    required this.lat,
    required this.lon,
    required this.jsonData,
    required this.timestamp,
  });

  bool get isExpired {
    // Cache expires after 2 hours
    return DateTime.now().difference(timestamp).inHours >= 2;
  }
}
