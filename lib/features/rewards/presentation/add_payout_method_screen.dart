import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/payout_account.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';

/// Pick the bank for a third payout destination.
class AddPayoutMethodScreen extends StatelessWidget {
  const AddPayoutMethodScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const ScreenHeader(title: 'Choose your bank'),
          const Gap(14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'Select a Philippine bank for your third payout method.',
              style: AppTypography.figtree(
                size: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const Gap(14),
          AppCard.flush(
            child: DividedColumn(
              children: [
                for (final bank in PhilippineBanks.all)
                  _BankRow(
                    name: bank,
                    onPressed: () => Navigator.of(context).pop(bank),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _BankRow extends StatelessWidget {
  const _BankRow({required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            _BankBadge(name: name),
            const Gap(14),
            Expanded(
              child: Text(
                name,
                style: AppTypography.figtree(size: 14.5, weight: 700),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textFaint,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Stands in for the bank logo the design shows — initials until there are
/// licensed marks to ship.
class _BankBadge extends StatelessWidget {
  const _BankBadge({required this.name});

  final String name;

  String get _initials => name
      .split(RegExp(r'\s+'))
      .take(2)
      .map((word) => word[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(9)),
      border: Border.all(color: AppColors.divider),
    ),
    child: Text(
      _initials,
      style: AppTypography.figtree(
        size: 12,
        weight: 800,
        color: AppColors.accentDeep,
      ),
    ),
  );
}
