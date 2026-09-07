import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_palette.dart';

/// The frame every screen shares: transparent over the app's backdrop, and
/// a safe area.
///
/// The backdrop is painted once beneath the navigator, so a screen lets it
/// through — that is what keeps the picture still while screens cross-fade
/// over it. Screens describe their content, not their chrome: the safe-area
/// rules live here instead of being retyped in each of them. Padding stays
/// with the caller because a scrollable has to own its own.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    this.bleedTop = false,
    this.bleedBottom = false,
    super.key,
  });

  final Widget child;

  /// True on a screen whose top runs under the status bar and pads itself
  /// for it. The sides stay safe either way.
  final bool bleedTop;

  /// True on a screen whose foot runs under the gesture bar — a sheet that
  /// pays the inset inside itself.
  final bool bleedBottom;

  /// Status-bar icons in the opposite tone to the page — no screen carries
  /// an app bar to set them.
  SystemUiOverlayStyle _overlayStyle(BuildContext context) =>
      context.palette.isDark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: _overlayStyle(context),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(top: !bleedTop, bottom: !bleedBottom, child: child),
    ),
  );
}
