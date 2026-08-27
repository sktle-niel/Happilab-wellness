import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/program_terms.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../../../shared/widgets/remote_image.dart';

/// Cream banner pointing at the programme explainer.
class AffiliateBanner extends StatelessWidget {
  const AffiliateBanner({required this.onHowItWorks, super.key});

  /// Stock photography from the design canvas — replace with product shots.
  static const String _imageUrl =
      'https://images.unsplash.com/photo-1585652757141-8837d676fac8?w=300&q=80';

  final VoidCallback onHowItWorks;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: const BoxDecoration(
      color: AppColors.cream,
      borderRadius: AppRadius.hero,
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AFFILIATE PROGRAM',
                style: AppTypography.figtree(
                  size: 11,
                  weight: 800,
                  letterSpacing: 0.66,
                  color: AppColors.accentDeep,
                ),
              ),
              const Gap(4),
              Text(
                'Earn ${ProgramTerms.earnRate} on every product',
                style: AppTypography.figtree(
                  size: 17,
                  weight: 800,
                  height: 1.25,
                  letterSpacing: -0.17,
                ),
              ),
              const Gap(10),
              _HowItWorksButton(onPressed: onHowItWorks),
            ],
          ),
        ),
        const Gap(12),
        const RemoteImage(
          url: _imageUrl,
          width: 104,
          height: 118,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ],
    ),
  );
}

class _HowItWorksButton extends StatelessWidget {
  const _HowItWorksButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: PressableScale(
      scale: 0.95,
      onPressed: onPressed,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          'How it works',
          style: AppTypography.figtree(
            size: 13.5,
            weight: 700,
            color: AppColors.surface,
          ),
        ),
      ),
    ),
  );
}
