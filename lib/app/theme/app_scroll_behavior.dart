import 'package:flutter/material.dart';

/// How every scrollable in the app moves: it stops at its edges, and draws
/// nothing there.
///
/// Android's default pulls the content like taffy when the member scrolls
/// past the end, which read as the cards deforming; the older glow is no
/// better a fit for the glass surfaces. With no edge effect the list simply
/// comes to rest, on every axis.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
