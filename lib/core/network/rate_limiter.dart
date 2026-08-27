import 'dart:collection';

/// Sliding-window rate limiter guarding every outbound call.
///
/// Without it a retry storm, a rebuild loop or an over-eager widget can flood
/// the backend, burn the user's quota and get the client blocked. The window
/// slides rather than resetting on a fixed tick, so a burst cannot sneak
/// through on a boundary.
///
/// Not fair across concurrent waiters: callers are released as capacity frees
/// up, not in arrival order. That is fine for UI-driven traffic.
class RateLimiter {
  RateLimiter({
    required this.maxOperations,
    required this.window,
    DateTime Function()? clock,
  }) : assert(maxOperations > 0, 'A limiter must allow at least one call'),
       _clock = clock ?? DateTime.now;

  factory RateLimiter.perMinute(int maxOperations) => RateLimiter(
    maxOperations: maxOperations,
    window: const Duration(minutes: 1),
  );

  final int maxOperations;
  final Duration window;
  final DateTime Function() _clock;
  final Queue<DateTime> _timestamps = Queue<DateTime>();

  /// Slots left in the current window.
  int get available {
    _evictExpired();
    return maxOperations - _timestamps.length;
  }

  /// How long until the next slot frees up.
  Duration get cooldown {
    _evictExpired();
    if (_timestamps.length < maxOperations) return Duration.zero;
    final elapsed = _clock().difference(_timestamps.first);
    final remaining = window - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Consumes a slot if one is free. Never blocks — use it where dropping the
  /// call is better than delaying it.
  bool tryAcquire() {
    _evictExpired();
    if (_timestamps.length >= maxOperations) return false;
    _timestamps.add(_clock());
    return true;
  }

  /// Waits for a slot, then runs [action].
  Future<T> run<T>(Future<T> Function() action) async {
    while (!tryAcquire()) {
      await Future<void>.delayed(cooldown);
    }
    return action();
  }

  void reset() => _timestamps.clear();

  void _evictExpired() {
    final threshold = _clock().subtract(window);
    while (_timestamps.isNotEmpty && !_timestamps.first.isAfter(threshold)) {
      _timestamps.removeFirst();
    }
  }
}
