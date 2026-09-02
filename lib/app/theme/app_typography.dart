import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppFonts {
  /// UI and body copy.
  static const String body = 'Figtree';

  /// The serif wordmark.
  static const String display = 'CormorantGaramond';
}

/// Type scale taken from the design canvas.
///
/// Both families ship as variable fonts, so every style sets the weight twice:
/// [FontWeight] drives layout and fallback selection, [FontVariation] drives the
/// actual `wght` axis. Going through [figtree] and [cormorant] keeps that pair
/// in sync — a raw `TextStyle` would silently render at the default weight.
///
/// A style without a colour inherits the theme's text colour, which is what
/// lets the same widget tree render in either palette. Styles that need a
/// specific tone take the palette.
abstract final class AppTypography {
  static TextStyle figtree({
    required double size,
    int weight = 600,
    double? letterSpacing,
    double? height,
    Color? color,
  }) => _style(
    family: AppFonts.body,
    size: size,
    weight: weight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );

  static TextStyle cormorant({
    required double size,
    int weight = 600,
    double? letterSpacing,
    double? height,
    Color? color,
  }) => _style(
    family: AppFonts.display,
    size: size,
    weight: weight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );

  // Named styles. Screens use these instead of measuring their own text.
  static TextStyle get screenTitle =>
      figtree(size: 23, weight: 800, letterSpacing: -0.23);

  static TextStyle screenSubtitle(AppPalette palette) =>
      figtree(size: 13.5, color: palette.textMuted);

  static TextStyle fieldLabel(AppPalette palette) => figtree(
    size: 11,
    weight: 800,
    letterSpacing: 0.66,
    color: palette.textMuted,
  );

  static TextStyle get input => figtree(size: 14.5);

  static TextStyle helper(AppPalette palette) =>
      figtree(size: 11.5, color: palette.textFaint);

  static TextStyle footnote(AppPalette palette) =>
      figtree(size: 13, color: palette.textMuted);

  static TextStyle get chip => figtree(size: 10.5, weight: 700);

  static TextStyle buttonPrimary(AppPalette palette) =>
      figtree(size: 16, weight: 700, color: palette.onAccent);

  static TextStyle get buttonSecondary => figtree(size: 15, weight: 700);

  /// AC FALCON CREST — the large serif wordmark on the loader.
  ///
  /// The brand green rather than the emblem's gold: the name is set in the
  /// same colour the accent speaks in, so the lockup belongs to the app rather
  /// than to the crest it replaced.
  static TextStyle wordmark(AppPalette palette) => cormorant(
    size: 34,
    weight: 600,
    letterSpacing: 6.8,
    height: 1.1,
    color: palette.accentText,
  );

  /// VENTURES — the ruled line beneath the wordmark.
  static TextStyle wordmarkSub(AppPalette palette) => cormorant(
    size: 15,
    weight: 500,
    letterSpacing: 6.5,
    color: palette.accentText,
  );

  static TextStyle tagline(AppPalette palette) => figtree(
    size: 10,
    weight: 700,
    letterSpacing: 2.2,
    color: palette.textMuted,
  );

  /// Feeds the Material [TextTheme] so stock widgets inherit the brand, and
  /// every uncoloured style above inherits [AppPalette.textPrimary].
  static TextTheme textTheme(AppPalette palette) => TextTheme(
    displaySmall: figtree(size: 34, weight: 800, letterSpacing: -0.34),
    headlineMedium: figtree(size: 26, weight: 800, letterSpacing: -0.26),
    titleLarge: screenTitle,
    titleMedium: figtree(size: 16, weight: 700),
    bodyLarge: figtree(size: 14.5),
    bodyMedium: figtree(size: 13.5),
    bodySmall: helper(palette),
    labelLarge: buttonSecondary,
    labelSmall: fieldLabel(palette),
  ).apply(bodyColor: palette.textPrimary, displayColor: palette.textPrimary);

  static TextStyle _style({
    required String family,
    required double size,
    required int weight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    color: color,
    fontWeight: _weightOf(weight),
    fontVariations: [FontVariation('wght', weight.toDouble())],
    letterSpacing: letterSpacing,
    height: height,
  );

  static FontWeight _weightOf(int weight) => FontWeight.values.firstWhere(
    (candidate) => candidate.value == weight,
    orElse: () => FontWeight.normal,
  );
}
