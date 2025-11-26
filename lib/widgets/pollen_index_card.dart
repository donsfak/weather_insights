import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class PollenIndexCard extends StatelessWidget {
  final int pollenIndex; // 1-5 scale
  final String dominantPollen;

  const PollenIndexCard({
    super.key,
    required this.pollenIndex,
    required this.dominantPollen,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getPollenColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.grass, color: _getPollenColor(), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pollen & Allergy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPollenLevel(),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getPollenColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getPollenColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pollenIndex.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getPollenColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dominant: $dominantPollen',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getRecommendation(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _getPollenLevel() {
    switch (pollenIndex) {
      case 1:
        return 'Low';
      case 2:
        return 'Moderate';
      case 3:
        return 'High';
      case 4:
        return 'Very High';
      case 5:
        return 'Extreme';
      default:
        return 'Unknown';
    }
  }

  Color _getPollenColor() {
    switch (pollenIndex) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRecommendation() {
    switch (pollenIndex) {
      case 1:
        return 'Great day to be outdoors! Pollen levels are low.';
      case 2:
        return 'Moderate pollen levels. Most people won\'t be affected.';
      case 3:
        return 'High pollen count. Consider taking allergy medication if sensitive.';
      case 4:
        return 'Very high pollen. Limit outdoor activities if you have allergies.';
      case 5:
        return 'Extreme pollen levels! Stay indoors if possible. Take precautions.';
      default:
        return 'Pollen data unavailable.';
    }
  }
}
