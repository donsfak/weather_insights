import 'package:flutter/material.dart';

class AnimatedWeatherIcon extends StatefulWidget {
  final String description;
  final double size;
  final Color? color;

  const AnimatedWeatherIcon({
    super.key,
    required this.description,
    this.size = 50,
    this.color,
  });

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _thunderController;
  late Animation<Offset> _cloudAnimation;
  late Animation<double> _thunderOpacity;

  @override
  void initState() {
    super.initState();

    // Cloud animation (drifting left and right)
    _cloudController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _cloudAnimation =
        Tween<Offset>(
          begin: const Offset(-0.05, 0),
          end: const Offset(0.05, 0),
        ).animate(
          CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
        );

    // Thunder animation (flashing)
    _thunderController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _thunderOpacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _thunderController, curve: Curves.bounceIn),
    );
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _thunderController.dispose();
    super.dispose();
  }

  String _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear')) return '☀️';
    if (desc.contains('cloud')) return '☁️';
    if (desc.contains('rain')) return '🌧️';
    if (desc.contains('thunder')) return '⛈️';
    if (desc.contains('snow')) return '❄️';
    if (desc.contains('mist') || desc.contains('fog')) return '🌫️';
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    final desc = widget.description.toLowerCase();
    final iconChar = _getWeatherIcon(widget.description);
    final style = TextStyle(
      fontSize: widget.size,
      color: widget.color,
      shadows: [
        Shadow(
          blurRadius: 10.0,
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(2.0, 2.0),
        ),
      ],
    );

    if (desc.contains('cloud')) {
      return SlideTransition(
        position: _cloudAnimation,
        child: Text(iconChar, style: style),
      );
    } else if (desc.contains('thunder')) {
      return FadeTransition(
        opacity: _thunderOpacity,
        child: Text(iconChar, style: style),
      );
    } else if (desc.contains('rain')) {
      // Simple bounce for rain
      return SlideTransition(
        position:
            Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: const Offset(0, 0.05),
            ).animate(
              CurvedAnimation(
                parent: _cloudController, // Reuse controller for sync
                curve: Curves.easeInOut,
              ),
            ),
        child: Text(iconChar, style: style),
      );
    }

    // Default static
    return Text(iconChar, style: style);
  }
}
