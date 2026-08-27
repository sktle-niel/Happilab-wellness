import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing scale. Every gap and padding comes from here — magic numbers
/// scattered across screens are what makes a UI drift out of rhythm.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Horizontal padding shared by the auth screens.
  static const double screenInset = 26;

  /// Vertical rhythm inside a form.
  static const double fieldGap = 10;

  static const double inputHeight = 48;
  static const double buttonHeight = 52;

  /// Circular icon buttons — also the minimum tap target.
  static const double iconButtonSize = 44;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenInset,
    vertical: lg,
  );
}

abstract final class AppRadius {
  static const BorderRadius input = BorderRadius.all(Radius.circular(16));
  static const BorderRadius card = BorderRadius.all(Radius.circular(24));

  /// Buttons and chips are fully rounded in this design.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// The design uses one warm shadow at three depths.
abstract final class AppShadows {
  static const List<BoxShadow> input = [
    BoxShadow(color: Color(0x14966414), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x1F966414), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A966414), blurRadius: 26, offset: Offset(0, 10)),
  ];
}

/// Motion tokens, matching the canvas timings.
abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration screenIn = Duration(milliseconds: 250);
  static const Duration entrance = Duration(milliseconds: 900);

  /// How long the loader holds before handing over to sign in. Long enough for
  /// the wordmark and mascot to finish their entrance.
  static const Duration splash = Duration(milliseconds: 2600);

  /// Default debounce for user-driven work. Pairs with the network rate limiter
  /// to keep request volume predictable.
  static const Duration debounce = Duration(milliseconds: 350);
}

/// Easing shared with the design canvas.
abstract final class AppCurves {
  /// cubic-bezier(.22, 1, .36, 1) — the entrance easing used by every
  /// rise-in and pop-in on the canvas.
  static const Curve entrance = Cubic(0.22, 1, 0.36, 1);
}

/// Semantic surface decoration reused by inputs and white buttons.
abstract final class AppDecoration {
  static BoxDecoration get field => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.input,
    boxShadow: AppShadows.input,
  );

  static BoxDecoration get fieldFocused => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.input,
    boxShadow: AppShadows.input,
    border: Border.all(color: AppColors.focus, width: 2),
  );
}
