import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../managers/settings_manager.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'dart:ui';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(5.4164, -4.0083); // Default to Abidjan
  LatLng? _userLocation;
  bool _showPrecipitation = true;
  WeatherModel? _weather;
  final WeatherService _weatherService = WeatherService();
  String _locationStatus = 'Searching for location...';
  bool _isLocationLoading = true;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
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
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_insights_app',
              ),
              if (_showPrecipitation)
                MarkerLayer(markers: _buildPrecipitationMarkers()),
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

          // Controls (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                _buildGlassButton(
                  icon: Icons.layers,
                  onPressed: () {
                    setState(() => _showPrecipitation = !_showPrecipitation);
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

          // Precipitation legend (bottom left)
          if (_showPrecipitation)
            Positioned(
              bottom: 32,
              left: 16,
              child: _buildPrecipitationLegend(isDarkMode),
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

  Widget _buildPrecipitationLegend(bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Précipitations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem('Extrêmes', const Color(0xFFFF0000)),
              _buildLegendItem('Fortes', const Color(0xFFFF6B00)),
              _buildLegendItem('Modérées', const Color(0xFF9B59B6)),
              _buildLegendItem('Faibles', const Color(0xFF3498DB)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
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

  List<Marker> _buildPrecipitationMarkers() {
    // Simulated precipitation zones around Abidjan/Abobo area
    final List<Map<String, dynamic>> precipZones = [
      {'lat': 5.35, 'lon': -4.05, 'intensity': 'extreme'},
      {'lat': 5.42, 'lon': -4.02, 'intensity': 'heavy'},
      {'lat': 5.40, 'lon': -3.98, 'intensity': 'moderate'},
      {'lat': 5.38, 'lon': -4.10, 'intensity': 'light'},
      {'lat': 5.45, 'lon': -4.08, 'intensity': 'heavy'},
      {'lat': 5.32, 'lon': -3.95, 'intensity': 'moderate'},
      {'lat': 5.48, 'lon': -4.15, 'intensity': 'light'},
      // Additional zones near user's potential location
      {
        'lat': _center.latitude + 0.02,
        'lon': _center.longitude + 0.02,
        'intensity': 'moderate',
      },
      {
        'lat': _center.latitude - 0.03,
        'lon': _center.longitude - 0.01,
        'intensity': 'light',
      },
      {
        'lat': _center.latitude + 0.01,
        'lon': _center.longitude - 0.03,
        'intensity': 'heavy',
      },
    ];

    return precipZones.map((zone) {
      Color markerColor;
      double size;

      switch (zone['intensity']) {
        case 'extreme':
          markerColor = const Color(0xFFFF0000);
          size = 60;
          break;
        case 'heavy':
          markerColor = const Color(0xFFFF6B00);
          size = 50;
          break;
        case 'moderate':
          markerColor = const Color(0xFF9B59B6);
          size = 40;
          break;
        case 'light':
        default:
          markerColor = const Color(0xFF3498DB);
          size = 30;
          break;
      }

      return Marker(
        point: LatLng(zone['lat'], zone['lon']),
        width: size,
        height: size,
        child: Container(
          decoration: BoxDecoration(
            color: markerColor.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(color: markerColor, width: 2),
          ),
          child: Center(
            child: Icon(Icons.water_drop, color: markerColor, size: size * 0.4),
          ),
        ),
      );
    }).toList();
  }
}
