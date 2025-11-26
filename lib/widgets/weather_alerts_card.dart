import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../widgets/glass_container.dart';
import 'package:flutter/services.dart';

class WeatherAlertsCard extends StatelessWidget {
  final List<WeatherAlert> alerts;

  const WeatherAlertsCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alert) => _buildAlertCard(alert)).toList(),
    );
  }

  Widget _buildAlertCard(WeatherAlert alert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        color: _getAlertColor(alert.event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getAlertIcon(alert.event), color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.event,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(alert.start)} - ${_formatTime(alert.end)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Source: ${alert.sender}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(String event) {
    final eventLower = event.toLowerCase();
    if (eventLower.contains('severe') || eventLower.contains('warning')) {
      return Colors.red;
    } else if (eventLower.contains('watch') ||
        eventLower.contains('advisory')) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  IconData _getAlertIcon(String event) {
    final eventLower = event.toLowerCase();
    if (eventLower.contains('thunder') || eventLower.contains('storm')) {
      return Icons.flash_on;
    } else if (eventLower.contains('rain') || eventLower.contains('flood')) {
      return Icons.water_drop;
    } else if (eventLower.contains('snow') || eventLower.contains('ice')) {
      return Icons.ac_unit;
    } else if (eventLower.contains('wind')) {
      return Icons.air;
    } else if (eventLower.contains('heat')) {
      return Icons.wb_sunny;
    } else if (eventLower.contains('fog')) {
      return Icons.cloud;
    }
    return Icons.warning;
  }

  String _formatTime(DateTime time) {
    return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
