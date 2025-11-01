// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherChart extends StatelessWidget {
  final List<double> temps;
  final List<HourlyForecast>? hourlyData;

  const WeatherChart({
    super.key,
    required this.temps,
    this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    // Safety: if temps is empty, show placeholder
    if (temps.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final minY = temps.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = temps.reduce((a, b) => a > b ? a : b) + 2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Temperature Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Use Flexible so chart fits inside column with other widgets
          Flexible(
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (hourlyData != null && hourlyData!.isNotEmpty) {
                          // clamp index to valid range
                          final clamped = index.clamp(0, hourlyData!.length - 1);
                          final hour = hourlyData![clamped];
                          // Use dateTime.hour; if your model uses another property, replace it
                          final hourLabel = '${hour.dateTime.hour}:00';
                          return Text(hourLabel, style: const TextStyle(fontSize: 10));
                        }
                        // fallback: show index
                        return Text(index.toString(), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}°', style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 4,
                  verticalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < temps.length; i++) FlSpot(i.toDouble(), temps[i]),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: minY,
                maxY: maxY,
                clipData: const FlClipData.all(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
