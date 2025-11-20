// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String description;
  final double size;
  final Color? color;

  const WeatherIcon({
    super.key,
    required this.description,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _getWeatherIcon(description),
      style: TextStyle(
        fontSize: size,
        color: color,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2.0, 2.0),
          ),
        ],
      ),
    );
  }

  String _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear')) return '☀️';
    if (desc.contains('cloud')) return '☁️';
    if (desc.contains('rain')) return '🌧️';
    if (desc.contains('thunder')) return '⛈️';
    if (desc.contains('snow')) return '❄️';
    if (desc.contains('mist') || desc.contains('fog')) return '🌫️';
    return '🌤️';
  }
}
