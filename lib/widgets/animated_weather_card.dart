import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class AnimatedWeatherCard extends StatelessWidget {
  final DailyForecast day;
  final VoidCallback onTap;

  const AnimatedWeatherCard({
    super.key,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = "${day.date.month}/${day.date.day}";
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.scale(
        scale: 0.95 + (0.05 * value),
        child: Opacity(
          opacity: value,
          child: Hero(
            tag: 'weather_card_${day.date.millisecondsSinceEpoch}',
            child: Card(
              elevation: 2 * value,
              // ignore: deprecated_member_use
              shadowColor: Colors.blue.withOpacity(0.3),
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                // ignore: deprecated_member_use
                splashColor: Colors.blue.withOpacity(0.1),
                // ignore: deprecated_member_use
                highlightColor: Colors.blue.withOpacity(0.05),
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Image.network(
                        'https://openweathermap.org/img/wn/${day.icon}@2x.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.cloud, size: 36),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${day.temp.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.condition,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}