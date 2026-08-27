import 'dart:math';

/// Exponential backoff with jitter for transient failures.
///
/// Two rules keep retries from making an outage worse: only transient failures
/// are retried (retrying a 400 just burns the rate limit), and delays are
/// jittered so every device on the network does not come back in lockstep.
class RetryPolicy {
  RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 8),
    this.maxServerCooldown = const Duration(seconds: 60),
    Random? random,
  }) : assert(maxAttempts >= 1, 'At least one attempt must be made'),
       _random = random ?? Random();

  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;

  /// Upper bound applied to a server `Retry-After`, so a bad header cannot
  /// freeze the UI for hours.
  final Duration maxServerCooldown;

  final Random _random;

  /// [attempt] is 1-based. Timeouts and connection failures arrive with a null
  /// [statusCode] and are treated as transient.
  bool shouldRetry({required int attempt, int? statusCode}) {
    if (attempt >= maxAttempts) return false;
    if (statusCode == null) return true;
    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }

  /// A server-sent [retryAfter] wins — it is the backend telling us its state.
  Duration delayFor(int attempt, {Duration? retryAfter}) {
    if (retryAfter != null) {
      return retryAfter > maxServerCooldown ? maxServerCooldown : retryAfter;
    }

    final exponential = initialDelay * pow(2, attempt - 1);
    final capped = exponential > maxDelay ? maxDelay : exponential;

    // Equal jitter: half the delay is fixed, half is random. Spreads retries
    // without ever collapsing to an immediate re-send.
    final jittered = capped.inMilliseconds * (0.5 + _random.nextDouble() / 2);
    return Duration(milliseconds: jittered.round());
  }
}
