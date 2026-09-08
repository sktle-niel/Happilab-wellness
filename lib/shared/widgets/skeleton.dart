import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';

/// Placeholders shaped like the content they stand in for, breathing
/// together while it loads — the simplest motion that still says "coming".
///
/// One [Skeleton] drives every box beneath it from a single ticker, so a
/// screen of placeholders costs one animation, not one per box; a box with
/// no [Skeleton] above it starts its own. The breath is an opacity fade on
/// the compositor, so nothing rebuilds while it runs.
class Skeleton extends StatefulWidget {
  const Skeleton({required this.child, super.key});

  final Widget child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  /// How faint a box gets at the bottom of its breath.
  static const double _faintest = 0.45;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDuration.pulse,
  )..repeat(reverse: true);

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _pulse,
    curve: Curves.easeInOut,
  ).drive(Tween(begin: _faintest, end: 1));

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _SkeletonScope(opacity: _opacity, child: widget.child);
}

class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({required this.opacity, required super.child});

  final Animation<double> opacity;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonScope>()?.opacity;

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) =>
      opacity != oldWidget.opacity;
}

/// One placeholder block: a rounded rectangle, or a disc. Fills its box when
/// given no size.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height,
    this.borderRadius = AppRadius.input,
    super.key,
  }) : _isCircle = false;

  const SkeletonBox.circle({required double size, super.key})
    : width = size,
      height = size,
      borderRadius = null,
      _isCircle = true;

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool _isCircle;

  @override
  Widget build(BuildContext context) {
    final opacity = _SkeletonScope.maybeOf(context);
    if (opacity == null) return Skeleton(child: this);

    return FadeTransition(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.palette.tint,
          shape: _isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// A line of text's worth of placeholder, [widthFactor] of the room it has.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({this.widthFactor = 1, this.height = 12, super.key});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: widthFactor,
    alignment: Alignment.centerLeft,
    child: SkeletonBox(height: height, borderRadius: AppRadius.pill),
  );
}
