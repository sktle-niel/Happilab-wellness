import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/network/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    late DateTime now;
    RateLimiter build({int maxOperations = 3}) => RateLimiter(
      maxOperations: maxOperations,
      window: const Duration(minutes: 1),
      clock: () => now,
    );

    setUp(() => now = DateTime.utc(2026));

    test('allows exactly the configured number of calls per window', () {
      final limiter = build();

      expect(
        List.generate(3, (_) => limiter.tryAcquire()),
        everyElement(isTrue),
      );
      expect(limiter.tryAcquire(), isFalse);
      expect(limiter.available, 0);
    });

    test('frees a slot once the oldest call slides out of the window', () {
      final limiter = build(maxOperations: 1);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse);

      now = now.add(const Duration(minutes: 1, milliseconds: 1));

      expect(limiter.available, 1);
      expect(limiter.tryAcquire(), isTrue);
    });

    test('reports the cooldown until the next slot', () {
      final limiter = build(maxOperations: 1)..tryAcquire();

      now = now.add(const Duration(seconds: 20));

      expect(limiter.cooldown, const Duration(seconds: 40));
    });

    test('run waits for capacity instead of dropping the call', () async {
      final limiter = RateLimiter(
        maxOperations: 1,
        window: const Duration(milliseconds: 30),
      );

      final completed = <int>[];
      await Future.wait([
        limiter.run(() async => completed.add(1)),
        limiter.run(() async => completed.add(2)),
      ]);

      expect(completed, hasLength(2));
    });
  });
}
