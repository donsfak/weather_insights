// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class MapTimelineControl extends StatelessWidget {
  final double currentHour;
  final bool isPlaying;
  final ValueChanged<double> onChanged;
  final VoidCallback onPlayPause;

  const MapTimelineControl({
    super.key,
    required this.currentHour,
    required this.isPlaying,
    required this.onChanged,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentTime = now.add(Duration(minutes: (currentHour * 60).round()));
    final timeStr = DateFormat('HH:mm').format(currentTime);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onPlayPause,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Forecast for next 12 hours",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEEE d MMMM yyyy').format(now),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      timeStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Slider Row
              SizedBox(
                height: 30,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                      elevation: 2,
                    ),
                    overlayColor: Colors.white.withOpacity(0.1),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: currentHour,
                    min: 0,
                    max: 12,
                    onChanged: onChanged,
                  ),
                ),
              ),

              // Time Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeLabel("Now"),
                    _buildTimeLabel(
                      DateFormat(
                        'HH:mm',
                      ).format(now.add(const Duration(hours: 3))),
                    ),
                    _buildTimeLabel(
                      DateFormat(
                        'HH:mm',
                      ).format(now.add(const Duration(hours: 6))),
                    ),
                    _buildTimeLabel(
                      DateFormat(
                        'HH:mm',
                      ).format(now.add(const Duration(hours: 9))),
                    ),
                    _buildTimeLabel(
                      DateFormat(
                        'HH:mm',
                      ).format(now.add(const Duration(hours: 12))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
