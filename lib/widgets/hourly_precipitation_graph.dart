import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';
import '../widgets/glass_container.dart';
import '../l10n/app_localizations.dart';

class HourlyPrecipitationGraph extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const HourlyPrecipitationGraph({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    // Take next 24 hours
    final next24Hours = hourlyData.take(24).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.precipitationForecast,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '24h',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100, // Percentage
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black87,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final hour = next24Hours[groupIndex];
                      final popPercent = (hour.pop * 100).toInt();
                      return BarTooltipItem(
                        '${hour.dateTime.hour}:00\n$popPercent% chance',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 3 != 0) return const SizedBox();
                        final hour = next24Hours[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${hour.dateTime.hour}h',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 35,
                      interval: 25,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: next24Hours.asMap().entries.map((entry) {
                  final popPercent = entry.value.pop * 100;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: popPercent,
                        color: _getPrecipitationColor(popPercent),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Color _getPrecipitationColor(double popPercent) {
    if (popPercent < 20) return Colors.blue.withOpacity(0.3);
    if (popPercent < 40) return Colors.blue.withOpacity(0.5);
    if (popPercent < 60) return Colors.blue.withOpacity(0.7);
    if (popPercent < 80) return Colors.blue.withOpacity(0.85);
    return Colors.blue;
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          AppLocalizations.of(context)!.uvLow,
          Colors.blue.withOpacity(0.3),
          '< 20%',
        ),
        _buildLegendItem(
          AppLocalizations.of(context)!.uvModerate,
          Colors.blue.withOpacity(0.5),
          '20-40%',
        ),
        _buildLegendItem(
          AppLocalizations.of(context)!.likely,
          Colors.blue.withOpacity(0.7),
          '40-60%',
        ),
        _buildLegendItem(
          AppLocalizations.of(context)!.veryLikely,
          Colors.blue,
          '> 60%',
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
        ),
        Text(
          range,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8),
        ),
      ],
    );
  }
}
