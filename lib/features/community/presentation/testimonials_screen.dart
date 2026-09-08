import 'package:flutter/material.dart';

import '../../../shared/widgets/card_skeleton.dart';
import '../../../shared/widgets/repository_view.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/testimonial.dart';
import 'widgets/testimonial_card.dart';

/// What earning actually looked like for other members.
class TestimonialsScreen extends StatelessWidget {
  const TestimonialsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: AppSpacing.pageInset,
      children: [
        const ScreenHeader(title: 'Member stories'),
        const Gap(14),
        RepositoryView<List<Testimonial>>(
          read: (repositories) => repositories.community.testimonials(),
          skeleton: const Column(
            children: [CardSkeleton(withImage: true), Gap(14), CardSkeleton()],
          ),
          builder: (context, testimonials) => Column(
            children: [
              for (final testimonial in testimonials) ...[
                TestimonialCard(testimonial: testimonial),
                const Gap(14),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
