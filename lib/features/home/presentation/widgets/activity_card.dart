import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/activity_entry.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/divided_column.dart';

/// Recent movements on the member's balance.
class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.entries, super.key});

  final List<ActivityEntry> entries;

  @override
  Widget build(BuildContext context) => AppCard.flush(
    child: DividedColumn(
      children: [for (final entry in entries) _ActivityRow(entry: entry)],
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry});

  final ActivityEntry entry;

  /// Money in is gold, money out is muted, and everything else is neutral.
  Color get _amountColor => switch (entry.kind) {
    ActivityKind.earned => AppColors.accentText,
    ActivityKind.cashOut => AppColors.textMuted,
    ActivityKind.joined => AppColors.textFaint,
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.title, style: AppTypography.figtree(size: 14.5)),
              Text(
                entry.when,
                style: AppTypography.figtree(
                  size: 12,
                  color: AppColors.textFaint,
                ),
              ),
            ],
          ),
        ),
        Text(
          entry.amountLabel,
          style: AppTypography.figtree(
            size: 14.5,
            weight: 800,
            color: _amountColor,
          ),
        ),
      ],
    ),
  );
}
