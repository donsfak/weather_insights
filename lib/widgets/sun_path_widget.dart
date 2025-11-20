// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SunPathWidget extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime currentTime;

  const SunPathWidget({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            "Sun Path",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: SunPathPainter(
                sunrise: sunrise,
                sunset: sunset,
                currentTime: currentTime,
              ),
              size: Size.infinite,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sunrise",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "${sunrise.hour}:${sunrise.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Sunset",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "${sunset.hour}:${sunset.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SunPathPainter extends CustomPainter {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime currentTime;

  SunPathPainter({
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height) - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = ui.Gradient.linear(
        Offset(0, size.height),
        Offset(size.width, size.height),
        [
          Colors.orangeAccent.withOpacity(0.3),
          Colors.purpleAccent.withOpacity(0.3),
        ],
      );

    // Draw Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      paint,
    );

    // Calculate Sun Position
    double totalDuration = sunset.difference(sunrise).inMinutes.toDouble();
    double currentDuration = currentTime
        .difference(sunrise)
        .inMinutes
        .toDouble();
    double progress = (currentDuration / totalDuration).clamp(0.0, 1.0);

    double angle = pi + (progress * pi);
    double sunX = center.dx + radius * cos(angle);
    double sunY = center.dy + radius * sin(angle);

    // Draw Sun
    final sunPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(Offset(sunX, sunY), 8, sunPaint);

    // Draw Glow
    final glowPaint = Paint()
      ..color = Colors.amber.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(sunX, sunY), 15, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
