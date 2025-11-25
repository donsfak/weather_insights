import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:weather_insights_app/services/weather_service.dart';
import 'package:weather_insights_app/models/weather_model.dart';
import 'package:weather_insights_app/utils/exceptions.dart';
import '../mocks.mocks.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('WeatherService', () {
    late WeatherService weatherService;
    late MockClient mockClient;

    setUpAll(() async {
      await dotenv.load(fileName: "${Directory.current.path}/test/.env.test");
    });

    setUp(() {
      mockClient = MockClient();
      weatherService = WeatherService(client: mockClient);
    });

    group('fetchWeather by city', () {
      test('returns WeatherModel when API call is successful', () async {
        // Arrange
        final mockResponse = File(
          'test/fixtures/weather_response.json',
        ).readAsStringSync();

        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await weatherService.fetchWeather('London');

        // Assert
        expect(result, isA<WeatherModel>());
        expect(result?.city, 'Zocca');
        expect(result?.daily, isNotEmpty);
      });

      test('returns null when API call fails with 404', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result = await weatherService.fetchWeather('InvalidCity');

        // Assert
        expect(result, isNull);
      });

      test('throws NetworkException when network error occurs', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenThrow(const SocketException('No Internet'));

        // Act & Assert
        expect(
          () => weatherService.fetchWeather('London'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('fetchWeatherByCoords', () {
      test('returns WeatherModel when API call is successful', () async {
        // Arrange
        final mockResponse = File(
          'test/fixtures/weather_response.json',
        ).readAsStringSync();

        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await weatherService.fetchWeatherByCoords(
          51.5085,
          -0.1257,
        );

        // Assert
        expect(result, isA<WeatherModel>());
        expect(result?.city, 'Zocca');
      });
    });
  });
}
