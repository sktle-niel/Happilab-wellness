import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/program_terms.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/program_guide.dart';
import 'widgets/program_step_card.dart';

/// The programme explained: the three steps, what a point is worth, and a
/// worked example.
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const ScreenHeader(title: 'How it works'),
          const Gap(AppSpacing.md),
          for (final step in ProgramGuide.steps) ...[
            ProgramStepCard(step: step),
            const Gap(14),
          ],
          const _ConversionCard(),
          const Gap(14),
          const _ExampleCard(),
          const Gap(AppSpacing.md),
          const SectionHeader(title: 'Benefits when they buy'),
          const Gap(AppSpacing.sm),
          const _BenefitsCard(),
          const Gap(AppSpacing.lg),
          AppButton(
            label: 'Start referring',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.myReferrals),
          ),
        ],
      ),
    ),
  );
}

/// What a point is actually worth — the number the whole programme rests on.
class _ConversionCard extends StatelessWidget {
  const _ConversionCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: const BoxDecoration(
      color: AppColors.accent,
      borderRadius: AppRadius.hero,
      boxShadow: AppShadows.soft,
    ),
    child: Column(
      children: [
        Text(
          'POINTS CONVERT TO REAL MONEY',
          textAlign: TextAlign.center,
          style: AppTypography.figtree(
            size: 11.5,
            weight: 800,
            letterSpacing: 1.15,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const Gap(4),
        Text(
          ProgramTerms.pointsConversionShort,
          textAlign: TextAlign.center,
          style: AppTypography.figtree(
            size: 31,
            weight: 800,
            letterSpacing: -0.31,
            color: AppColors.surface,
          ),
        ),
        const Gap(4),
        Text(
          'Cash out anytime via ${ProgramTerms.payoutMethods.join(', ')}',
          textAlign: TextAlign.center,
          style: AppTypography.figtree(
            size: 13.5,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    ),
  );
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard();

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Example', style: AppTypography.figtree(size: 16.5, weight: 800)),
        const Gap(4),
        Text.rich(
          TextSpan(
            style: AppTypography.figtree(
              size: 14.5,
              height: 1.55,
              color: AppColors.textMuted,
            ),
            children: [
              TextSpan(
                text:
                    'Your friend orders ${ProgramGuide.exampleOrder} of '
                    'products with your code. You earn '
                    '${ProgramTerms.earnRate} — that is ',
              ),
              TextSpan(
                text: ProgramGuide.exampleEarnings,
                style: AppTypography.figtree(
                  size: 14.5,
                  weight: 800,
                  height: 1.55,
                  color: AppColors.accentText,
                ),
              ),
              const TextSpan(
                text: '. You keep earning on their repeat orders too.',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final benefit in ProgramGuide.benefits) _BenefitRow(text: benefit),
      ],
    ),
  );
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: const BoxDecoration(
            color: AppColors.cream,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 13,
            color: AppColors.accentText,
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.figtree(size: 14.5, height: 1.5),
          ),
        ),
      ],
    ),
  );
}
