import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class UVIndexCard extends StatelessWidget {
  final double uvIndex;

  const UVIndexCard({super.key, required this.uvIndex});

  @override
  Widget build(BuildContext context) {
    final uvLevel = _getUVLevel(context, uvIndex);
    final uvColor = _getUVColor(uvIndex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [uvColor.withOpacity(0.3), uvColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: uvColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: uvColor, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.uvIndex,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                uvIndex.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: uvColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uvLevel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: uvColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getUVRecommendation(context, uvIndex),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildUVScale(),
        ],
      ),
    );
  }

  Widget _buildUVScale() {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00E400), // Low
                Color(0xFFF7E400), // Moderate
                Color(0xFFF85900), // High
                Color(0xFFD8001D), // Very High
                Color(0xFF6B49C8), // Extreme
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontSize: 10, color: Colors.white60)),
            Text('2', style: TextStyle(fontSize: 10, color: Colors.white60)),
            Text('5', style: TextStyle(fontSize: 10, color: Colors.white60)),
            Text('7', style: TextStyle(fontSize: 10, color: Colors.white60)),
            Text('10', style: TextStyle(fontSize: 10, color: Colors.white60)),
            Text('11+', style: TextStyle(fontSize: 10, color: Colors.white60)),
          ],
        ),
      ],
    );
  }

  String _getUVLevel(BuildContext context, double uv) {
    if (uv < 3) return AppLocalizations.of(context)!.uvLow;
    if (uv < 6) return AppLocalizations.of(context)!.uvModerate;
    if (uv < 8) return AppLocalizations.of(context)!.uvHigh;
    if (uv < 11) return AppLocalizations.of(context)!.uvVeryHigh;
    return AppLocalizations.of(context)!.uvExtreme;
  }

  Color _getUVColor(double uv) {
    if (uv < 3) return const Color(0xFF00E400);
    if (uv < 6) return const Color(0xFFF7E400);
    if (uv < 8) return const Color(0xFFF85900);
    if (uv < 11) return const Color(0xFFD8001D);
    return const Color(0xFF6B49C8);
  }

  String _getUVRecommendation(BuildContext context, double uv) {
    if (uv < 3) return AppLocalizations.of(context)!.uvRecLow;
    if (uv < 6) return AppLocalizations.of(context)!.uvRecModerate;
    if (uv < 8) return AppLocalizations.of(context)!.uvRecHigh;
    if (uv < 11) return AppLocalizations.of(context)!.uvRecVeryHigh;
    return AppLocalizations.of(context)!.uvRecExtreme;
  }
}
