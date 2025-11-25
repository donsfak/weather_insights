import 'package:flutter/material.dart';
import 'dart:ui';

class PrecipitationLegend extends StatelessWidget {
  const PrecipitationLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Precipitation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildColorBox(const Color(0xFF00A8E0), 'Light'),
                  const SizedBox(width: 4),
                  _buildColorBox(const Color(0xFF0078D4), 'Mod'),
                  const SizedBox(width: 4),
                  _buildColorBox(const Color(0xFF0050A0), 'Heavy'),
                  const SizedBox(width: 4),
                  _buildColorBox(const Color(0xFFFFD700), 'Storm'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8)),
      ],
    );
  }
}
