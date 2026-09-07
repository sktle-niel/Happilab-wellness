import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

/// The illustrated page every screen sits on: the branches and the perched
/// bird, on white or on black to match the theme.
///
/// Painted once, beneath the navigator, so it never moves — screens are
/// transparent over it and cross-fade into one another on top. Pinned to the
/// top right so the bird survives a narrow screen; what a tall phone crops
/// away is the foliage at the left edge, not the character.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({this.child, super.key});

  /// The navigator, as the app's builder hands it over.
  final Widget? child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      // Its own layer: a page repainting above it must not re-record the
      // picture underneath.
      const RepaintBoundary(child: _Picture()),
      ?child,
    ],
  );
}

class _Picture extends StatelessWidget {
  const _Picture();

  static const String _light = 'assets/images/backdrop-light.jpg';
  static const String _dark = 'assets/images/backdrop-dark.jpg';

  String _assetFor(AppPalette palette) => palette.isDark ? _dark : _light;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.palette.canvas,
    child: Image.asset(
      _assetFor(context.palette),
      fit: BoxFit.cover,
      alignment: Alignment.topRight,
      excludeFromSemantics: true,
      // The theme wipe swaps the picture mid-reveal; holding the old frame
      // until the new one has decoded keeps the swap from blinking.
      gaplessPlayback: true,
    ),
  );
}
