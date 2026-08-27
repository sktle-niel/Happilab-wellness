import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/faith_wordmark.dart';
import '../../../shared/widgets/floating_petals.dart';
import 'widgets/faith_mascot.dart';

/// The loader: brand lockup, drifting petals and the mascot, then a hand-off to
/// the product showcase.
///
/// One controller drives the whole entrance; each element claims an interval of
/// it, which is what keeps the stagger in step no matter how the timings change.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    _handoff = Timer(AppDuration.splash, _continueToShowcase);
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  void _continueToShowcase() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.productIntro);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: Stack(
      children: [
        const Positioned.fill(child: FloatingPetals()),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LogoIntro(entrance: _entrance),
              FaithWordmark(entrance: _entrance),
              const SizedBox(height: 18),
              const FaithMascot(),
            ],
          ),
        ),
      ],
    ),
  );
}

/// The mark scales past its resting size and settles back — the canvas
/// `logoIn` keyframe.
class _LogoIntro extends StatelessWidget {
  const _LogoIntro({required this.entrance});

  static const Interval _slice = Interval(0, 0.5, curve: AppCurves.entrance);

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final progress = CurvedAnimation(parent: entrance, curve: _slice);

    final scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.78, end: 1.04), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1), weight: 40),
    ]).animate(progress);

    return FadeTransition(
      opacity: progress,
      child: ScaleTransition(scale: scale, child: const BrandMark(size: 172)),
    );
  }
}
