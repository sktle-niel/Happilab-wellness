import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';

/// Wraps a picture so a tap leaves a heart where the finger landed.
///
/// Every tap spawns its own heart on its own controller, so a run of taps
/// overlaps into a burst instead of restarting one animation. Each heart pops
/// in, drifts up and fades out, then takes itself off the stack.
class HeartBurst extends StatefulWidget {
  const HeartBurst({required this.child, required this.onTapped, super.key});

  final Widget child;

  /// Fired on every tap, not only the first — the caller decides what a repeat
  /// means.
  final VoidCallback onTapped;

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<HeartBurst> with TickerProviderStateMixin {
  final List<_Heart> _hearts = <_Heart>[];

  /// Counts every heart ever spawned, which gives each one its tilt without a
  /// random source that a test could not predict.
  int _spawned = 0;

  @override
  void dispose() {
    for (final heart in _hearts) {
      heart.controller.dispose();
    }
    super.dispose();
  }

  void _spawn(TapUpDetails details) {
    widget.onTapped();

    final heart = _Heart(
      at: details.localPosition,
      tilt: (_spawned++ % 3 - 1) * 0.14,
      controller: AnimationController(
        vsync: this,
        duration: AppDuration.heartBurst,
      ),
    );

    setState(() => _hearts.add(heart));
    heart.controller.forward().whenComplete(() {
      // Unmounted means dispose() has already cleaned every controller up.
      if (!mounted) return;
      setState(() => _hearts.remove(heart));
      heart.controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapUp: _spawn,
    behavior: HitTestBehavior.opaque,
    child: Stack(
      children: [
        widget.child,
        for (final heart in _hearts)
          Positioned(
            left: heart.at.dx - _FlyingHeart.size / 2,
            top: heart.at.dy - _FlyingHeart.size / 2,
            // The hearts are decoration; taps belong to the picture under them.
            child: IgnorePointer(child: _FlyingHeart(heart: heart)),
          ),
      ],
    ),
  );
}

/// One heart in flight: where it started, how it leans, and what drives it.
class _Heart {
  const _Heart({
    required this.at,
    required this.tilt,
    required this.controller,
  });

  final Offset at;
  final double tilt;
  final AnimationController controller;
}

class _FlyingHeart extends StatelessWidget {
  const _FlyingHeart({required this.heart});

  /// As small as it can be and still read as a heart: not quite twice the like
  /// icon under the picture. A feed card is not a full-screen video, and the
  /// mark is meant to be left on the photo, not to cover it.
  static const double size = 36;

  /// How far it climbs over its life. Scaled to the mark — a small heart
  /// travelling a long way reads as drifting rather than as a tap landing.
  static const double _rise = 18;

  final _Heart heart;

  /// In fast, hold, then out — the shape that reads as a burst rather than a
  /// fade.
  static double _opacity(double t) {
    if (t < 0.12) return t / 0.12;
    if (t < 0.55) return 1;
    return 1 - (t - 0.55) / 0.45;
  }

  /// A pop that overshoots and settles, done inside the first quarter.
  static double _scale(double t) {
    if (t >= 0.25) return 1;
    return 0.5 + 0.5 * Curves.easeOutBack.transform(t / 0.25);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: heart.controller,
    builder: (context, child) {
      final t = heart.controller.value;

      return Opacity(
        opacity: _opacity(t),
        child: Transform.translate(
          offset: Offset(0, -_rise * t),
          child: Transform.rotate(
            angle: heart.tilt,
            child: Transform.scale(scale: _scale(t), child: child),
          ),
        ),
      );
    },
    child: Icon(
      Icons.favorite_rounded,
      size: size,
      color: context.palette.danger,
      // A picture can be any colour underneath; the lift keeps the shape read.
      shadows: [
        BoxShadow(
          color: context.palette.shadow.withValues(alpha: 0.35),
          blurRadius: 8,
        ),
      ],
    ),
  );
}
