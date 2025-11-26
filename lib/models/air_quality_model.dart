class AirQualityModel {
  final int aqi; // Air Quality Index (1-5)
  final double pm2_5; // PM2.5
  final double pm10; // PM10
  final double no2; // Nitrogen dioxide
  final double o3; // Ozone
  final double co; // Carbon monoxide
  final double so2; // Sulfur dioxide

  AirQualityModel({
    required this.aqi,
    required this.pm2_5,
    required this.pm10,
    required this.no2,
    required this.o3,
    required this.co,
    required this.so2,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List;
    if (list.isEmpty) throw Exception('No AQI data found');

    final item = list[0];
    final main = item['main'] ?? {};
    final components = item['components'] ?? {};

    return AirQualityModel(
      aqi: (main['aqi'] as num).toInt(),
      pm2_5: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      no2: (components['no2'] as num).toDouble(),
      o3: (components['o3'] as num).toDouble(),
      co: (components['co'] as num).toDouble(),
      so2: (components['so2'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': [
        {
          'main': {'aqi': aqi},
          'components': {
            'co': co,
            'no2': no2,
            'o3': o3,
            'so2': so2,
            'pm2_5': pm2_5,
            'pm10': pm10,
          },
        },
      ],
    };
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
