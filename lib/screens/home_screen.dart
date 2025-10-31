import 'package:flutter/material.dart';
import 'dart:math' show pi, sin;
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../widgets/animated_weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final WeatherService _service = WeatherService();
  WeatherModel? _weather;
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  late AnimationController _welcomeController;
  late Animation<double> _welcomeScale;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _welcomeController.dispose();
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
        _error = data == null ? 'Could not fetch weather. Check city name or API key.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error fetching weather data. Please try again.';
      });
    }
  }

  void _showDayDetails(DailyForecast day) {
    final dateStr = "${day.date.month}/${day.date.day}";
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 1.0, end: 0.0),
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, 50 * value),
          child: Opacity(
            opacity: 1 - value,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Weather Details - $dateStr",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            "Temperature",
                            "${day.temp.toStringAsFixed(1)}°C",
                            Icons.thermostat,
                            Colors.orange,
                          ),
                          _buildDetailRow(
                            "Feels Like",
                            "${day.feelsLike.toStringAsFixed(1)}°C",
                            Icons.person,
                            Colors.blue,
                          ),
                          _buildDetailRow(
                            "Min/Max",
                            "${day.minTemp.toStringAsFixed(0)}°C / ${day.maxTemp.toStringAsFixed(0)}°C",
                            Icons.compare_arrows,
                            Colors.purple,
                          ),
                          _buildDetailRow(
                            "Precipitation",
                            "${day.precipitation.toStringAsFixed(1)} mm",
                            Icons.water_drop,
                            Colors.blue,
                          ),
                          _buildDetailRow(
                            "Humidity",
                            "${day.humidity}%",
                            Icons.opacity,
                            Colors.blueGrey,
                          ),
                          _buildDetailRow(
                            "Wind",
                            "${day.wind.toStringAsFixed(1)} m/s at ${day.windDirection}°",
                            Icons.air,
                            Colors.grey,
                          ),
                          _buildDetailRow(
                            "Pressure",
                            "${day.pressure} hPa",
                            Icons.speed,
                            Colors.teal,
                          ),
                          _buildDetailRow(
                            "Cloud Cover",
                            "${day.cloudiness}%",
                            Icons.cloud,
                            Colors.blueGrey,
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  gradient: RadialGradient(colors: [Colors.yellow[600]!, Colors.orange[300]!]),
                  boxShadow: [BoxShadow(color: const Color.fromRGBO(255, 165, 0, 0.3), blurRadius: 18)],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌤️ Weather Insights"),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                ValueListenableBuilder<TextEditingValue>(
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
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (value.text.isNotEmpty && !_loading)
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
                            _loading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: _getWeather,
                                    tooltip: 'Search',
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _weather != null
                      ? Column(
                          key: const ValueKey('forecast'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.blueAccent),
                                    const SizedBox(width: 6),
                                    Text(
                                      _weather!.city,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _weather!.daily.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final day = _weather!.daily[i];
                                  return AnimatedWeatherCard(
                                    day: day,
                                    onTap: () => _showDayDetails(day),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                if (_weather == null && _error == null)
                  ScaleTransition(
                    scale: _welcomeScale,
                    child: Column(
                      key: const ValueKey('welcome'),
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
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
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