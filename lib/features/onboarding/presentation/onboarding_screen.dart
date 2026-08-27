import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gap.dart';
import '../domain/product_highlight.dart';
import 'widgets/onboarding_backdrop.dart';
import 'widgets/stage_dots.dart';

/// The pitch: what the programme pays, and the way in.
///
/// The backdrop cycles on its own while the copy stays put — the reader is
/// meant to finish one sentence, not chase three.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String headline =
      'Share Wellness, Earn Real Money with Every Referral!';

  /// How long each backdrop stage holds.
  static const Duration stageHold = Duration(milliseconds: 3600);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Timer? _stageTimer;
  int _stageIndex = 0;

  @override
  void initState() {
    super.initState();
    _stageTimer = Timer.periodic(OnboardingScreen.stageHold, _advanceStage);
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }

  void _advanceStage(Timer timer) {
    if (!mounted) return;
    setState(() => _stageIndex = (_stageIndex + 1) % OnboardingBackdrop.count);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: Stack(
      fit: StackFit.expand,
      children: [
        OnboardingBackdrop(stageIndex: _stageIndex),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenInset,
                0,
                AppSpacing.screenInset,
                46,
              ),
              child: _OnboardingPitch(
                stageIndex: _stageIndex,
                onGetStarted: () =>
                    Navigator.of(context).pushNamed(AppRoutes.createAccount),
                onSignIn: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signIn),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _OnboardingPitch extends StatelessWidget {
  const _OnboardingPitch({
    required this.stageIndex,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final int stageIndex;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      StageDots(count: OnboardingBackdrop.count, activeIndex: stageIndex),
      const Gap(14),
      Text(
        OnboardingScreen.headline,
        textAlign: TextAlign.center,
        style: AppTypography.figtree(
          size: 30,
          weight: 800,
          height: 1.25,
          letterSpacing: -0.3,
          color: AppColors.surface,
        ),
      ),
      const Gap(12),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Text(
          'Invite friends to Faith Wellness — earn ${ProgramTerms.earnRate} of '
          'every product they buy. ${ProgramTerms.pointsConversion}.',
          textAlign: TextAlign.center,
          style: AppTypography.figtree(
            size: 14.5,
            height: 1.55,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ),
      const Gap(22),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: AppButton(label: 'Get Started', onPressed: onGetStarted),
      ),
      const Gap(AppSpacing.sm),
      _AlreadyAMember(onPressed: onSignIn),
    ],
  );
}

class _AlreadyAMember extends StatelessWidget {
  const _AlreadyAMember({required this.onPressed});

  /// The link tint the design uses over dark photography.
  static const Color _linkOnDark = Color(0xFFFFB84D);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        'Already a member?',
        style: AppTypography.figtree(
          size: 13.5,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            'Sign in',
            style: AppTypography.figtree(
              size: 13.5,
              weight: 700,
              color: _linkOnDark,
            ),
          ),
        ),
      ),
    ],
  );
}
