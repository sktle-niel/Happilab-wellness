import 'package:flutter/material.dart';

/// Type scale overrides applied on top of the Material baseline.
abstract final class AppTypography {
  static TextTheme from(TextTheme base) => base.copyWith(
    headlineMedium: base.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );
}
