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

  /// 15:05 -> "3:05 PM"; 00:30 -> "12:30 AM"
  static String time(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
