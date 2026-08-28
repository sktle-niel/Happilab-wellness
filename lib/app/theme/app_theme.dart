import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Single source of truth for the app's look, one [ThemeData] per palette.
///
/// Screens never branch on brightness: they read `context.palette` and the
/// palette carries the difference.
abstract final class AppTheme {
  static ThemeData light() => _from(AppPalette.light);

  static ThemeData dark() => _from(AppPalette.dark);

  static ThemeData _from(AppPalette palette) {
    final scheme = ColorScheme(
      brightness: palette.brightness,
      primary: palette.accent,
      onPrimary: palette.onAccent,
      secondary: palette.accentText,
      onSecondary: palette.onAccent,
      surface: palette.canvas,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.surface,
      error: palette.danger,
      onError: palette.surface,
      outline: palette.textFaint,
      shadow: palette.shadow,
    );

    return ThemeData(
      colorScheme: scheme,
      extensions: [palette],
      scaffoldBackgroundColor: palette.canvas,
      textTheme: AppTypography.textTheme(palette),
      splashColor: palette.accent.withValues(alpha: 0.08),
      highlightColor: palette.accent.withValues(alpha: 0.04),
      appBarTheme: AppBarThemeData(
        backgroundColor: palette.canvas,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: AppTypography.buttonPrimary(palette),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          backgroundColor: palette.surface,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          side: BorderSide.none,
          textStyle: AppTypography.buttonSecondary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accentText,
          textStyle: AppTypography.figtree(size: 13, weight: 800),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textPrimary,
        contentTextStyle: AppTypography.figtree(
          size: 14,
          color: palette.canvas,
        ),
      ),
    );
  }
}
