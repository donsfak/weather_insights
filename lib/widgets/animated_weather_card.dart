import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather_model.dart';

class AnimatedWeatherCard extends StatefulWidget {
  final DailyForecast day;
  final VoidCallback onTap;

  const AnimatedWeatherCard({
    super.key,
    required this.day,
    required this.onTap,
  });

  @override
  State<AnimatedWeatherCard> createState() => _AnimatedWeatherCardState();
}

class _AnimatedWeatherCardState extends State<AnimatedWeatherCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  LinearGradient _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF536976), Color(0xFF292E49)],
        );
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFEE59), Color(0xFFF93759)],
        );
      case 'clouds':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF283E51), Color(0xFF4B5563)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = "${widget.day.date.month}/${widget.day.date.day}";
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) => Transform.scale(
        scale: _scaleController.value,
        child: Hero(
          tag: 'weather_card_${widget.day.date.millisecondsSinceEpoch}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000), // 10% opacity black
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: (_) {
                  _scaleController.reverse();
                },
                onTapUp: (_) {
                  _scaleController.forward();
                  widget.onTap();
                },
                onTapCancel: () {
                  _scaleController.forward();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: _getWeatherGradient(widget.day.condition),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CachedNetworkImage(
                        imageUrl:
                            'https://openweathermap.org/img/wn/${widget.day.icon}@2x.png',
                        width: 60,
                        height: 60,
                        placeholder: (context, url) => const SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.cloud,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.day.temp.toStringAsFixed(1)}°C",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.day.condition,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xE6FFFFFF), // 90% opacity white
                        ),
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
