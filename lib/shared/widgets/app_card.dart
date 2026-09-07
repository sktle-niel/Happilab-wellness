import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_palette.dart';

/// The glass card the content screens are built from.
///
/// Every list, panel and tile in the design shares one surface, one edge, one
/// radius and one shadow — putting that here is what keeps them from drifting
/// apart, and what lets them all sit on the backdrop the same way.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderRadius = AppRadius.card,
    this.clip = false,
    this.shadow,
    super.key,
  });

  /// Rows that run edge to edge (lists with dividers) need their own padding.
  const AppCard.flush({
    required this.child,
    this.color,
    this.borderRadius = AppRadius.hero,
    this.shadow,
    super.key,
  }) : padding = EdgeInsets.zero,
       clip = true;

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Defaults to the palette's glass.
  final Color? color;
  final BorderRadius borderRadius;

  /// Clips children to the radius — needed when a child paints to the edge.
  final bool clip;

  /// Defaults to the palette's soft shadow; hero moments pass a deeper one.
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    clipBehavior: clip ? Clip.antiAlias : Clip.none,
    decoration: BoxDecoration(
      color: color ?? context.palette.glass,
      borderRadius: borderRadius,
      border: Border.all(color: context.palette.glassEdge),
      boxShadow: shadow ?? context.palette.shadowSoft,
    ),
    child: child,
  );
}
