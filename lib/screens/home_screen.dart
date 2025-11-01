import 'package:flutter/material.dart';
import 'package:weather_insights_app/components/theme_switcher.dart';
import 'dart:math' show pi, sin;
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../widgets/animated_weather_card.dart';
import '../screens/weather_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  const HomeScreen({super.key, required this.onToggleTheme, required this.isDarkMode});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final WeatherService _service = WeatherService();
  WeatherModel? _weather;
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  late AnimationController _welcomeController;
  late AnimationController _fadeController;
  late Animation<double> _welcomeScale;
  late Animation<Offset> _slideTransition;

  @override
  void initState() {
    super.initState();

    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _welcomeScale = CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeOutBack,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideTransition = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _welcomeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _getWeather() async {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      setState(() {
        _error = 'Please enter a city.';
        _weather = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.fetchWeather(city);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _weather = data;
        _error = data == null
            ? 'Could not fetch weather. Check city name or API key.'
            : null;
      });
      _fadeController.forward(from: 0); // Trigger animation on success
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error fetching weather data. Please try again.';
      });
    }
  }

  Widget _buildWelcomeAnimation() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 3),
      tween: Tween(begin: 0, end: 2 * pi),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.yellow[600]!, Colors.orange[300]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(255, 165, 0, 0.3),
                      blurRadius: 18,
                    )
                  ],
                ),
                child: Icon(Icons.wb_sunny, color: Colors.yellow[100], size: 48),
              ),
            ),
            Positioned(
              bottom: 30 + (10 * sin(value)),
              left: 40,
              child: Opacity(
                opacity: 0.9,
                child: Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud, color: Colors.blueGrey[400], size: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        return TextField(
          controller: _controller,
          onSubmitted: (_) => _getWeather(),
          decoration: InputDecoration(
            hintText: "Enter a city (e.g., Abidjan)",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: _loading
                  ? Padding(
                      key: const ValueKey('loading'),
                      padding: const EdgeInsets.all(10),
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      key: const ValueKey('actions'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (value.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _weather = null;
                                _error = null;
                              });
                            },
                            tooltip: 'Clear',
                          ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _getWeather,
                          tooltip: 'Search',
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌤️ Weather Insights"),
        actions: [
          ThemeSwitcher(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 196, 73, 73),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                _buildSearchField(),
                const SizedBox(height: 16),

                if (_error != null)
                  FadeTransition(
                    opacity: _fadeController,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 🔮 Animated weather content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: _slideTransition,
                        child: child,
                      ),
                    );
                  },
                  child: _weather != null
                      ? Column(
                          key: const ValueKey('forecast'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 600),
                              opacity: 1,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.blueAccent),
                                      const SizedBox(width: 6),
                                      Text(
                                        _weather!.city,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _weather!.daily.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final day = _weather!.daily[i];
                                  return AnimatedWeatherCard(
                                    day: day,
                                    onTap: () => Navigator.of(context).push(
                                      PageRouteBuilder(
                                        transitionDuration:
                                            const Duration(milliseconds: 400),
                                        pageBuilder:
                                            (context, anim1, anim2) =>
                                                FadeTransition(
                                          opacity: anim1,
                                          child: WeatherDetailsScreen(
                                            day: day,
                                            hourlyData: _weather!.hourly
                                                .where((h) =>
                                                    h.dateTime.day ==
                                                        day.date.day &&
                                                    h.dateTime.month ==
                                                        day.date.month)
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : ScaleTransition(
                          key: const ValueKey('welcome'),
                          scale: _welcomeScale,
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: _buildWelcomeAnimation(),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Welcome! Enter a city to get weather insights.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
