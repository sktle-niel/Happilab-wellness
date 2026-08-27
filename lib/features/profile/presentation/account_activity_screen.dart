import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/activity_entry.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';

/// Every movement on the account, not just the recent few on home.
class AccountActivityScreen extends StatelessWidget {
  const AccountActivityScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const ScreenHeader(title: 'Account activity'),
          const Gap(14),
          AppCard.flush(
            borderRadius: AppRadius.card,
            child: DividedColumn(
              children: [
                for (final entry in ActivityEntry.placeholder)
                  _ActivityRow(entry: entry),
                const _EndOfList(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry});

  final ActivityEntry entry;

  Color get _amountColor => switch (entry.kind) {
    ActivityKind.earned => AppColors.accentText,
    ActivityKind.cashOut => AppColors.textMuted,
    ActivityKind.joined => AppColors.textFaint,
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.title,
                style: AppTypography.figtree(size: 14.5, height: 1.4),
              ),
              Text(
                entry.when,
                style: AppTypography.figtree(
                  size: 12,
                  weight: 700,
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

class _EndOfList extends StatelessWidget {
  const _EndOfList();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      'No more activity',
      textAlign: TextAlign.center,
      style: AppTypography.figtree(
        size: 12,
        weight: 700,
        color: AppColors.textFaint,
      ),
    ),
  );
}
