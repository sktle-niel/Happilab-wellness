/// Every route name in the app. Screens push these constants, never string
/// literals, so a renamed route is a compile error instead of a blank page.
abstract final class AppRoutes {
  /// The loader, which hands over to [signIn].
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String createAccount = '/create-account';

  /// Placeholder destination after sign in, until the Home design is built.
  static const String home = '/home';
}
