import 'package:flutter_test/flutter_test.dart';
import 'package:weather_insights_app/models/weather_model.dart';

void main() {
  test('WeatherModel.fromJson parses hourly and daily', () {
    final json = {
      'city': {'name': 'TestCity', 'sunrise': 1600000000, 'sunset': 1600040000},
      'list': [
        {
          'dt_txt': '2025-10-31 12:00:00',
          'dt': 1700000000,
          'main': {'temp': 15.0, 'feels_like': 14.0, 'humidity': 80, 'pressure': 1012},
          'wind': {'speed': 2.5, 'deg': 120},
          'clouds': {'all': 75},
          'visibility': 10000,
          'weather': [
            {'description': 'clear sky', 'icon': '01d'}
          ]
        }
      ]
    };

    final model = WeatherModel.fromJson(json);
    expect(model.city, 'TestCity');
    expect(model.hourly.isNotEmpty, true);
    expect(model.daily.isNotEmpty, true);
    expect(model.hourly.first.temp, 15.0);
  });
}
