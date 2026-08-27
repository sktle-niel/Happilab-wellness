import '../utils/number_format.dart';

/// What kind of movement an activity row reports, which decides how its amount
/// is coloured.
enum ActivityKind { earned, cashOut, joined }

/// One line in Recent activity.
class ActivityEntry {
  const ActivityEntry({
    required this.title,
    required this.when,
    required this.kind,
    this.points,
  });

  final String title;
  final String when;
  final ActivityKind kind;

  /// Null for entries that move no points, like a friend joining.
  final int? points;

  String get amountLabel {
    final value = points;
    if (value == null) return '—';
    return NumberFormat.signedPoints(value);
  }

  static const List<ActivityEntry> placeholder = [
    ActivityEntry(
      title: 'Maria bought Sakura Glow Soap',
      when: '2 hours ago',
      kind: ActivityKind.earned,
      points: 11,
    ),
    ActivityEntry(
      title: 'Cash out to GCash',
      when: 'Yesterday',
      kind: ActivityKind.cashOut,
      points: -500,
    ),
    ActivityEntry(
      title: 'Paolo joined with your code',
      when: '3 days ago',
      kind: ActivityKind.joined,
    ),
  ];
}
