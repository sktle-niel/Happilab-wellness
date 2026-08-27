import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Single source of truth for the app's look.
///
/// The design canvas defines one warm, light palette; there is no dark variant
/// yet, so `HappilabApp` pins [ThemeMode.light]. When a dark canvas exists, add
/// `dark()` here rather than branching on brightness inside screens.
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.surface,
      secondary: AppColors.brandGold,
      onSecondary: AppColors.surface,
      surface: AppColors.canvas,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surface,
      error: AppColors.danger,
      onError: AppColors.surface,
      outline: AppColors.textFaint,
      shadow: AppColors.shadow,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: AppTypography.textTheme(),
      splashColor: AppColors.accent.withValues(alpha: 0.08),
      highlightColor: AppColors.accent.withValues(alpha: 0.04),
      appBarTheme: const AppBarThemeData(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: AppTypography.buttonPrimary,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          side: BorderSide.none,
          textStyle: AppTypography.buttonSecondary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentText,
          textStyle: AppTypography.figtree(size: 13, weight: 800),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
