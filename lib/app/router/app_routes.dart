/// Every route name in the app. Screens push these constants, never string
/// literals, so a renamed route is a compile error instead of a blank page.
abstract final class AppRoutes {
  // First run
  /// The loader, which hands over to [productIntro].
  static const String splash = '/';

  /// Interstitial showcase; hands over to [onboarding] on its own.
  static const String productIntro = '/product-intro';
  static const String onboarding = '/onboarding';

  // Account
  static const String signIn = '/sign-in';
  static const String createAccount = '/create-account';

  // Main
  static const String home = '/home';
  static const String notifications = '/notifications';

  // Referrals
  static const String howItWorks = '/how-it-works';
  static const String myReferrals = '/my-referrals';

  // Rewards
  static const String rewards = '/rewards';
  static const String editPayoutNumber = '/rewards/payout-number';

  // Community
  static const String newsFeed = '/feed';
  static const String testimonials = '/testimonials';
  static const String suggestions = '/suggestions';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String accountActivity = '/profile/activity';

  // Support
  static const String helpCenter = '/help';
  static const String terms = '/terms';
}
