// ignore_for_file: deprecated_member_use, unnecessary_import

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_weather_icon.dart';
import '../widgets/sun_path_widget.dart';

class WeatherDetailsScreen extends StatefulWidget {
  final DailyForecast day;
  final List<HourlyForecast> hourlyData;

  const WeatherDetailsScreen({
    super.key,
    required this.day,
    required this.hourlyData,
  });

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = "${widget.day.date.month}/${widget.day.date.day}";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(50),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "$dateStr Details",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ]
                : [
                    const Color(0xFF4FACFE), // Bright Blue
                    const Color(0xFF00F2FE), // Cyan
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Tabs modernes
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(16),
                  padding: EdgeInsets.zero,
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: "Overview"),
                      Tab(text: "Hourly"),
                      Tab(text: "7-Day Trend"),
                    ],
                  ),
                ),
              ),
              // Contenu
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildHourlyTab(),
                    _buildTrendTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grande carte température
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.day.temp.toStringAsFixed(1)}°C",
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.day.condition,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    AnimatedWeatherIcon(
                      description: widget.day.condition,
                      size: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (widget.day.sunrise != null && widget.day.sunset != null)
                  SunPathWidget(
                    sunrise: widget.day.sunrise!,
                    sunset: widget.day.sunset!,
                    currentTime: DateTime.now(),
                  ),
                const SizedBox(height: 24),
                Container(height: 1, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTempInfo(
                      "Feels like",
                      "${widget.day.feelsLike.toStringAsFixed(1)}°C",
                    ),
                    _buildTempInfo(
                      "Min/Max",
                      "${widget.day.minTemp.toStringAsFixed(1)}° / ${widget.day.maxTemp.toStringAsFixed(1)}°C",
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Conditions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow("Weather", widget.day.condition),
                const SizedBox(height: 16),
                _buildInfoRow("Clouds", "${widget.day.cloudiness}%"),
                const SizedBox(height: 16),
                _buildInfoRow(
                  "Precipitation",
                  "${widget.day.precipitation.toStringAsFixed(2)} mm",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Wind & Pressure",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                  "Wind Speed",
                  "${widget.day.wind.toStringAsFixed(2)} m/s",
                ),
                const SizedBox(height: 16),
                _buildInfoRow("Direction", "${widget.day.windDirection}°"),
                const SizedBox(height: 16),
                _buildInfoRow("Pressure", "${widget.day.pressure} hPa"),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHourlyTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.hourlyData.length,
      itemBuilder: (context, index) {
        final hour = widget.hourlyData[index];
        final timeStr =
            "${hour.dateTime.hour.toString().padLeft(2, '0')}:${hour.dateTime.minute.toString().padLeft(2, '0')}";

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                AnimatedWeatherIcon(description: hour.condition, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hour.condition,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${hour.temp.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendTab() {
    if (widget.hourlyData.isEmpty) {
      return Center(
        child: Text(
          "No data available",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
      );
    }

    // Préparer les données pour le graphique
    final spots = widget.hourlyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temp);
    }).toList();

    final minTemp = widget.hourlyData
        .map((h) => h.temp)
        .reduce((a, b) => a < b ? a : b);
    final maxTemp = widget.hourlyData
        .map((h) => h.temp)
        .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Temperature Trend",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: widget.hourlyData.length > 8 ? 2 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= widget.hourlyData.length) {
                            return const SizedBox();
                          }
                          final hour = widget.hourlyData[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "${hour.dateTime.hour}:00",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.toInt()}°",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (widget.hourlyData.length - 1).toDouble(),
                  minY: (minTemp - 2).floorToDouble(),
                  maxY: (maxTemp + 2).ceilToDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.white.withOpacity(0.5),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final hour = widget.hourlyData[spot.x.toInt()];
                          return LineTooltipItem(
                            "${hour.temp.toStringAsFixed(1)}°C\n${hour.dateTime.hour}:00",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
