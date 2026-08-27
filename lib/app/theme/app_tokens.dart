import 'package:flutter/widgets.dart';

/// Spacing scale. Every gap and padding in the app comes from here — magic
/// numbers scattered across screens are what makes a UI drift out of rhythm.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Minimum interactive height; keeps every control above the 48dp tap target.
  static const double controlHeight = 48;

  static const EdgeInsets screenPadding = EdgeInsets.all(md);
}

/// Corner radii, kept in step with the spacing scale.
abstract final class AppRadius {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(20));
}

/// Motion tokens. Shared durations keep transitions feeling like one product.
abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);

  /// Default debounce for user-driven work (search fields, filters). Pairs with
  /// the network rate limiter to keep request volume predictable.
  static const Duration debounce = Duration(milliseconds: 350);
}
