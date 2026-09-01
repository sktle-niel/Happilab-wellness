import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/network/retry_policy.dart';

import '../../support/fixed_random.dart';

void main() {
  group('RetryPolicy', () {
    RetryPolicy build({int maxAttempts = 3, double jitter = 0}) =>
        RetryPolicy(maxAttempts: maxAttempts, random: FixedRandom(jitter));

    test('retries a transient failure up to the attempt ceiling', () {
      final policy = build();

      expect(policy.shouldRetry(attempt: 1, statusCode: 503), isTrue);
      expect(policy.shouldRetry(attempt: 2, statusCode: 503), isTrue);
      expect(policy.shouldRetry(attempt: 3, statusCode: 503), isFalse);
    });

    test('retries the transient status codes and nothing else', () {
      final policy = build();

      for (final code in [408, 429, 500, 502, 503, 504]) {
        expect(
          policy.shouldRetry(attempt: 1, statusCode: code),
          isTrue,
          reason: '$code is worth another attempt',
        );
      }

      // A 4xx means the request itself was wrong: sending it again cannot
      // change the answer, it only burns the rate limit.
      for (final code in [400, 401, 403, 404, 409, 422]) {
        expect(
          policy.shouldRetry(attempt: 1, statusCode: code),
          isFalse,
          reason: '$code will fail the same way',
        );
      }
    });

    test('treats a timeout or a dropped connection as transient', () {
      expect(build().shouldRetry(attempt: 1, statusCode: null), isTrue);
    });

    test('a server cooldown wins over local backoff', () {
      expect(
        build().delayFor(1, retryAfter: const Duration(seconds: 5)),
        const Duration(seconds: 5),
      );
    });

    test('clamps a server cooldown that would freeze the UI', () {
      final policy = RetryPolicy(
        maxServerCooldown: const Duration(seconds: 60),
        random: const FixedRandom(0),
      );

      expect(
        policy.delayFor(1, retryAfter: const Duration(hours: 2)),
        const Duration(seconds: 60),
      );
    });

    test('doubles the delay each attempt, up to the ceiling', () {
      // The highest draw leaves the full backoff standing to assert against.
      final policy = build(jitter: 1);

      expect(policy.delayFor(1), const Duration(milliseconds: 300));
      expect(policy.delayFor(2), const Duration(milliseconds: 600));
      expect(policy.delayFor(3), const Duration(milliseconds: 1200));
      expect(policy.delayFor(9), const Duration(seconds: 8));
    });

    test('never collapses a retry into an immediate re-send', () {
      // Even the lowest draw keeps half the backoff.
      final policy = build(jitter: 0);

      expect(policy.delayFor(1), const Duration(milliseconds: 150));
      expect(policy.delayFor(3), const Duration(milliseconds: 600));
    });
  });
}
