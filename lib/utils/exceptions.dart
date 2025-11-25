// ignore_for_file: use_super_parameters

class WeatherException implements Exception {
  final String message;
  final String? code;

  WeatherException(this.message, {this.code});

  @override
  String toString() =>
      'WeatherException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends WeatherException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class ApiException extends WeatherException {
  final int statusCode;

  ApiException(this.statusCode, String message)
    : super(message, code: 'API_ERROR_$statusCode');
}

class LocationException extends WeatherException {
  LocationException(String message) : super(message, code: 'LOCATION_ERROR');
}
