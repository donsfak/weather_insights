import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherChart extends StatelessWidget {
  final WeatherModel weather;
  const WeatherChart({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < weather.temps.length; i++)
                FlSpot(i.toDouble(), weather.temps[i]),
            ],
            isCurved: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
