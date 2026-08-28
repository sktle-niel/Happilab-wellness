import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_tokens.dart';
import 'theme_controller.dart';

/// Switches palettes with a circular wipe from wherever the member tapped —
/// the same move the web does with a View Transition clipped to a circle.
///
/// The screen is snapshotted, the theme flips underneath, and the snapshot is
/// clipped by a growing hole until the new palette fills the screen. The
/// hole's final radius reaches the farthest corner, so every pixel is
/// covered. Sits above the [MaterialApp] so the whole app, dialogs included,
/// is covered.
class ThemeReveal extends StatefulWidget {
  const ThemeReveal({required this.controller, required this.child, super.key});

  final ThemeController controller;
  final Widget child;

  static ThemeRevealState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_RevealScope>();
    assert(scope != null, 'No ThemeReveal found above this widget.');
    return scope!.state;
  }

  @override
  State<ThemeReveal> createState() => ThemeRevealState();
}

class ThemeRevealState extends State<ThemeReveal>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundary = GlobalKey();

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppDuration.themeReveal,
  );

  ui.Image? _snapshot;
  Offset _origin = Offset.zero;

  @override
  void dispose() {
    _reveal.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  /// Flips the palette, revealing it from the centre of [from]'s widget.
  ///
  /// When the member has asked the system for less motion, the palette just
  /// switches — no snapshot, no wipe.
  Future<void> toggle({required BuildContext from}) async {
    if (_reveal.isAnimating) return;
    if (MediaQuery.disableAnimationsOf(from)) {
      widget.controller.setDark(!widget.controller.isDark);
      return;
    }

    final origin = _centerOf(from);
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final snapshot = await boundary.toImage(
      pixelRatio: View.of(from).devicePixelRatio,
    );
    if (!mounted) {
      snapshot.dispose();
      return;
    }

    setState(() {
      _snapshot?.dispose();
      _snapshot = snapshot;
      _origin = origin;
    });
    widget.controller.setDark(!widget.controller.isDark);

    await _reveal.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _snapshot?.dispose();
      _snapshot = null;
    });
  }

  Offset _centerOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return Offset.zero;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  @override
  Widget build(BuildContext context) => _RevealScope(
    state: this,
    child: Stack(
      fit: StackFit.expand,
      alignment: Alignment.topLeft,
      children: [
        RepaintBoundary(key: _boundary, child: widget.child),
        if (_snapshot != null)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, child) => ClipPath(
                clipper: _HoleClipper(
                  center: _origin,
                  progress: AppCurves.themeReveal.transform(_reveal.value),
                ),
                child: child,
              ),
              child: RawImage(image: _snapshot, fit: BoxFit.fill),
            ),
          ),
      ],
    ),
  );
}

class _RevealScope extends InheritedWidget {
  const _RevealScope({required this.state, required super.child});

  final ThemeRevealState state;

  @override
  bool updateShouldNotify(_RevealScope oldWidget) => state != oldWidget.state;
}

/// Everything except a circle around [center] whose radius grows with
/// [progress] until it reaches the farthest corner.
class _HoleClipper extends CustomClipper<Path> {
  const _HoleClipper({required this.center, required this.progress});

  final Offset center;
  final double progress;

  @override
  Path getClip(Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    final reach = corners
        .map((corner) => (corner - center).distance)
        .reduce(math.max);
    final hole = Path()
      ..addOval(Rect.fromCircle(center: center, radius: reach * progress));
    final whole = Path()..addRect(Offset.zero & size);
    return Path.combine(PathOperation.difference, whole, hole);
  }

  @override
  bool shouldReclip(_HoleClipper oldClipper) =>
      progress != oldClipper.progress || center != oldClipper.center;
}
