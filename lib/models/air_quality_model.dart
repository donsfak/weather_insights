class AirQualityModel {
  final int aqi; // Air Quality Index (1-5)
  final double pm25; // PM2.5
  final double pm10; // PM10
  final double no2; // Nitrogen dioxide
  final double o3; // Ozone
  final double co; // Carbon monoxide

  AirQualityModel({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.no2,
    required this.o3,
    required this.co,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final components = json['components'] ?? {};

    return AirQualityModel(
      aqi: main['aqi'] ?? 1,
      pm25: (components['pm2_5'] ?? 0.0).toDouble(),
      pm10: (components['pm10'] ?? 0.0).toDouble(),
      no2: (components['no2'] ?? 0.0).toDouble(),
      o3: (components['o3'] ?? 0.0).toDouble(),
      co: (components['co'] ?? 0.0).toDouble(),
    );
  }

  String get aqiLevel {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  String get healthRecommendation {
    switch (aqi) {
      case 1:
        return 'Air quality is good. Ideal for outdoor activities.';
      case 2:
        return 'Air quality is acceptable. Sensitive groups should limit outdoor exposure.';
      case 3:
        return 'Reduce prolonged outdoor exertion. Sensitive groups should avoid outdoor activities.';
      case 4:
        return 'Avoid outdoor activities. Everyone may experience health effects.';
      case 5:
        return 'Stay indoors. Air quality is hazardous to health.';
      default:
        return 'Air quality data unavailable.';
    }
  }
}
