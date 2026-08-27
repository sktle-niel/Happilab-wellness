import 'package:flutter/material.dart';

/// Faith Wellness palette, taken from the design canvas.
///
/// Screens never declare colors of their own — they read the [ColorScheme] and
/// the semantic tokens below, so a rebrand is a one-file change.
abstract final class AppColors {
  /// Screen background: warm cream.
  static const Color canvas = Color(0xFFFDF4E6);

  /// Cards, inputs and the secondary button sit on white.
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary call to action.
  static const Color accent = Color(0xFFF59A1E);

  /// Links and accent text — a shade deeper than [accent] for contrast.
  static const Color accentText = Color(0xFFE08A1E);
  static const Color accentPressed = Color(0xFFB96F12);

  /// Focus ring on inputs.
  static const Color focus = Color(0xFFF5A02D);

  /// The serif wordmark gold.
  static const Color brandGold = Color(0xFF9C7A2E);

  static const Color textPrimary = Color(0xFF3B2F1E);
  static const Color textMuted = Color(0xFFA08A63);
  static const Color textFaint = Color(0xFFC2AD86);

  static const Color danger = Color(0xFFE0563E);

  /// Warm tint behind chips, avatars and secondary buttons.
  static const Color cream = Color(0xFFFDEED3);

  /// Deeper gold for small uppercase labels on cream.
  static const Color accentDeep = Color(0xFFC47A12);

  /// Splash decoration.
  static const Color petalLight = Color(0xFFF0C8CD);
  static const Color petalDeep = Color(0xFFDDAAB1);
  static const Color blush = Color(0xFFF5B8BD);
  static const Color mascotBody = cream;

  /// Every elevation in the design is the same warm brown at a different alpha.
  static const Color shadow = Color(0xFF966414);

  static const Color divider = Color(0x26966414);
}
