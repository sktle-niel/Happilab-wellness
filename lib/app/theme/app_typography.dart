import 'package:flutter/material.dart';

import 'app_colors.dart';

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
abstract final class AppTypography {
  static TextStyle figtree({
    required double size,
    int weight = 600,
    double? letterSpacing,
    double? height,
    Color color = AppColors.textPrimary,
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
    Color color = AppColors.brandGold,
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

  static TextStyle get screenSubtitle =>
      figtree(size: 13.5, color: AppColors.textMuted);

  static TextStyle get fieldLabel => figtree(
    size: 11,
    weight: 800,
    letterSpacing: 0.66,
    color: AppColors.textMuted,
  );

  static TextStyle get input => figtree(size: 14.5);

  static TextStyle get helper =>
      figtree(size: 11.5, color: AppColors.textFaint);

  static TextStyle get footnote =>
      figtree(size: 13, color: AppColors.textMuted);

  static TextStyle get chip => figtree(size: 10.5, weight: 700);

  static TextStyle get buttonPrimary =>
      figtree(size: 16, weight: 700, color: AppColors.surface);

  static TextStyle get buttonSecondary => figtree(size: 15, weight: 700);

  /// FAITH — the large serif wordmark on the loader.
  static TextStyle get wordmark =>
      cormorant(size: 46, letterSpacing: 9.2, height: 1.1);

  /// WELLNESS — the ruled line beneath the wordmark.
  static TextStyle get wordmarkSub =>
      cormorant(size: 17, weight: 500, letterSpacing: 8.5);

  static TextStyle get tagline => figtree(
    size: 10.5,
    weight: 700,
    letterSpacing: 3.36,
    color: AppColors.textMuted,
  );

  /// Feeds the Material [TextTheme] so stock widgets inherit the brand.
  static TextTheme textTheme() => TextTheme(
    displaySmall: figtree(size: 34, weight: 800, letterSpacing: -0.34),
    headlineMedium: figtree(size: 26, weight: 800, letterSpacing: -0.26),
    titleLarge: screenTitle,
    titleMedium: figtree(size: 16, weight: 700),
    bodyLarge: figtree(size: 14.5),
    bodyMedium: figtree(size: 13.5),
    bodySmall: helper,
    labelLarge: buttonSecondary,
    labelSmall: fieldLabel,
  );

  static TextStyle _style({
    required String family,
    required double size,
    required int weight,
    required Color color,
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
