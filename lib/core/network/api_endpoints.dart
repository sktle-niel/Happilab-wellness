/// Every path the app calls, in one place. Repositories name a constant, never
/// spell a path, so the API version and the routes change here alone.
abstract final class ApiEndpoints {
  static const String _v = '/v1';

  // Auth
  static const String signIn = '$_v/auth/sign-in';
  static const String register = '$_v/auth/register';
  static const String signOut = '$_v/auth/sign-out';
  static const String refresh = '$_v/auth/refresh';

  // The signed-in member
  static const String me = '$_v/me';
  static const String myDetails = '$_v/me/details';
  static const String myPassword = '$_v/me/password';
  static const String myActivity = '$_v/me/activity';
  static const String myReferrals = '$_v/me/referrals';
  static const String myNotifications = '$_v/me/notifications';
  static const String myNotificationsRead = '$_v/me/notifications/read';
  static const String myPayoutAccounts = '$_v/me/payout-accounts';
  static const String myCashOuts = '$_v/me/cash-outs';

  /// One notification, read.
  static String notificationRead(String id) => '$_v/me/notifications/$id/read';

  // Catalogue and community
  static const String products = '$_v/products';
  static const String feed = '$_v/feed';
  static const String testimonials = '$_v/testimonials';

  // Support
  static const String faqs = '$_v/support/faqs';
  static const String terms = '$_v/support/terms';
}
