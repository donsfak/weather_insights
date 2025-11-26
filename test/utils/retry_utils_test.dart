import 'package:flutter_test/flutter_test.dart';
import 'package:weather_insights_app/utils/retry_utils.dart';

void main() {
  group('RetryUtils', () {
    test('retries operation on failure', () async {
      int attempts = 0;
      try {
        await RetryUtils.retry(
          () async {
            attempts++;
            throw Exception('Fail');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 1),
        );
      } catch (_) {}
      expect(attempts, 3);
    });

    test('returns result on success', () async {
      final result = await RetryUtils.retry(
        () async => 'Success',
        maxAttempts: 3,
      );
      expect(result, 'Success');
    });
  });
}
