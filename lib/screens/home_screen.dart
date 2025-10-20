import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _service = WeatherService();
  WeatherModel? _weather;
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  void _getWeather() async {
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

    final data = await _service.fetchWeather(city);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _weather = data;
      _error = data == null ? 'Could not fetch weather. Check city name or API key.' : null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            // add viewInsets bottom so the scrollable content gains enough space
            // when the keyboard appears (prevents bottom overflowed by X pixels)
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
                                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
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
                            height: 220,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _weather!.daily.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final day = _weather!.daily[i];
                                final dateStr = "${day.date.month}/${day.date.day}";
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  child: Card(
                                    color: Colors.blue[50],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: Container(
                                      width: 140,
                                      padding: const EdgeInsets.all(14),
                                      // allow the card's vertical content to scroll if it doesn't fit
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Image.network(
                                              'https://openweathermap.org/img/wn/${day.icon}@2x.png',
                                              width: 54,
                                              height: 54,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, size: 40),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              day.condition,
                                              style: const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${day.temp.toStringAsFixed(1)}°C",
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                            ),
                                            const SizedBox(height: 6),
                                            Text("Feels like ${day.feelsLike.toStringAsFixed(1)}°C", style: const TextStyle(fontSize: 12)),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.thermostat, size: 14, color: Colors.orange),
                                                const SizedBox(width: 4),
                                                Text("Min ${day.minTemp.toStringAsFixed(0)}° / Max ${day.maxTemp.toStringAsFixed(0)}°", style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                                                const SizedBox(width: 4),
                                                Text("${day.precipitation.toStringAsFixed(1)} mm", style: const TextStyle(fontSize: 12)),
                                                const SizedBox(width: 8),
                                                const Icon(Icons.opacity, size: 16, color: Colors.blueGrey),
                                                const SizedBox(width: 4),
                                                Text("${day.humidity}%", style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.air, size: 16, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text("${day.wind.toStringAsFixed(1)} m/s", style: const TextStyle(fontSize: 12)),
                                                const SizedBox(width: 8),
                                                Text("${day.windDirection}°", style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.speed, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text("${day.pressure} hPa", style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text("Clouds: ${day.cloudiness}%", style: const TextStyle(fontSize: 12)),
                                          ],
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
                    : const SizedBox.shrink(),
              ),
              if (_weather == null && _error == null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    key: const ValueKey('welcome'),
                    children: [
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: const _AnimatedWeatherWelcome(),
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
    );
  }
}

class _AnimatedWeatherWelcome extends StatefulWidget {
  const _AnimatedWeatherWelcome();

  @override
  State<_AnimatedWeatherWelcome> createState() => _AnimatedWeatherWelcomeState();
}

class _AnimatedWeatherWelcomeState extends State<_AnimatedWeatherWelcome> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _cloudOffset;
  late final Animation<double> _sunRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _cloudOffset = Tween<double>(begin: 0, end: 20).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _sunRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _sunRotation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.yellow[600]!, Colors.orange[300]!]),
                  boxShadow: [BoxShadow(color: Color.fromRGBO(255, 165, 0, 0.3), blurRadius: 18)],
                ),
                child: Icon(Icons.wb_sunny, color: Colors.yellow[100], size: 48),
              ),
            ),
            Positioned(
              bottom: 30 + _cloudOffset.value,
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
}
