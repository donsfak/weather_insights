// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';
import 'dart:math' as math;

class AdvancedChartsScreen extends StatefulWidget {
  final WeatherModel weatherData;

  const AdvancedChartsScreen({
    super.key,
    required this.weatherData,
  });

  @override
  State<AdvancedChartsScreen> createState() => _AdvancedChartsScreenState();
}

class _AdvancedChartsScreenState extends State<AdvancedChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showTemp = true;
  bool _showHumidity = true;
  bool _showWind = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "📊 Advanced Analytics",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMultiAxisChart(),
                    _buildRadarChart(),
                    _buildComparativeChart(),
                    _buildHeatmapChart(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicator: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: "Multi-Axis"),
                Tab(text: "Radar"),
                Tab(text: "Compare"),
                Tab(text: "Heatmap"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiAxisChart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Multi-Parameter Analysis",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip("Temperature", _showTemp, () {
                      setState(() => _showTemp = !_showTemp);
                    }),
                    _buildFilterChip("Humidity", _showHumidity, () {
                      setState(() => _showHumidity = !_showHumidity);
                    }),
                    _buildFilterChip("Wind", _showWind, () {
                      setState(() => _showWind = !_showWind);
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: _buildMultiAxisLineChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsCards(),
        ],
      ),
    );
  }

  Widget _buildMultiAxisLineChart() {
    final hourlyData = widget.weatherData.hourly.take(24).toList();
    
    if (hourlyData.isEmpty) {
      return Center(
        child: Text(
          "No data available",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }

    final tempMin = hourlyData.map((h) => h.temp).reduce(math.min);
    final tempMax = hourlyData.map((h) => h.temp).reduce(math.max);
    
    List<FlSpot> tempSpots = [];
    List<FlSpot> humiditySpots = [];
    List<FlSpot> windSpots = [];

    for (int i = 0; i < hourlyData.length; i++) {
      final h = hourlyData[i];
      tempSpots.add(FlSpot(i.toDouble(), h.temp));
      final normalizedHumidity = tempMin + (h.humidity / 100) * (tempMax - tempMin);
      humiditySpots.add(FlSpot(i.toDouble(), normalizedHumidity));
      final normalizedWind = tempMin + (h.wind / 20) * (tempMax - tempMin);
      windSpots.add(FlSpot(i.toDouble(), normalizedWind));
    }

    List<LineChartBarData> lines = [];
    
    if (_showTemp) {
      lines.add(LineChartBarData(
        spots: tempSpots,
        isCurved: true,
        color: Colors.orange,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.3),
              Colors.orange.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ));
    }

    if (_showHumidity) {
      lines.add(LineChartBarData(
        spots: humiditySpots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        dashArray: [5, 5],
      ));
    }

    if (_showWind) {
      lines.add(LineChartBarData(
        spots: windSpots,
        isCurved: true,
        color: Colors.green,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        dashArray: [2, 4],
      ));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= hourlyData.length) return const SizedBox();
                final hour = hourlyData[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "${hour.dateTime.hour}h",
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
        lineBarsData: lines,
        minY: tempMin - 2,
        maxY: tempMax + 2,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final hour = hourlyData[spot.x.toInt()];
                String label = "";
                if (spot.barIndex == 0 && _showTemp) {
                  label = "🌡️ ${hour.temp.toStringAsFixed(1)}°C";
                } else if ((spot.barIndex == 1 && _showHumidity && _showTemp) || 
                          (spot.barIndex == 0 && _showHumidity && !_showTemp)) {
                  label = "💧 ${hour.humidity}%";
                } else {
                  label = "💨 ${hour.wind.toStringAsFixed(1)} m/s";
                }
                return LineTooltipItem(
                  label,
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
    );
  }

  Widget _buildStatsCards() {
    final hourlyData = widget.weatherData.hourly.take(24).toList();
    if (hourlyData.isEmpty) return const SizedBox();
    
    final avgTemp = hourlyData.map((h) => h.temp).reduce((a, b) => a + b) / hourlyData.length;
    final avgHumidity = hourlyData.map((h) => h.humidity).reduce((a, b) => a + b) / hourlyData.length;
    final avgWind = hourlyData.map((h) => h.wind).reduce((a, b) => a + b) / hourlyData.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Avg Temp",
            "${avgTemp.toStringAsFixed(1)}°C",
            Icons.thermostat,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Avg Humidity",
            "${avgHumidity.toStringAsFixed(0)}%",
            Icons.water_drop,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Avg Wind",
            "${avgWind.toStringAsFixed(1)} m/s",
            Icons.air,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
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
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    final day = widget.weatherData.daily.first;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              children: [
                const Text(
                  "Weather Conditions Radar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      tickCount: 5,
                      ticksTextStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                      tickBorderData: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      gridBorderData: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      radarBorderData: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      radarBackgroundColor: Colors.white.withOpacity(0.05),
                      titleTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      getTitle: (index, angle) {
                        switch (index) {
                          case 0:
                            return const RadarChartTitle(text: 'Temp');
                          case 1:
                            return const RadarChartTitle(text: 'Humidity');
                          case 2:
                            return const RadarChartTitle(text: 'Wind');
                          case 3:
                            return const RadarChartTitle(text: 'Pressure');
                          case 4:
                            return const RadarChartTitle(text: 'Clouds');
                          default:
                            return const RadarChartTitle(text: '');
                        }
                      },
                      dataSets: [
                        RadarDataSet(
                          fillColor: Colors.blue.withOpacity(0.3),
                          borderColor: Colors.blue,
                          borderWidth: 3,
                          dataEntries: [
                            RadarEntry(value: (day.temp / 40) * 100),
                            RadarEntry(value: day.humidity.toDouble()),
                            RadarEntry(value: (day.wind / 20) * 100),
                            RadarEntry(value: (day.pressure / 1050) * 100),
                            RadarEntry(value: day.cloudiness.toDouble()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildRadarLegend(day),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarLegend(DailyForecast day) {
    return Column(
      children: [
        _buildLegendItem("🌡️ Temperature", "${day.temp.toStringAsFixed(1)}°C", Colors.orange),
        _buildLegendItem("💧 Humidity", "${day.humidity}%", Colors.blue),
        _buildLegendItem("💨 Wind Speed", "${day.wind.toStringAsFixed(1)} m/s", Colors.green),
        _buildLegendItem("🔽 Pressure", "${day.pressure} hPa", Colors.purple),
        _buildLegendItem("☁️ Cloudiness", "${day.cloudiness}%", Colors.grey),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeChart() {
    final hourlyData = widget.weatherData.hourly.take(24).toList();
    
    final dayData = hourlyData.where((h) => h.dateTime.hour >= 6 && h.dateTime.hour < 18).toList();
    final nightData = hourlyData.where((h) => h.dateTime.hour < 6 || h.dateTime.hour >= 18).toList();
    
    final avgDayTemp = dayData.isEmpty ? 0.0 : dayData.map((h) => h.temp).reduce((a, b) => a + b) / dayData.length;
    final avgNightTemp = nightData.isEmpty ? 0.0 : nightData.map((h) => h.temp).reduce((a, b) => a + b) / nightData.length;
    
    final avgDayHumidity = dayData.isEmpty ? 0.0 : dayData.map((h) => h.humidity).reduce((a, b) => a + b) / dayData.length;
    final avgNightHumidity = nightData.isEmpty ? 0.0 : nightData.map((h) => h.humidity).reduce((a, b) => a + b) / nightData.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Day vs Night Comparison",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Temperature', style: TextStyle(color: Colors.white, fontSize: 12));
                                case 1:
                                  return const Text('Humidity', style: TextStyle(color: Colors.white, fontSize: 12));
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
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
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: avgDayTemp * 2,
                              color: Colors.orange,
                              width: 30,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            BarChartRodData(
                              toY: avgNightTemp * 2,
                              color: Colors.blue[900],
                              width: 30,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ],
                          barsSpace: 10,
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: avgDayHumidity,
                              color: Colors.lightBlue,
                              width: 30,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            BarChartRodData(
                              toY: avgNightHumidity,
                              color: Colors.indigo,
                              width: 30,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ],
                          barsSpace: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildComparisonLegend("☀️ Day", Colors.orange),
                    const SizedBox(width: 24),
                    _buildComparisonLegend("🌙 Night", Colors.blue[900]!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapChart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Temperature Heatmap (7 Days)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: widget.weatherData.daily.length,
                    itemBuilder: (context, index) {
                      final day = widget.weatherData.daily[index];
                      final dayName = _getDayName(day.date);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                dayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getTempColor(day.minTemp),
                                      _getTempColor(day.temp),
                                      _getTempColor(day.maxTemp),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    "${day.minTemp.toStringAsFixed(0)}° → ${day.maxTemp.toStringAsFixed(0)}°",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeatmapLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Color _getTempColor(double temp) {
    if (temp < 0) return Colors.blue[900]!;
    if (temp < 10) return Colors.blue[400]!;
    if (temp < 20) return Colors.green[400]!;
    if (temp < 30) return Colors.orange[400]!;
    return Colors.red[600]!;
  }

  Widget _buildHeatmapLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Temperature Scale:",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildTempLegendItem("< 0°C", Colors.blue[900]!),
            _buildTempLegendItem("0-10°C", Colors.blue[400]!),
            _buildTempLegendItem("10-20°C", Colors.green[400]!),
            _buildTempLegendItem("20-30°C", Colors.orange[400]!),
            _buildTempLegendItem("> 30°C", Colors.red[600]!),
          ],
        ),
      ],
    );
  }

  Widget _buildTempLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white.withOpacity(0.6),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}