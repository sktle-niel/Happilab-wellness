import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/payout_account.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/divided_column.dart';
import '../../../../shared/widgets/gap.dart';

/// Single-choice list of the member's payout destinations.
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
      child: ColoredBox(
        color: isSelected ? AppColors.cream : AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          child: Row(
            children: [
              _RadioDot(isSelected: isSelected),
              const Gap(12),
              Expanded(
                child: Text(
                  account.label,
                  style: AppTypography.figtree(size: 15.5, weight: 700),
                ),
              ),
              Text(
                account.reference,
                style: AppTypography.figtree(
                  size: 12.5,
                  color: AppColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.accent, width: 2),
    ),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.accent : Colors.transparent,
      ),
    ),
  );
}
