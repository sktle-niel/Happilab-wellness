/// Number formatting for the few shapes this app displays.
///
/// Hand-rolled rather than pulling in `intl`: the app shows points and pesos in
/// one locale, and a formatting package is a large dependency for two lines.
abstract final class NumberFormat {
  /// 1240 -> "1,240"
  static String thousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value.isNegative ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// 1240 -> "1,240 pts"
  static String points(int value) => '${thousands(value)} pts';

  /// 1240 -> "₱1,240"
  static String peso(int value) => '₱${thousands(value)}';

  /// Signed, for activity rows: 11 -> "+11 pts", -500 -> "-500 pts".
  static String signedPoints(int value) =>
      '${value > 0 ? '+' : ''}${thousands(value)} pts';
}
