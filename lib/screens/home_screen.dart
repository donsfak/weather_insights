// ignore_for_file: deprecated_member_use, unnecessary_import

import 'package:flutter/material.dart';
import 'package:weather_insights_app/components/theme_switcher.dart';
import 'package:weather_insights_app/widgets/glass_container.dart';
import '../widgets/animated_weather_icon.dart';
import 'dart:math' show sin;
import '../services/weather_service.dart';
import '../services/widget_service.dart';
import '../models/weather_model.dart';
import '../screens/advanced_charts_screen.dart';
import 'dart:ui';
import '../managers/settings_manager.dart';
import '../widgets/forecast_chart.dart';
import '../widgets/alert_banner.dart';
import '../screens/map_screen.dart';
import 'package:latlong2/latlong.dart';
import '../services/air_quality_service.dart';
import '../models/air_quality_model.dart';
import '../widgets/clothing_recommendation_card.dart';
import '../widgets/air_quality_card.dart';
import '../widgets/uv_index_card.dart';
import '../widgets/error_state_widget.dart';
import '../utils/exceptions.dart';
import 'package:flutter/services.dart';
import '../widgets/hourly_precipitation_graph.dart';

import '../services/connectivity_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final WeatherService _service = WeatherService();
  final AirQualityService _aqiService = AirQualityService();
  final ConnectivityService _connectivityService = ConnectivityService();
  WeatherModel? _weather;
  AirQualityModel? _airQuality;
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  String? _error;
  bool _isOffline = false;

  late AnimationController _welcomeController;
  late AnimationController _fadeController;
  late Animation<double> _welcomeScale;
  late Animation<Offset> _slideTransition;

  @override
  void initState() {
    super.initState();

    _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
        if (isConnected && _weather == null) {
          _getWeather();
        }
      }
    });
    _connectivityService.initialize();

    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _welcomeScale = CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.elasticOut,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideTransition =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    _controller.dispose();
    _welcomeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _getWeather() async {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      setState(() {
        _error = 'Please enter a city name';
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
      if (data != null) {
        _fadeController.forward(from: 0);
        // Update widget with new weather data
        await WidgetService.updateWidget(data);

        // Fetch Air Quality
        if (data.lat != 0 && data.lon != 0) {
          final aqi = await _aqiService.fetchAirQuality(data.lat, data.lon);
          if (mounted) {
            setState(() {
              _airQuality = aqi;
            });
          }
        }
      }
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error fetching weather data. Please try again.';
      });
    }
  }

  Widget _buildModernWelcome() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 4),
      tween: Tween(begin: 0, end: 2 * pi),
      builder: (context, value, child) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Rotating sun
                Transform.rotate(
                  angle: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.amber[300]!, Colors.orange[400]!],
                      ),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                // Floating cloud
                Positioned(
                  bottom: 20 + (12 * sin(value)),
                  left: 30,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: 0.85,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(20),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.blueGrey[300],
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              "Weather Insights",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Enter a city to discover the weather",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassSearchField() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        return GlassContainer(
          borderRadius: BorderRadius.circular(20),
          child: TextField(
            controller: _controller,
            onSubmitted: (_) => _getWeather(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Search city (e.g., Abidjan)",
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _loading
                    ? const Padding(
                        key: ValueKey('loading'),
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('actions'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (value.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _controller.clear();
                                setState(() {
                                  _weather = null;
                                  _error = null;
                                });
                              },
                              tooltip: 'Clear',
                            ),
                          if (_weather != null)
                            ValueListenableBuilder<List<String>>(
                              valueListenable: SettingsManager().savedLocations,
                              builder: (context, locations, child) {
                                final isSaved = locations.contains(
                                  _weather!.city,
                                );
                                return IconButton(
                                  icon: Icon(
                                    isSaved ? Icons.star : Icons.star_border,
                                    color: isSaved
                                        ? Colors.amber
                                        : Colors.white,
                                  ),
                                  onPressed: () {
                                    if (isSaved) {
                                      SettingsManager().removeLocation(
                                        _weather!.city,
                                      );
                                    } else {
                                      SettingsManager().addLocation(
                                        _weather!.city,
                                      );
                                    }
                                  },
                                  tooltip: isSaved
                                      ? 'Remove from favorites'
                                      : 'Add to favorites',
                                );
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _getWeather();
                            },
                            tooltip: 'Search',
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsManager().isCelsius,
      builder: (context, isCelsius, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          drawer: _buildDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              "🌤️ Weather Insights",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.map_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        initialLocation: _weather != null
                            ? LatLng(_weather!.lat, _weather!.lon)
                            : null,
                      ),
                    ),
                  );
                },
                tooltip: 'View Map',
              ),
              ThemeSwitcher(onToggle: widget.onToggleTheme),
              const SizedBox(width: 8),
            ],
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.isDarkMode
                    ? [
                        const Color(0xFF0F2027),
                        const Color(0xFF203A43),
                        const Color(0xFF2C5364),
                      ]
                    : [
                        const Color(0xFF4FACFE), // Bright Blue
                        const Color(0xFF00F2FE), // Cyan
                      ],
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _getWeather();
                },
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                        if (_isOffline)
                          Container(
                            width: double.infinity,
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: const Text(
                              'Offline Mode',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        _buildGlassSearchField(),
                        const SizedBox(height: 20),

                        // Error message
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ErrorStateWidget(
                              message: _error!,
                              onRetry: _getWeather,
                              isOffline: _error!.contains('connection'),
                            ),
                          ),

                        // Main content
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Main Content
                                    if (_weather != null &&
                                        _weather!.alerts.isNotEmpty)
                                      ..._weather!.alerts.map(
                                        (alert) => AlertBanner(
                                          alert: alert,
                                          onDismiss: () {
                                            setState(() {
                                              _weather!.alerts.remove(alert);
                                            });
                                          },
                                        ),
                                      ),
                                    // Main Weather Display
                                    Column(
                                      children: [
                                        Text(
                                          _weather!.city,
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            "Updating",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        AnimatedWeatherIcon(
                                          description:
                                              _weather!.daily.first.condition,
                                          size: 120,
                                        ),
                                        const SizedBox(height: 10),
                                        ValueListenableBuilder<bool>(
                                          valueListenable:
                                              SettingsManager().isCelsius,
                                          builder: (context, isCelsius, _) {
                                            final temp = SettingsManager()
                                                .convertTemp(
                                                  _weather!.daily.first.temp,
                                                );
                                            return Text(
                                              "${temp.toStringAsFixed(0)}${SettingsManager().tempUnit}",
                                              style: const TextStyle(
                                                fontSize: 80,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                height: 1.0,
                                              ),
                                            );
                                          },
                                        ),
                                        Text(
                                          _weather!.daily.first.condition
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getDayName(DateTime.now()),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),

                                    // Weather Stats Row
                                    GlassContainer(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 01,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ValueListenableBuilder<bool>(
                                            valueListenable:
                                                SettingsManager().isCelsius,
                                            builder: (context, isCelsius, _) {
                                              final speed = SettingsManager()
                                                  .convertSpeed(
                                                    _weather!.daily.first.wind,
                                                  );
                                              return _buildStatItem(
                                                Icons.air,
                                                "${speed.toStringAsFixed(1)} ${SettingsManager().speedUnit}",
                                                "Wind",
                                              );
                                            },
                                          ),
                                          _buildStatItem(
                                            Icons.water_drop,
                                            "${_weather!.daily.first.humidity}%",
                                            "Humidity",
                                          ),
                                          _buildStatItem(
                                            Icons.umbrella,
                                            "87%",
                                            "Chance of rain",
                                          ), // Mock data for now
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Clothing Recommendation
                                    if (_weather != null)
                                      ClothingRecommendationCard(
                                        temperature: _weather!.daily.first.temp,
                                        condition:
                                            _weather!.daily.first.condition,
                                        wind: _weather!.daily.first.wind,
                                        humidity:
                                            _weather!.daily.first.humidity,
                                      ),

                                    const SizedBox(height: 24),

                                    // Air Quality
                                    if (_airQuality != null)
                                      AirQualityCard(airQuality: _airQuality),

                                    const SizedBox(height: 24),

                                    // UV Index
                                    if (_weather != null)
                                      UVIndexCard(
                                        uvIndex: _weather!.daily.first.uvi,
                                      ),

                                    const SizedBox(height: 24),

                                    // Hourly Precipitation Graph
                                    if (_weather != null &&
                                        _weather!.hourly.isNotEmpty)
                                      HourlyPrecipitationGraph(
                                        hourlyData: _weather!.hourly,
                                      ),

                                    const SizedBox(height: 24),
                                    // 7-Day Forecast Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Hourly Forecast",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AdvancedChartsScreen(
                                                      weatherData: _weather!,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                "7 days",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.chevron_right,
                                                color: Colors.white70,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Daily Forecast List
                                    SizedBox(
                                      height: 160,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _weather!.hourly.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, i) {
                                          final hour = _weather!.hourly[i];
                                          return _buildHourlyWeatherCard(hour);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ForecastChart(
                                      dailyForecast: _weather!.daily,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                )
                              : ScaleTransition(
                                  key: const ValueKey('welcome'),
                                  scale: _welcomeScale,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: _buildModernWelcome(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: widget.isDarkMode
            ? const Color(0xFF0F2027)
            : const Color(0xFF4FACFE),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Settings & Favorites",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white30),
              ListTile(
                title: const Text(
                  "Temperature Unit",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("°F", style: TextStyle(color: Colors.white70)),
                    Switch(
                      value: SettingsManager().isCelsius.value,
                      onChanged: (val) => SettingsManager().toggleUnit(),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.greenAccent,
                    ),
                    const Text("°C", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const Divider(color: Colors.white30),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Saved Locations",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: SettingsManager().savedLocations,
                  builder: (context, locations, child) {
                    if (locations.isEmpty) {
                      return const Center(
                        child: Text(
                          "No saved locations",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final city = locations[index];
                        return ListTile(
                          title: Text(
                            city,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _controller.text = city;
                            _getWeather();
                            Navigator.pop(context);
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white70,
                            ),
                            onPressed: () =>
                                SettingsManager().removeLocation(city),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHourlyWeatherCard(HourlyForecast hour) {
    final now = DateTime.now();
    final isNow =
        hour.dateTime.hour == now.hour &&
        hour.dateTime.day == now.day &&
        hour.dateTime.month == now.month;

    final timeStr = isNow
        ? "Now"
        : "${hour.dateTime.hour.toString().padLeft(2, '0')}:00";

    return GlassContainer(
      width: 100,
      color: isNow ? Colors.blue : Colors.white,
      opacity: isNow ? 0.4 : 0.1,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: SettingsManager().isCelsius,
            builder: (context, isCelsius, _) {
              final temp = SettingsManager().convertTemp(hour.temp);
              return Text(
                "${temp.toStringAsFixed(0)}°",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          AnimatedWeatherIcon(description: hour.condition, size: 32),
          Text(
            timeStr,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
  }
}
