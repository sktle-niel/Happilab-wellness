import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/activity_entry.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../app/theme/app_palette.dart';

/// Every movement on the account, not just the recent few on home.
class AccountActivityScreen extends StatelessWidget {
  const AccountActivityScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: AppSpacing.pageInset,
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
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry});

  final ActivityEntry entry;

  Color _amountColor(AppPalette palette) => switch (entry.kind) {
    ActivityKind.earned => palette.accentText,
    ActivityKind.cashOut => palette.textMuted,
    ActivityKind.joined => palette.textFaint,
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
                  color: context.palette.textFaint,
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
            color: _amountColor(context.palette),
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
        color: context.palette.textFaint,
      ),
    ),
  );
}
