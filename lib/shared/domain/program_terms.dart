/// Headline numbers of the referral programme.
///
/// Constants for now because there is no backend to quote them from; when one
/// exists these become a fetched model and every screen still reads them here.
abstract final class ProgramTerms {
  /// Share of each referred sale that the referrer earns.
  static const String earnRate = '5–7%';

  static const String pointsConversion = '1,000 points = ₱1,000';

  /// The same conversion in the compact form the cards use.
  static const String pointsConversionShort = '1,000 pts = ₱1,000';

  /// Ways a member can take their money out.
  static const List<String> payoutMethods = ['GCash', 'Maya'];
}
