import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The waving mascot. It draws at its natural 96x92; callers that want it
/// smaller wrap it in a [FittedBox], as the points card does.
///
/// Three controllers, one per rhythm in the design: the body bob (which the
/// ground shadow shares), the faster arm wave, and the slow blink. Sharing one
/// controller would force all three onto the same period and lose the loose,
/// hand-animated feel.
class FaithMascot extends StatefulWidget {
  const FaithMascot({super.key});

  @override
  State<FaithMascot> createState() => _FaithMascotState();
}

class _FaithMascotState extends State<FaithMascot>
    with TickerProviderStateMixin {
  static const Color _outline = AppColors.textPrimary;

  late final AnimationController _bob = _loop(1100, reverse: true);
  late final AnimationController _wave = _loop(550, reverse: true);
  late final AnimationController _blink = _loop(3400);

  AnimationController _loop(int milliseconds, {bool reverse = false}) =>
      AnimationController(
        vsync: this,
        duration: Duration(milliseconds: milliseconds),
      )..repeat(reverse: reverse);

  @override
  void dispose() {
    _bob.dispose();
    _wave.dispose();
    _blink.dispose();
    super.dispose();
  }

  /// Open eyes for most of the cycle, one quick squash near the end.
  double _eyeScale(double t) => switch (t) {
    < 0.90 => 1,
    < 0.94 => 1 - (t - 0.90) / 0.04 * 0.92,
    _ => 0.08 + (t - 0.94) / 0.06 * 0.92,
  };

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedBuilder(
        animation: _bob,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -8 * Curves.easeInOut.transform(_bob.value)),
          child: child,
        ),
        child: SizedBox(
          width: 96,
          height: 92,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(left: 8, top: 10, child: _Body()),
              const Positioned(left: 26, top: -2, child: _Ear()),
              Positioned(left: 30, top: 36, child: _buildEye()),
              Positioned(left: 57, top: 36, child: _buildEye()),
              const Positioned(left: 22, top: 48, child: _Cheek()),
              const Positioned(left: 64, top: 48, child: _Cheek()),
              const Positioned(left: 41, top: 50, child: _Mouth()),
              Positioned(left: -5, top: 38, child: _buildWavingArm()),
              const Positioned(right: -3, top: 52, child: _RestingArm()),
            ],
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _bob,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_bob.value);
          return Transform.scale(
            scaleX: 1 - 0.18 * t,
            child: Opacity(opacity: 0.18 - 0.08 * t, child: child),
          );
        },
        child: const SizedBox(
          width: 56,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _outline,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildEye() => AnimatedBuilder(
    animation: _blink,
    builder: (context, child) =>
        Transform.scale(scaleY: _eyeScale(_blink.value), child: child),
    child: const DecoratedBox(
      decoration: BoxDecoration(color: _outline, shape: BoxShape.circle),
      child: SizedBox(width: 9, height: 11),
    ),
  );

  Widget _buildWavingArm() => AnimatedBuilder(
    animation: _wave,
    builder: (context, child) => Transform.rotate(
      // The arm pivots at the shoulder, which is its right edge.
      alignment: Alignment.centerRight,
      angle:
          (14 - 42 * Curves.easeInOut.transform(_wave.value)) * math.pi / 180,
      child: child,
    ),
    child: const _Limb(width: 22, height: 9),
  );
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) => Container(
    width: 80,
    height: 72,
    decoration: BoxDecoration(
      color: AppColors.mascotBody,
      border: Border.all(color: AppColors.textPrimary, width: 2.5),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(38),
        topRight: Radius.circular(38),
        bottomLeft: Radius.circular(34),
        bottomRight: Radius.circular(34),
      ),
    ),
  );
}

class _Ear extends StatelessWidget {
  const _Ear();

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -18 * math.pi / 180,
    child: Container(
      width: 18,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.petalLight,
        border: Border.all(color: AppColors.textPrimary, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.elliptical(10.8, 8.4),
          topRight: Radius.elliptical(7.2, 5.6),
          bottomRight: Radius.elliptical(10.8, 8.4),
          bottomLeft: Radius.elliptical(7.2, 5.6),
        ),
      ),
    ),
  );
}

class _Cheek extends StatelessWidget {
  const _Cheek();

  @override
  Widget build(BuildContext context) => const Opacity(
    opacity: 0.8,
    child: SizedBox(
      width: 10,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
      ),
    ),
  );
}

class _Limb extends StatelessWidget {
  const _Limb({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.mascotBody,
      border: Border.all(color: AppColors.textPrimary, width: 2.5),
      borderRadius: const BorderRadius.all(Radius.circular(999)),
    ),
  );
}

class _RestingArm extends StatelessWidget {
  const _RestingArm();

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: 24 * math.pi / 180,
    child: const _Limb(width: 20, height: 9),
  );
}

class _Mouth extends StatelessWidget {
  const _Mouth();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 14,
    height: 7,
    child: CustomPaint(painter: _MouthPainter()),
  );
}

class _MouthPainter extends CustomPainter {
  const _MouthPainter();

  @override
  void paint(Canvas canvas, Size size) => canvas.drawArc(
    Rect.fromLTWH(0, -size.height, size.width, size.height * 2),
    0,
    math.pi,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.textPrimary,
  );

  @override
  bool shouldRepaint(_MouthPainter oldDelegate) => false;
}
