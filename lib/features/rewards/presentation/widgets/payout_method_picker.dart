import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/payout_account.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/divided_column.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/payout_brand_mark.dart';

/// Single-choice list of the member's payout destinations: the provider's
/// mark, its name over the account it is under, a pencil to change it, and a
/// check on the chosen row.
class PayoutMethodPicker extends StatelessWidget {
  const PayoutMethodPicker({
    required this.accounts,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    super.key,
  });

  final List<PayoutAccount> accounts;
  final PayoutAccount? selected;
  final ValueChanged<PayoutAccount> onSelect;

  /// Opens the wallet's form, filled with what is saved.
  final ValueChanged<PayoutKind> onEdit;

  @override
  Widget build(BuildContext context) => AppCard.flush(
    child: DividedColumn(
      children: [
        for (final account in accounts)
          _MethodRow(
            account: account,
            isSelected: account == selected,
            onPressed: () => onSelect(account),
            onEdit: () => onEdit(account.kind),
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
    required this.onEdit,
  });

  final PayoutAccount account;
  final bool isSelected;
  final VoidCallback onPressed;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Semantics(
    inMutuallyExclusiveGroup: true,
    selected: isSelected,
    button: true,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            PayoutBrandMark(logoAsset: account.logoAsset),
            const Gap(12),
            Expanded(child: _AccountLines(account: account)),
            _EditButton(label: account.label, onPressed: onEdit),
            const Gap(AppSpacing.xs),
            _CheckMark(isSelected: isSelected),
          ],
        ),
      ),
    ),
  );
}

/// The wallet's name, and under it whose account and which number.
class _AccountLines extends StatelessWidget {
  const _AccountLines({required this.account});

  final PayoutAccount account;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        account.label,
        style: AppTypography.figtree(size: 15, weight: 700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        '${account.accountName} · ${account.reference}',
        style: AppTypography.figtree(
          size: 12.5,
          color: context.palette.textMuted,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: 'Edit $label',
    splashRadius: 20,
    icon: Icon(
      Icons.edit_outlined,
      size: 19,
      color: context.palette.accentText,
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
