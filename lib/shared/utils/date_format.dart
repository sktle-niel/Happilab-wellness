/// Date formatting for the one shape this app displays. Hand-rolled for the
/// same reason as `NumberFormat`: `intl` is a large dependency for a month
/// name.
abstract final class DateFormat {
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// 2025-03-12 -> "March 2025"
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';
}
