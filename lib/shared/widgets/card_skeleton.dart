import 'package:flutter/material.dart';

import 'app_card.dart';
import 'gap.dart';
import 'skeleton.dart';

/// A content card's worth of placeholders — a byline, a few lines, and a
/// picture when the real card carries one — breathing while it loads.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({this.withImage = false, this.lines = 3, super.key});

  final bool withImage;
  final int lines;

  @override
  Widget build(BuildContext context) => Skeleton(
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SkeletonBox.circle(size: 36),
              Gap(10),
              Expanded(child: SkeletonLine(widthFactor: 0.45)),
            ],
          ),
          const Gap(14),
          for (var line = 0; line < lines; line++) ...[
            SkeletonLine(widthFactor: line == lines - 1 ? 0.6 : 1),
            const Gap(8),
          ],
          if (withImage) ...[
            const Gap(6),
            const AspectRatio(aspectRatio: 16 / 10, child: SkeletonBox()),
          ],
        ],
      ),
    ),
  );
}
