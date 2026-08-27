import '../../../shared/utils/number_format.dart';

/// The signed-in member's headline figures.
///
/// Placeholder values until the API exists; every screen reads them from here
/// so there is one place to swap when it does.
class MemberSummary {
  const MemberSummary({
    required this.name,
    required this.referralCode,
    required this.points,
    required this.referredPeople,
    required this.referredBuyers,
    required this.unreadNotifications,
  });

  final String name;
  final String referralCode;
  final int points;
  final int referredPeople;
  final int referredBuyers;
  final int unreadNotifications;

  String get pointsFormatted => NumberFormat.thousands(points);

  /// A point is a peso, which is the whole promise of the programme.
  String get pesoValue => NumberFormat.peso(points);

  bool get hasUnread => unreadNotifications > 0;

  String get referralSummary =>
      '$referredPeople people · $referredBuyers purchased';

  static const MemberSummary placeholder = MemberSummary(
    name: 'Ivy Santos',
    referralCode: 'FAITH-IVY24',
    points: 1240,
    referredPeople: 8,
    referredBuyers: 5,
    unreadNotifications: 3,
  );
}
