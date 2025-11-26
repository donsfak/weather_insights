# Weather Insights

A comprehensive weather application built with Flutter, featuring real-time weather data, air quality monitoring, precipitation maps, and smart clothing recommendations.

## Features

- **Real-time Weather Data**: Current conditions and 7-day forecasts
- **Hourly Forecasts**: Detailed hour-by-hour weather predictions
- **Air Quality Index (AQI)**: Monitor air quality with health recommendations
- **UV Index**: Sun protection advice based on UV levels
- **Interactive Maps**: Precipitation overlay with animation timeline
- **Smart Clothing Recommendations**: AI-powered outfit suggestions
- **Offline Mode**: Cached data for offline access
- **Multiple Units**: Toggle between Celsius/Fahrenheit and km/h/mph
- **Saved Locations**: Favorite cities for quick access

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- An OpenWeatherMap API key (free tier available)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/weather_insights.git
cd weather_insights
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Keys

1. Copy the `.env.example` file to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Open `.env` and add your OpenWeatherMap API key:

   ```
   OPENWEATHER_API_KEY=your_actual_api_key_here
   ```

3. Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)

### 4. Generate Required Files

Run the build runner to generate Hive adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── services/                 # API and business logic
├── widgets/                  # Reusable UI components
├── managers/                 # State management
└── utils/                    # Helper functions
```

## Testing

Run unit tests:

```bash
flutter test
```

Run specific test file:

```bash
flutter test test/services/weather_service_test.dart
```

## Technologies Used

- **Flutter**: UI framework
- **Hive**: Local data persistence
- **HTTP**: Network requests
- **Flutter Map**: Interactive maps
- **FL Chart**: Data visualization
- **Geolocator**: Location services
- **Connectivity Plus**: Network status monitoring
- **Cached Network Image**: Image caching

## Performance Features

- Image caching for weather icons
- Local data caching with expiration
- Offline mode support
- Optimized map tile loading

## Security

- API keys stored in `.env` (not committed to version control)
- `.env` is listed in `.gitignore`
- Use `.env.example` as a template

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Air quality data from OpenWeatherMap Air Pollution API
- UV index data from Open-Meteo API
