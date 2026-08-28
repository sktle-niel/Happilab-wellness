import 'package:flutter/material.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/avatar_circle.dart';
import '../../../../shared/widgets/gap.dart';
import '../../domain/testimonial.dart';
import '../../../../app/theme/app_palette.dart';

/// One member story.
class TestimonialCard extends StatelessWidget {
  const TestimonialCard({required this.testimonial, super.key});

  final Testimonial testimonial;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(20),
    borderRadius: AppRadius.hero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Stars(count: testimonial.rating),
        const Gap.sm(),
        Text(
          '“${testimonial.quote}”',
          style: AppTypography.figtree(size: 15, weight: 500, height: 1.55),
        ),
        const Gap(14),
        Row(
          children: [
            AvatarCircle(name: testimonial.name, size: 40),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    testimonial.name,
                    style: AppTypography.figtree(size: 14, weight: 800),
                  ),
                  Text(
                    testimonial.detail,
                    style: AppTypography.figtree(
                      size: 12,
                      color: context.palette.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Stars extends StatelessWidget {
  const _Stars({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$count out of 5 stars',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < count; index++)
          Padding(
            padding: EdgeInsets.only(right: 3),
            child: Icon(
              Icons.star_rounded,
              size: 17,
              color: context.palette.focus,
            ),
          ),
      ],
    ),
  );
}
