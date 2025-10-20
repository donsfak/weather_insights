class DailyForecast {
  final DateTime date;
  final double temp;
  final double precipitation;
  final double wind;
  final String condition;
  final String icon;

  DailyForecast({
    required this.date,
    required this.temp,
    required this.precipitation,
    required this.wind,
    required this.condition,
    required this.icon,
  });
}

class WeatherModel {
  final String city;
  final List<DailyForecast> daily;

  WeatherModel({
    required this.city,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['list'];
    final Map<String, List<dynamic>> grouped = {};
    for (var entry in list) {
      final date = (entry['dt_txt'] as String).split(' ')[0];
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    final List<DailyForecast> daily = [];
    grouped.forEach((date, entries) {
      // Use noon forecast if available, else first
      final entry = entries.firstWhere(
        (e) => (e['dt_txt'] as String).contains('12:00:00'),
        orElse: () => entries[0],
      );
      final temp = (entry['main']['temp'] as num).toDouble();
      final wind = (entry['wind']['speed'] as num).toDouble();
      final weather = entry['weather'][0];
      final condition = weather['description'] as String;
      final icon = weather['icon'] as String;
      // Precipitation: rain or snow, fallback to 0
      double precipitation = 0;
      if (entry['rain'] != null && entry['rain']['3h'] != null) {
        precipitation = (entry['rain']['3h'] as num).toDouble();
      } else if (entry['snow'] != null && entry['snow']['3h'] != null) {
        precipitation = (entry['snow']['3h'] as num).toDouble();
      }
      daily.add(DailyForecast(
        date: DateTime.parse(date),
        temp: temp,
        precipitation: precipitation,
        wind: wind,
        condition: condition,
        icon: icon,
      ));
    });
    return WeatherModel(
      city: json['city']['name'],
      daily: daily,
    );
  }
}
