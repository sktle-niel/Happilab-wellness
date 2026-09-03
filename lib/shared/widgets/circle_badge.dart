import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

/// A disc with something centred in it — the badge shape the design repeats
/// for step numbers, checkmarks, brand marks and small icon actions.
class CircleBadge extends StatelessWidget {
  const CircleBadge({
    required this.size,
    required this.child,
    this.color,
    this.padding,
    super.key,
  });

  final double size;

  /// Defaults to the palette's tint.
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? context.palette.tint,
      shape: BoxShape.circle,
    ),
    child: child,
  );
}
