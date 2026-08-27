import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/testimonial.dart';
import 'widgets/testimonial_card.dart';

/// What earning actually looked like for other members.
class TestimonialsScreen extends StatelessWidget {
  const TestimonialsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const ScreenHeader(title: 'Member stories'),
          const Gap(14),
          for (final testimonial in Testimonial.placeholder) ...[
            TestimonialCard(testimonial: testimonial),
            const Gap(14),
          ],
        ],
      ),
    ),
  );
}
