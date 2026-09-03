import 'package:flutter/material.dart';

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

  /// The page inset every pushed content screen sits in. The generous bottom
  /// keeps the last row clear of the gesture bar.
  static const EdgeInsets pageInset = EdgeInsets.fromLTRB(20, 12, 20, 40);
}

abstract final class AppRadius {
  static const BorderRadius input = BorderRadius.all(Radius.circular(16));
  static const BorderRadius card = BorderRadius.all(Radius.circular(24));

  /// The larger radius the design uses on hero cards.
  static const BorderRadius hero = BorderRadius.all(Radius.circular(26));

  /// Buttons and chips are fully rounded in this design.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
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

  /// The circular reveal that swaps light and dark.
  static const Duration themeReveal = Duration(milliseconds: 540);

  /// How long one heart lives after a tap on a picture. Short enough that a
  /// run of taps overlaps into a burst rather than a queue.
  static const Duration heartBurst = Duration(milliseconds: 900);

  /// One turn of the loader. Slow enough to read as waiting, not as urgency.
  static const Duration pulse = Duration(milliseconds: 1100);

  /// How long a toast stays before it withdraws. Long enough to read two
  /// lines, short enough not to sit over the content.
  static const Duration toast = Duration(milliseconds: 3400);

  /// One beat of the falcon's wings on the loader. A shade slower than the
  /// clip was authored at, which reads as gliding rather than as hurry.
  static const Duration wingbeat = Duration(milliseconds: 900);

  /// One sway of the falcon's wings on the marks that live in the chrome.
  /// A shade longer than the clip runs, so the sway reads as unhurried rather
  /// than as beating — this one is in the corner of the eye all day.
  static const Duration wingSway = Duration(milliseconds: 1000);

  /// How long the wings take to close, and to open again.
  static const Duration wingFold = Duration(milliseconds: 550);

  /// How long they stay closed before the next few beats. Long enough that the
  /// mark settles out of notice, short enough that it is not mistaken for a
  /// still picture.
  static const Duration wingsRested = Duration(milliseconds: 3800);

  /// How long a load may run before the loader admits the connection is slow,
  /// rather than leaving the member guessing whether anything is happening.
  static const Duration slowHint = Duration(seconds: 6);
}

/// Easing shared with the design canvas.
abstract final class AppCurves {
  /// cubic-bezier(.22, 1, .36, 1) — the entrance easing used by every
  /// rise-in and pop-in on the canvas.
  static const Curve entrance = Cubic(0.22, 1, 0.36, 1);

  /// cubic-bezier(.32, .08, .24, 1) — a quick start that settles softly, the
  /// pace of the theme wipe.
  static const Curve themeReveal = Cubic(0.32, 0.08, 0.24, 1);
}
