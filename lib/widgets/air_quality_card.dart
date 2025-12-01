import 'package:flutter/material.dart';
import '../models/air_quality_model.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';

class AirQualityCard extends StatelessWidget {
  final AirQualityModel? airQuality;

  const AirQualityCard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    if (airQuality == null) {
      return const SizedBox.shrink();
    }

    final aqiColor = _getAQIColor(airQuality!.aqi);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.air, color: aqiColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.airQuality,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: aqiColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: aqiColor, width: 2),
                    ),
                    child: Text(
                      airQuality!.aqiLevel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: aqiColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      airQuality!.healthRecommendation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPollutant(
                    'PM2.5',
                    airQuality!.pm2_5.toStringAsFixed(1),
                    'μg/m³',
                  ),
                  _buildPollutant(
                    'PM10',
                    airQuality!.pm10.toStringAsFixed(1),
                    'μg/m³',
                  ),
                  _buildPollutant(
                    'O₃',
                    airQuality!.o3.toStringAsFixed(1),
                    'μg/m³',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollutant(String name, String value, String unit) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
        ),
      ],
    );
  }

  Color _getAQIColor(int aqi) {
    switch (aqi) {
      case 1:
        return const Color(0xFF00E400); // Good - Green
      case 2:
        return const Color(0xFFF7E400); // Fair - Yellow
      case 3:
        return const Color(0xFFF85900); // Moderate - Orange
      case 4:
        return const Color(0xFFD8001D); // Poor - Red
      case 5:
        return const Color(0xFF6B49C8); // Very Poor - Purple
      default:
        return Colors.grey;
    }
  }
}
