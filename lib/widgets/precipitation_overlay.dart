import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/precipitation_service.dart';
import 'dart:ui' as ui;

/// Apple Weather-style precipitation overlay with smooth animations
class PrecipitationOverlay extends StatefulWidget {
  final List<PrecipitationFrame> frames;
  final int currentFrameIndex;
  final double opacity;

  const PrecipitationOverlay({
    super.key,
    required this.frames,
    required this.currentFrameIndex,
    this.opacity = 0.7,
  });

  @override
  State<PrecipitationOverlay> createState() => _PrecipitationOverlayState();
}

class _PrecipitationOverlayState extends State<PrecipitationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(PrecipitationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFrameIndex != widget.currentFrameIndex) {
      // Smooth transition between frames
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty ||
        widget.currentFrameIndex >= widget.frames.length) {
      return const SizedBox.shrink();
    }

    final currentFrame = widget.frames[widget.currentFrameIndex];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: TileLayer(
        urlTemplate: PrecipitationService.getTileUrl(
          currentFrame.path,
          0, // z placeholder
          0, // x placeholder
          0, // y placeholder
        ).replaceAll('/0/0/0/', '/{z}/{x}/{y}/'),
        userAgentPackageName: 'com.example.weather_insights_app',
        tileBuilder: (context, widget, tile) {
          return ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(this.widget.opacity),
              BlendMode.modulate,
            ),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: 2.0,
                sigmaY: 2.0,
                tileMode: TileMode.decal,
              ),
              child: widget,
            ),
          );
        },
      ),
    );
  }
}

/// Animated precipitation layer manager
class AnimatedPrecipitationLayer extends StatefulWidget {
  final bool isPlaying;
  final double currentHour;
  final ValueChanged<int>? onFrameChanged;

  const AnimatedPrecipitationLayer({
    super.key,
    required this.isPlaying,
    required this.currentHour,
    this.onFrameChanged,
  });

  @override
  State<AnimatedPrecipitationLayer> createState() =>
      _AnimatedPrecipitationLayerState();
}

class _AnimatedPrecipitationLayerState
    extends State<AnimatedPrecipitationLayer> {
  List<PrecipitationFrame> _frames = [];
  int _currentFrameIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFrames();
  }

  Future<void> _loadFrames() async {
    final service = PrecipitationService();
    final frames = await service.fetchFrames();
    if (mounted) {
      setState(() {
        _frames = frames;
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedPrecipitationLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentHour != oldWidget.currentHour && _frames.isNotEmpty) {
      // Map currentHour (0-12) to frame index
      final frameIndex = (widget.currentHour / 12 * _frames.length)
          .floor()
          .clamp(0, _frames.length - 1);
      if (frameIndex != _currentFrameIndex) {
        setState(() {
          _currentFrameIndex = frameIndex;
        });
        widget.onFrameChanged?.call(frameIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return PrecipitationOverlay(
      frames: _frames,
      currentFrameIndex: _currentFrameIndex,
      opacity: 0.75,
    );
  }
}
