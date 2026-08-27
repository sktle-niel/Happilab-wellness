import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/payout_account.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/gap.dart';

/// A linked payout destination, with the two things a member does to it.
class PayoutMethodCard extends StatelessWidget {
  const PayoutMethodCard({
    required this.account,
    required this.onEdit,
    required this.onRemove,
    super.key,
  });

  final PayoutAccount account;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    borderRadius: const BorderRadius.all(Radius.circular(20)),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                account.label,
                style: AppTypography.figtree(size: 15, weight: 800),
              ),
              Text(
                account.accountName,
                style: AppTypography.figtree(size: 12.5, weight: 700),
              ),
              Text(
                account.reference,
                style: AppTypography.figtree(
                  size: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        _RoundAction(
          icon: Icons.edit_outlined,
          label: 'Edit ${account.label}',
          background: AppColors.canvas,
          foreground: AppColors.textMuted,
          onPressed: onEdit,
        ),
        const Gap.sm(),
        _RoundAction(
          icon: Icons.delete_outline_rounded,
          label: 'Remove ${account.label}',
          background: const Color(0xFFFDF3F0),
          foreground: AppColors.danger,
          onPressed: onRemove,
        ),
      ],
    ),
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 14, color: foreground),
      ),
    ),
  );
}
