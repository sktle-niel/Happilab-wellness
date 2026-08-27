/// Every route name in the app. Screens push these constants, never string
/// literals, so a renamed route is a compile error instead of a blank page.
abstract final class AppRoutes {
  /// The loader, which hands over to [productIntro].
  static const String splash = '/';

  /// Interstitial showcase; hands over to [onboarding] on its own.
  static const String productIntro = '/product-intro';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String createAccount = '/create-account';

  /// Placeholder destination after sign in, until the Home design is built.
  static const String home = '/home';
}
