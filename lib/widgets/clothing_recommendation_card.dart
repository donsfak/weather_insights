import 'package:flutter/material.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';

class ClothingRecommendationCard extends StatelessWidget {
  final double temperature;
  final String condition;
  final double wind;
  final int humidity;

  const ClothingRecommendationCard({
    super.key,
    required this.temperature,
    required this.condition,
    required this.wind,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations(context);

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
                  const Icon(Icons.checkroom, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.whatToWear,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: recommendations
                    .map(
                      (rec) =>
                          _buildRecommendationChip(rec['icon']!, rec['label']!),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getRecommendations(BuildContext context) {
    final recommendations = <Map<String, String>>[];

    // Temperature-based
    if (temperature < 0) {
      recommendations.add({
        'icon': '🧥',
        'label': AppLocalizations.of(context)!.heavyCoat,
      });
      recommendations.add({
        'icon': '🧤',
        'label': AppLocalizations.of(context)!.gloves,
      });
      recommendations.add({
        'icon': '🧣',
        'label': AppLocalizations.of(context)!.scarf,
      });
    } else if (temperature < 10) {
      recommendations.add({
        'icon': '🧥',
        'label': AppLocalizations.of(context)!.jacket,
      });
      recommendations.add({
        'icon': '🧣',
        'label': AppLocalizations.of(context)!.scarf,
      });
    } else if (temperature < 20) {
      recommendations.add({
        'icon': '👕',
        'label': AppLocalizations.of(context)!.longSleeves,
      });
    } else if (temperature < 25) {
      recommendations.add({
        'icon': '👕',
        'label': AppLocalizations.of(context)!.lightClothes,
      });
    } else {
      recommendations.add({
        'icon': '👕',
        'label': AppLocalizations.of(context)!.tShirt,
      });
      recommendations.add({
        'icon': '🧢',
        'label': AppLocalizations.of(context)!.hat,
      });
    }

    // Condition-based
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower.contains('drizzle')) {
      recommendations.add({
        'icon': '☂️',
        'label': AppLocalizations.of(context)!.umbrella,
      });
    }
    if (lower.contains('snow')) {
      recommendations.add({
        'icon': '👢',
        'label': AppLocalizations.of(context)!.boots,
      });
    }
    if (lower.contains('sun') || lower.contains('clear')) {
      recommendations.add({
        'icon': '🕶️',
        'label': AppLocalizations.of(context)!.sunglasses,
      });
    }

    // Wind-based
    if (wind > 10) {
      recommendations.add({
        'icon': '🧥',
        'label': AppLocalizations.of(context)!.windbreaker,
      });
    }

    return recommendations;
  }
}
