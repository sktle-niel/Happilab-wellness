import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Petals drifting up the loader background.
///
/// Each petal owns one controller running at its own period and reads a phase
/// offset instead of waiting on a timer, so the five never fall into step and
/// nothing has to be cancelled on dispose beyond the controller itself.
class FloatingPetals extends StatelessWidget {
  const FloatingPetals({super.key});

  static const List<_PetalSpec> _petals = [
    _PetalSpec(0.12, 16, 12, 5.5, 0, AppColors.petalLight),
    _PetalSpec(0.30, 12, 9, 6.5, 1.2, AppColors.petalDeep),
    _PetalSpec(0.52, 18, 13, 5, 2.1, AppColors.petalLight),
    _PetalSpec(0.70, 13, 10, 7, 0.6, AppColors.petalDeep),
    _PetalSpec(0.86, 15, 11, 6, 1.7, AppColors.petalLight),
  ];

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          for (final petal in _petals)
            Positioned(
              left: constraints.maxWidth * petal.left,
              top: constraints.maxHeight / 2,
              child: _Petal(spec: petal, travel: constraints.maxHeight),
            ),
        ],
      ),
    ),
  );
}

class _PetalSpec {
  const _PetalSpec(
    this.left,
    this.width,
    this.height,
    this.seconds,
    this.delaySeconds,
    this.color,
  );

  /// Horizontal position as a fraction of the screen width.
  final double left;
  final double width;
  final double height;
  final double seconds;
  final double delaySeconds;
  final Color color;

  double get phase => (delaySeconds / seconds) % 1;
}

class _Petal extends StatefulWidget {
  const _Petal({required this.spec, required this.travel});

  final _PetalSpec spec;

  /// Height of the area the petal crosses.
  final double travel;

  @override
  State<_Petal> createState() => _PetalState();
}

class _PetalState extends State<_Petal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.spec.seconds * 1000).round()),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Mirrors the canvas keyframes: fades in by 12%, holds, fades out at the top.
  double _opacityAt(double t) => switch (t) {
    < 0.12 => (t / 0.12) * 0.6,
    < 0.88 => 0.6 - (t - 0.12) / 0.76 * 0.1,
    _ => 0.5 * (1 - (t - 0.88) / 0.12),
  };

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + spec.phase) % 1;
        return Transform.translate(
          offset: Offset(0, widget.travel * (0.46 - 0.98 * t)),
          child: Transform.rotate(
            angle: t * 300 * 3.1415926535 / 180,
            child: Opacity(opacity: _opacityAt(t).clamp(0, 1), child: child),
          ),
        );
      },
      child: Container(
        width: spec.width,
        height: spec.height,
        decoration: BoxDecoration(
          color: spec.color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(spec.width * 0.6, spec.height * 0.6),
            topRight: Radius.elliptical(spec.width * 0.4, spec.height * 0.4),
            bottomRight: Radius.elliptical(spec.width * 0.6, spec.height * 0.6),
            bottomLeft: Radius.elliptical(spec.width * 0.4, spec.height * 0.4),
          ),
        ),
      ),
    );
  }
}
