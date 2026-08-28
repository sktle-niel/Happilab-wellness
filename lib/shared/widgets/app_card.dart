import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_palette.dart';

/// The white card the content screens are built from.
///
/// Every list, panel and tile in the design shares one surface, one radius and
/// one shadow — putting that here is what keeps them from drifting apart.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderRadius = AppRadius.card,
    this.clip = false,
    super.key,
  });

  /// Rows that run edge to edge (lists with dividers) need their own padding.
  const AppCard.flush({
    required this.child,
    this.color,
    this.borderRadius = AppRadius.hero,
    super.key,
  }) : padding = EdgeInsets.zero,
       clip = true;

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Defaults to the palette's surface.
  final Color? color;
  final BorderRadius borderRadius;

  /// Clips children to the radius — needed when a child paints to the edge.
  final bool clip;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    clipBehavior: clip ? Clip.antiAlias : Clip.none,
    decoration: BoxDecoration(
      color: color ?? context.palette.surface,
      borderRadius: borderRadius,
      boxShadow: context.palette.shadowSoft,
    ),
    child: child,
  );
}
