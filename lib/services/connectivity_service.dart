import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkConnection(results);
    });
  }

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _checkConnection(results);
  }

  void _checkConnection(List<ConnectivityResult> results) {
    // If any result is not none, we have a connection (WiFi, Mobile, Ethernet, etc.)
    // Note: This doesn't guarantee internet access, just network connection.
    // For actual internet, we'd need to ping a server, but for UI "Offline Mode", this is usually sufficient.
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    _connectionStatusController.add(hasConnection);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
