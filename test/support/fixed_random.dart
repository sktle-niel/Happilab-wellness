import 'dart:math';

/// A [Random] that returns exactly what a test asked it for.
///
/// Jitter is the point of `RetryPolicy`, and jitter a test cannot predict is a
/// flaky suite — this pins the random half of a delay to a known quantity.
class FixedRandom implements Random {
  const FixedRandom(this.value);

  /// What every [nextDouble] returns: 0 draws the shortest delay the policy
  /// allows, 1 the longest.
  final double value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (max * value).floor();
}
