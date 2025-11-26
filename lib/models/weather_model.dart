class DailyForecast {
  final DateTime date;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double visibility; // meters -> we'll convert to km in UI
  final double minTemp;
  final double maxTemp;
  final DateTime? sunrise;
  final DateTime? sunset;
  final int pressure;
  final double precipitation;
  final double wind;
  final int windDirection; // degrees
  final int cloudiness; // percent
  final String condition;
  final String icon;
  final double uvi;

  DailyForecast({
    required this.date,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.visibility,
    required this.minTemp,
    required this.maxTemp,
    required this.sunrise,
    required this.sunset,
    required this.pressure,
    required this.precipitation,
    required this.wind,
    required this.windDirection,
    required this.cloudiness,
    required this.condition,
    required this.icon,
    required this.uvi,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temp: (json['temp']['day'] as num).toDouble(),
      minTemp: (json['temp']['min'] as num).toDouble(),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
      wind: (json['wind_speed'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      uvi: (json['uvi'] as num).toDouble(),
      sunrise: json['sunrise'] != 0
          ? DateTime.fromMillisecondsSinceEpoch((json['sunrise'] as int) * 1000)
          : null,
      sunset: json['sunset'] != 0
          ? DateTime.fromMillisecondsSinceEpoch((json['sunset'] as int) * 1000)
          : null,
      pressure: (json['pressure'] as num).toInt(),
      precipitation: (json['rain']?['3h'] as num?)?.toDouble() ?? 0.0,
      cloudiness: (json['clouds']?['all'] as num?)?.toInt() ?? 0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feels_like'] as num).toDouble(),
      windDirection: (json['wind_deg'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': date.millisecondsSinceEpoch ~/ 1000,
      'temp': {'day': temp, 'min': minTemp, 'max': maxTemp},
      'weather': [
        {'main': condition, 'icon': icon},
      ],
      'wind_speed': wind,
      'humidity': humidity,
      'uvi': uvi,
      'sunrise': sunrise != null ? sunrise!.millisecondsSinceEpoch ~/ 1000 : 0,
      'sunset': sunset != null ? sunset!.millisecondsSinceEpoch ~/ 1000 : 0,
      'pressure': pressure,
      'rain': {'3h': precipitation},
      'clouds': {'all': cloudiness},
      'visibility': visibility,
      'feels_like': feelsLike,
      'wind_deg': windDirection,
    };
  }
}

class WeatherModel {
  final String city;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;
  final List<WeatherAlert> alerts;
  final double lat;
  final double lon;

  WeatherModel({
    required this.city,
    required this.daily,
    required this.hourly,
    this.alerts = const [],
    required this.lat,
    required this.lon,
  });

  factory WeatherModel.fromJson(
    Map<String, dynamic> json, {
    double? uvIndexOverride,
  }) {
    final List<dynamic> list = json['list'];
    final Map<String, List<dynamic>> grouped = {};
    for (var entry in list) {
      final date = (entry['dt_txt'] as String).split(' ')[0];
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    final List<DailyForecast> daily = [];
    // city sunrise/sunset are in json['city']['sunrise'] (unix), json['city']['sunset'] (unix)
    final int? citySunrise = json['city']?['sunrise'];
    final int? citySunset = json['city']?['sunset'];

    grouped.forEach((date, entries) {
      // compute aggregates across entries for the day
      double sumTemp = 0;
      double minTemp = double.infinity;
      double maxTemp = -double.infinity;
      double sumFeels = 0;
      int sumHumidity = 0;
      double sumVisibility = 0;
      int sumPressure = 0;
      double sumWind = 0;
      int sumWindDir = 0;
      int sumCloud = 0;
      double sumPrecip = 0;
      double sumUvi = 0; // Added for UVI
      int count = entries.length;

      for (var e in entries) {
        final main = e['main'];
        final tempVal = (main['temp'] as num).toDouble();
        sumTemp += tempVal;
        minTemp = tempVal < minTemp ? tempVal : minTemp;
        maxTemp = tempVal > maxTemp ? tempVal : maxTemp;
        sumFeels += (main['feels_like'] as num?)?.toDouble() ?? tempVal;
        sumHumidity += (main['humidity'] as num).toInt();
        sumPressure += (main['pressure'] as num).toInt();

        sumVisibility += (e['visibility'] as num?)?.toDouble() ?? 0;
        final windVal = (e['wind']['speed'] as num).toDouble();
        sumWind += windVal;
        sumWindDir += (e['wind']['deg'] as num).toInt();
        sumCloud += (e['clouds']?['all'] as num?)?.toInt() ?? 0;
        sumUvi += (e['uvi'] as num?)?.toDouble() ?? 0.0; // Added for UVI

        // precipitation
        if (e['rain'] != null && e['rain']['3h'] != null) {
          sumPrecip += (e['rain']['3h'] as num).toDouble();
        }
        if (e['snow'] != null && e['snow']['3h'] != null) {
          sumPrecip += (e['snow']['3h'] as num).toDouble();
        }
      }

      final avgTemp = sumTemp / count;
      final avgFeels = sumFeels / count;
      final avgHumidity = (sumHumidity / count).round();
      final avgVisibility = sumVisibility / count;
      final avgPressure = (sumPressure / count) ~/ count;
      final avgWind = sumWind / count;
      final avgWindDir = (sumWindDir / count).round();
      final avgCloud = (sumCloud / count).round();
      final avgUvi =
          uvIndexOverride ?? (sumUvi / count); // Use override if available

      // choose representative weather entry (noon or first)
      final rep = entries.firstWhere(
        (e) => (e['dt_txt'] as String).contains('12:00:00'),
        orElse: () => entries[0],
      );
      final weather = rep['weather'][0];
      final condition = weather['description'] as String;
      final icon = weather['icon'] as String;

      daily.add(
        DailyForecast(
          date: DateTime.parse(date),
          temp: avgTemp,
          feelsLike: avgFeels,
          humidity: avgHumidity,
          visibility: avgVisibility,
          minTemp: minTemp == double.infinity ? avgTemp : minTemp,
          maxTemp: maxTemp == -double.infinity ? avgTemp : maxTemp,
          sunrise: citySunrise != null
              ? DateTime.fromMillisecondsSinceEpoch(citySunrise * 1000)
              : null,
          sunset: citySunset != null
              ? DateTime.fromMillisecondsSinceEpoch(citySunset * 1000)
              : null,
          pressure: avgPressure,
          precipitation: sumPrecip,
          wind: avgWind,
          windDirection: avgWindDir,
          cloudiness: avgCloud,
          condition: condition,
          icon: icon,
          uvi: avgUvi, // Added for UVI
        ),
      );
    });
    // Build hourly list (flatten entries -> HourlyForecast)
    final List<HourlyForecast> hourly = list.map((e) {
      final dtTxt = e['dt_txt'] as String?;
      final dt = dtTxt != null
          ? DateTime.parse(dtTxt)
          : DateTime.fromMillisecondsSinceEpoch((e['dt'] as int) * 1000);
      final main = e['main'];
      final weather = (e['weather'] as List).isNotEmpty
          ? e['weather'][0]
          : null;
      return HourlyForecast(
        dateTime: dt,
        temp: (main['temp'] as num).toDouble(),
        feelsLike:
            (main['feels_like'] as num?)?.toDouble() ??
            (main['temp'] as num).toDouble(),
        humidity: (main['humidity'] as num?)?.toInt() ?? 0,
        wind: (e['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
        precipitation:
            ((e['rain']?['3h'] as num?)?.toDouble() ?? 0.0) +
            ((e['snow']?['3h'] as num?)?.toDouble() ?? 0.0),
        condition: weather != null ? (weather['description'] as String) : '',
        icon: weather != null ? (weather['icon'] as String) : '',
      );
    }).toList();

    final List<WeatherAlert> alerts = [];
    if (json['alerts'] != null) {
      alerts.addAll(
        (json['alerts'] as List).map((e) => WeatherAlert.fromJson(e)).toList(),
      );
    }

    return WeatherModel(
      city: json['city']['name'],
      daily: daily,
      hourly: hourly,
      alerts: alerts,
      lat: (json['city']['coord']['lat'] as num).toDouble(),
      lon: (json['city']['coord']['lon'] as num).toDouble(),
    );
  }

  factory WeatherModel.fromCacheJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city'],
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      daily: (json['daily'] as List)
          .map((e) => DailyForecast.fromJson(e))
          .toList(),
      hourly: (json['hourly'] as List)
          .map((e) => HourlyForecast.fromJson(e))
          .toList(),
      alerts: (json['alerts'] as List)
          .map((e) => WeatherAlert.fromCacheJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'lat': lat,
      'lon': lon,
      'daily': daily.map((e) => e.toJson()).toList(),
      'hourly': hourly.map((e) => e.toJson()).toList(),
      'alerts': alerts.map((e) => e.toJson()).toList(),
    };
  }
}

class HourlyForecast {
  final DateTime dateTime;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double wind;
  final double precipitation;
  final String condition;
  final String icon;

  HourlyForecast({
    required this.dateTime,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.precipitation,
    required this.condition,
    required this.icon,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dateTime: DateTime.parse(json['dateTime']),
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      wind: (json['wind'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      condition: json['condition'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'temp': temp,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'wind': wind,
      'precipitation': precipitation,
      'condition': condition,
      'icon': icon,
    };
  }
}

class WeatherAlert {
  final String sender;
  final String event;
  final DateTime start;
  final DateTime end;
  final String description;

  WeatherAlert({
    required this.sender,
    required this.event,
    required this.start,
    required this.end,
    required this.description,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      sender: json['sender_name'] ?? 'Unknown Sender',
      event: json['event'] ?? 'Weather Alert',
      start: DateTime.fromMillisecondsSinceEpoch((json['start'] as int) * 1000),
      end: DateTime.fromMillisecondsSinceEpoch((json['end'] as int) * 1000),
      description: json['description'] ?? '',
    );
  }

  factory WeatherAlert.fromCacheJson(Map<String, dynamic> json) {
    return WeatherAlert(
      sender: json['sender'],
      event: json['event'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'event': event,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'description': description,
    };
  }
}
