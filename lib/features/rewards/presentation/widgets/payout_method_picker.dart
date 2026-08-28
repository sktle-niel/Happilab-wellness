import 'package:flutter/material.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/payout_account.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/divided_column.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/payout_brand_mark.dart';
import '../../../../app/theme/app_palette.dart';

/// Single-choice list of the member's payout destinations: the provider's
/// mark, its name, the masked account, and a check on the chosen row.
class PayoutMethodPicker extends StatelessWidget {
  const PayoutMethodPicker({
    required this.accounts,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<PayoutAccount> accounts;
  final PayoutAccount? selected;
  final ValueChanged<PayoutAccount> onSelect;

  @override
  Widget build(BuildContext context) => AppCard.flush(
    child: DividedColumn(
      children: [
        for (final account in accounts)
          _MethodRow(
            account: account,
            isSelected: account == selected,
            onPressed: () => onSelect(account),
          ),
      ],
    ),
  );
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.account,
    required this.isSelected,
    required this.onPressed,
  });

  final PayoutAccount account;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    inMutuallyExclusiveGroup: true,
    selected: isSelected,
    button: true,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            PayoutBrandMark(logoAsset: account.logoAsset),
            const Gap(12),
            // Two equal columns put every account number on the same line,
            // however long the provider's name runs.
            Expanded(
              child: Text(
                account.label,
                style: AppTypography.figtree(size: 15, weight: 700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                account.reference,
                style: AppTypography.figtree(
                  size: 12.5,
                  color: context.palette.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(AppSpacing.sm),
            _CheckMark(isSelected: isSelected),
          ],
        ),
      ),
    ),
  );
}

/// Filled disc with a tick when chosen, a faint ring otherwise.
class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppDuration.fast,
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isSelected ? context.palette.accent : Colors.transparent,
      border: Border.all(
        color: isSelected ? context.palette.accent : context.palette.textFaint,
        width: 1.5,
      ),
    ),
    child: isSelected
        ? Icon(Icons.check_rounded, size: 14, color: context.palette.onAccent)
        : null,
  );
}
