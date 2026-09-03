import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/security/session_manager.dart';
import '../../../shared/widgets/falcon.dart';
import '../../../shared/widgets/faith_wordmark.dart';
import '../../../shared/widgets/floating_petals.dart';
import '../../../app/theme/app_palette.dart';

/// The loader: brand lockup, drifting petals and the flying falcon, then a
/// hand-off — straight home for a member with a live session, to the product
/// showcase for everyone else.
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
  SessionManager? _session;

  @override
  void initState() {
    super.initState();
    _handoff = Timer(AppDuration.splash, _continueOn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kick the restore off now so it runs behind the entrance animation.
    _session ??= AppScope.of(context).sessionManager..restore();
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _continueOn() async {
    final session = _session!;
    final navigator = Navigator.of(context);
    // Usually already done well inside the splash hold; awaiting covers a slow
    // keystore without a second timer.
    await session.restore();
    if (!mounted) return;
    navigator.pushReplacementNamed(
      session.isSignedIn ? AppRoutes.home : AppRoutes.productIntro,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.canvas,
    body: Stack(
      children: [
        const Positioned.fill(child: FloatingPetals()),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaithWordmark(entrance: _entrance),
              const SizedBox(height: 18),
              const Falcon(clip: FalconClip.loader),
            ],
          ),
        ),
      ],
    ),
  );
}
