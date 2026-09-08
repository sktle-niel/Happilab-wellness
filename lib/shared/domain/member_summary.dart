import '../utils/date_format.dart';
import '../utils/number_format.dart';

/// The signed-in member's headline figures.
///
/// Placeholder values until the API exists; every screen reads them from here
/// so there is one place to swap when it does.
class MemberSummary {
  const MemberSummary({
    required this.name,
    required this.referralCode,
    required this.joinedOn,
    required this.points,
    required this.lifetimePoints,
    required this.referredPeople,
    required this.referredBuyers,
    required this.unreadNotifications,
  });

  final String name;
  final String referralCode;

  /// When the member signed up.
  final DateTime joinedOn;

  /// The balance — what there is to cash out now.
  final int points;

  /// Everything the member has ever earned, cash-outs included.
  final int lifetimePoints;

  final int referredPeople;
  final int referredBuyers;
  final int unreadNotifications;

  /// What stands in for a figure while the member keeps it hidden.
  static const String masked = '••••';

  String get pointsFormatted => NumberFormat.thousands(points);

  /// The balance, or the mask when [hidden].
  String pointsShown({required bool hidden}) =>
      hidden ? masked : pointsFormatted;

  /// The peso value, or the mask when [hidden].
  String pesoShown({required bool hidden}) => hidden ? '₱$masked' : pesoValue;

  /// A point is a peso, which is the whole promise of the programme.
  String get pesoValue => NumberFormat.peso(points);

  bool get hasUnread => unreadNotifications > 0;

  String get referralSummary =>
      '$referredPeople people · $referredBuyers purchased';

  /// The line under the name on the profile: how long they have been here,
  /// and what that has added up to.
  String get membershipSummary =>
      'Joined ${DateFormat.monthYear(joinedOn)} · '
      '${NumberFormat.points(lifetimePoints)} earned';

  /// Not a constant only because a date cannot be one.
  static final MemberSummary placeholder = MemberSummary(
    name: 'Ivy Santos',
    referralCode: 'FCV-IVY24',
    joinedOn: DateTime(2025, 3, 12),
    points: 1240,
    lifetimePoints: 4860,
    referredPeople: 8,
    referredBuyers: 5,
    unreadNotifications: 3,
  );
}
