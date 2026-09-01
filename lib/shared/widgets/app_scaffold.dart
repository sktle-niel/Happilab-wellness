import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

/// The frame every screen shares: the canvas behind it, and a safe area.
///
/// Screens describe their content, not their chrome, so the page background and
/// the safe-area rules live here instead of being retyped in each of them.
/// Padding stays with the caller because a scrollable has to own its own — the
/// list must reach the edges for the scroll to look right.
class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.canvas,
    body: SafeArea(child: child),
  );
}
