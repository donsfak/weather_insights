// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../managers/settings_manager.dart';

class ForecastChart extends StatelessWidget {
  final List<DailyForecast> dailyForecast;

  const ForecastChart({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsManager().isCelsius,
      builder: (context, isCelsius, _) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Temperature Trend",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < dailyForecast.length) {
                              final date = dailyForecast[index].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "${date.day}/${date.month}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                          interval: 1,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Max Temp Line
                      LineChartBarData(
                        spots: dailyForecast.asMap().entries.map((e) {
                          final temp = SettingsManager().convertTemp(
                            e.value.maxTemp,
                          );
                          return FlSpot(e.key.doubleValue, temp);
                        }).toList(),
                        isCurved: true,
                        color: Colors.orangeAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orangeAccent.withOpacity(0.1),
                        ),
                      ),
                      // Min Temp Line
                      LineChartBarData(
                        spots: dailyForecast.asMap().entries.map((e) {
                          final temp = SettingsManager().convertTemp(
                            e.value.minTemp,
                          );
                          return FlSpot(e.key.doubleValue, temp);
                        }).toList(),
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blueAccent.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on int {
  double get doubleValue => toDouble();
}
