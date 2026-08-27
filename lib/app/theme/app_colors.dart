import 'package:flutter/material.dart';

/// Brand color tokens.
///
/// Screens never declare colors of their own — they read the [ColorScheme]
/// that `AppTheme` derives from these seeds, so a rebrand is a one-file change.
abstract final class AppColors {
  static const Color seed = Color(0xFF4F46E5);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
}
