import 'package:flutter/material.dart';

import '../../../../app/theme/app_tokens.dart';

/// Progress pips for the onboarding backdrop. The active one stretches rather
/// than only changing colour, which reads at a glance over photography.
class StageDots extends StatelessWidget {
  const StageDots({required this.count, required this.activeIndex, super.key});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var index = 0; index < count; index++) ...[
        if (index > 0) const SizedBox(width: 6),
        AnimatedContainer(
          duration: AppDuration.screenIn,
          curve: Curves.easeOut,
          width: index == activeIndex ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: index == activeIndex ? 1 : 0.4,
            ),
            borderRadius: AppRadius.pill,
          ),
        ),
      ],
    ],
  );
}
