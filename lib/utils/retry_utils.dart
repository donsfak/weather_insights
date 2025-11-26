import 'dart:async';

class RetryUtils {
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= maxAttempts ||
            (shouldRetry != null && !shouldRetry(e))) {
          rethrow;
        }

        // ignore: avoid_print
        print(
          'Retry attempt $attempts failed: $e. Retrying in ${delay.inMilliseconds}ms...',
        );

        await Future.delayed(delay);
        delay *= backoffFactor;
      }
    }
  }
}
