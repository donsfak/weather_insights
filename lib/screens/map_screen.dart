import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../managers/settings_manager.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'dart:async';
import 'dart:ui';
import '../widgets/map_timeline_control.dart';
import '../widgets/precipitation_overlay.dart';
import '../widgets/precipitation_legend.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapScreen({super.key, this.initialLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(5.4164, -4.0083); // Default to Abidjan
  LatLng? _userLocation;
  WeatherModel? _weather;
  final WeatherService _weatherService = WeatherService();
  String _locationStatus = 'Searching for location...';
  bool _isLocationLoading = true;

  // Forecasting
  double _currentForecastHour = 0;
  bool _isPlaying = false;
  Timer? _animationTimer;

  // Layer Control
  String _currentLayer = 'precipitation'; // precipitation, temp_new
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _center = widget.initialLocation!;
      _userLocation = widget.initialLocation; // Treat as user loc for now
      _locationStatus = 'Showing selected city';
      _isLocationLoading = false;
      _fetchWeatherForLocation(_center);
    } else {
      _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'Location services disabled';
          _isLocationLoading = false;
        });
        debugPrint('[MAP] Location services are disabled');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Location permission denied';
            _isLocationLoading = false;
          });
          debugPrint('[MAP] Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permission denied forever';
          _isLocationLoading = false;
        });
        debugPrint('[MAP] Location permission denied forever');
        return;
      }

      await _getUserLocation();
    } catch (e) {
      setState(() {
        _locationStatus = 'Error: $e';
        _isLocationLoading = false;
      });
      debugPrint('[MAP] Permission error: $e');
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      debugPrint('[MAP] Requesting current position...');

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint(
        '[MAP] Got position: ${position.latitude}, ${position.longitude}',
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _center = _userLocation!;
        _locationStatus =
            'Location found: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _isLocationLoading = false;
      });

      // Move map to user location with animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_center, 13.0);
      });

      _fetchWeatherForLocation(_center);
    } catch (e) {
      debugPrint('[MAP] Error getting location: $e');
      setState(() {
        _locationStatus = 'Could not get location: $e';
        _isLocationLoading = false;
        // Use default location (Abidjan)
        _center = const LatLng(5.4164, -4.0083);
      });
      _mapController.move(_center, 11.0);
      _fetchWeatherForLocation(_center);
    }
  }

  Future<void> _fetchWeatherForLocation(LatLng location) async {
    final weather = await _weatherService.fetchWeatherByCoords(
      location.latitude,
      location.longitude,
    );
    setState(() {
      _weather = weather;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 10.0,
              onTap: (tapPosition, point) {
                _fetchWeatherForLocation(point);
              },
            ),
            children: [
              // Dark Base Map (CartoDB Dark Matter)
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.weather_insights_app',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              // Apple Weather-style Precipitation Overlay
              if (_currentLayer == 'precipitation')
                AnimatedPrecipitationLayer(
                  isPlaying: _isPlaying,
                  currentHour: _currentForecastHour,
                ),
              // Temperature layer (fallback)
              if (_currentLayer == 'temp_new')
                TileLayer(
                  urlTemplate:
                      'https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=$_apiKey',
                  userAgentPackageName: 'com.example.weather_insights_app',
                ),
              // User location marker
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              // Saved locations markers
              MarkerLayer(markers: _buildSavedLocationMarkers()),
            ],
          ),

          // Close button (top left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildGlassButton(
              icon: Icons.close,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Layer Control (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                _buildGlassButton(
                  icon: Icons.layers,
                  onPressed: () {
                    setState(() {
                      if (_currentLayer == 'precipitation') {
                        _currentLayer = 'temp_new';
                      } else {
                        _currentLayer = 'precipitation';
                      }
                    });
                    String layerName = 'PRECIPITATION';
                    if (_currentLayer == 'temp_new') {
                      layerName = 'TEMPERATURE';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Layer: $layerName'),
                        duration: const Duration(milliseconds: 1000),
                        backgroundColor: Colors.black87,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(
                          bottom: 120,
                          left: 20,
                          right: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildGlassButton(
                  icon: Icons.my_location,
                  onPressed: _userLocation != null
                      ? () {
                          _mapController.move(_userLocation!, 12.0);
                          _fetchWeatherForLocation(_userLocation!);
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                _buildGlassButton(
                  icon: Icons.add,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildGlassButton(
                  icon: Icons.remove,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
              ],
            ),
          ),

          // Weather info card (top center)
          if (_weather != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 80,
              right: 80,
              child: _buildWeatherCard(isDarkMode),
            ),

          // Precipitation Legend (Top Right, below layers button)
          if (_currentLayer == 'precipitation')
            const Positioned(top: 100, right: 16, child: PrecipitationLegend()),
          // Timeline Control (bottom)
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: MapTimelineControl(
              currentHour: _currentForecastHour,
              isPlaying: _isPlaying,
              onChanged: (value) {
                setState(() {
                  _currentForecastHour = value;
                  if (_isPlaying) {
                    _isPlaying = false;
                    _animationTimer?.cancel();
                  }
                });
              },
              onPlayPause: _togglePlay,
            ),
          ),

          // Location status debug overlay (bottom right)
          if (_isLocationLoading || _userLocation == null)
            Positioned(
              bottom: 32,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLocationLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        if (_isLocationLoading) const SizedBox(width: 8),
                        Text(
                          _locationStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, VoidCallback? onPressed}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(bool isDarkMode) {
    final temp = SettingsManager().convertTemp(_weather!.daily.first.temp);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${temp.toStringAsFixed(0)}${SettingsManager().tempUnit}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.cloud, color: Colors.white, size: 32),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _weather!.city,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Marker> _buildSavedLocationMarkers() {
    final savedLocations = SettingsManager().savedLocations.value;
    return savedLocations.map((cityName) {
      final coords = _getCityCoordinates(cityName);
      return Marker(
        point: coords,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            _mapController.move(coords, 12.0);
            _fetchWeatherForLocation(coords);
          },
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      );
    }).toList();
  }

  LatLng _getCityCoordinates(String cityName) {
    // Mock coordinates - in real app, use geocoding API
    final Map<String, LatLng> cityCoords = {
      'New York': const LatLng(40.7128, -74.0060),
      'London': const LatLng(51.5074, -0.1278),
      'Paris': const LatLng(48.8566, 2.3522),
      'Tokyo': const LatLng(35.6762, 139.6503),
      'Abidjan': const LatLng(5.3600, -4.0083),
      'Abobo': const LatLng(5.4164, -4.0211),
    };
    return cityCoords[cityName] ?? const LatLng(0, 0);
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startAnimation();
      } else {
        _animationTimer?.cancel();
      }
    });
  }

  void _startAnimation() {
    const fps = 30;
    const durationSeconds = 10; // 12 hours in 10 seconds
    const totalFrames = fps * durationSeconds;
    const hourPerFrame = 12.0 / totalFrames;

    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 1000 ~/ fps),
      (timer) {
        setState(() {
          _currentForecastHour += hourPerFrame;
          if (_currentForecastHour >= 12) {
            _currentForecastHour = 0;
          }
        });
      },
    );
  }
}
