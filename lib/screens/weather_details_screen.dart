import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../widgets/weather_chart.dart';

class WeatherDetailsScreen extends StatelessWidget {
  final DailyForecast day;
  final List<HourlyForecast> hourlyData;

  const WeatherDetailsScreen({
    super.key,
    required this.day,
    required this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    // Build a temperature list required by WeatherChart
    final List<double> temps = hourlyData.map((h) => h.temp).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${day.date.month}/${day.date.day} Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Hourly'),
              Tab(text: '7-Day Trend'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildHourlyTab(),
            // Pass both required temps and optional hourlyData to the chart
            WeatherChart(
              temps: temps,
              hourlyData: hourlyData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          "Temperature",
          [
            _buildDetailRow("Current", "${day.temp}°C"),
            _buildDetailRow("Feels like", "${day.feelsLike}°C"),
            _buildDetailRow("Min/Max", "${day.minTemp}°C / ${day.maxTemp}°C"),
          ],
        ),
        _buildInfoCard(
          "Conditions",
          [
            _buildDetailRow("Weather", day.condition),
            _buildDetailRow("Clouds", "${day.cloudiness}%"),
            _buildDetailRow("Precipitation", "${day.precipitation} mm"),
          ],
        ),
        _buildInfoCard(
          "Wind & Pressure",
          [
            _buildDetailRow("Wind Speed", "${day.wind} m/s"),
            _buildDetailRow("Direction", "${day.windDirection}°"),
            _buildDetailRow("Pressure", "${day.pressure} hPa"),
          ],
        ),
      ],
    );
  }

  Widget _buildHourlyTab() {
    return ListView.builder(
      itemCount: hourlyData.length,
      itemBuilder: (context, index) {
        final hour = hourlyData[index];

        // Use `dateTime.hour`. If your model uses a different field
        // (e.g. `time`), change `hour.dateTime.hour` to `hour.time`.
        final hourString = '${hour.dateTime.hour}:00';

        return ListTile(
          leading: Image.network(
            'https://openweathermap.org/img/wn/${hour.icon}@2x.png',
            width: 50,
            height: 50,
            errorBuilder: (c, e, s) => const SizedBox(width: 50, height: 50),
          ),
          title: Text(hourString),
          subtitle: Text(hour.condition),
          trailing: Text(
            '${hour.temp.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
