import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/gap.dart';
import '../../domain/program_guide.dart';
import '../../../../app/theme/app_palette.dart';

/// A numbered step in the programme explainer.
class ProgramStepCard extends StatelessWidget {
  const ProgramStepCard({required this.step, super.key});

  final ProgramStep step;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.palette.tint,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${step.number}',
            style: AppTypography.figtree(
              size: 18,
              weight: 800,
              color: context.palette.accentText,
            ),
          ),
        ),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step.title,
                style: AppTypography.figtree(size: 16.5, weight: 800),
              ),
              Text(
                step.detail,
                style: AppTypography.figtree(
                  size: 14,
                  height: 1.5,
                  color: context.palette.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
