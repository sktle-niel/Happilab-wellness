/// Every route name in the app. Screens push these constants, never string
/// literals, so a renamed route is a compile error instead of a blank page.
abstract final class AppRoutes {
  static const String counter = '/';
}
