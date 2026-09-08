import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'app_card.dart';
import 'divided_column.dart';
import 'gap.dart';
import 'skeleton.dart';

/// A list card's worth of placeholders — a face and two lines per row —
/// breathing while the rows load.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({this.rows = 4, this.withAvatar = true, super.key});

  final int rows;
  final bool withAvatar;

  @override
  Widget build(BuildContext context) => Skeleton(
    child: AppCard.flush(
      borderRadius: AppRadius.card,
      child: DividedColumn(
        children: [
          for (var row = 0; row < rows; row++)
            _SkeletonRow(withAvatar: withAvatar),
        ],
      ),
    ),
  );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.withAvatar});

  final bool withAvatar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        if (withAvatar) ...[const SkeletonBox.circle(size: 40), const Gap(12)],
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(widthFactor: 0.55),
              Gap(8),
              SkeletonLine(widthFactor: 0.35, height: 10),
            ],
          ),
        ),
      ],
    ),
  );
}
