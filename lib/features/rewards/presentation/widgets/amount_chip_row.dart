import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/utils/number_format.dart';
import '../../../../shared/widgets/pressable_scale.dart';

/// The preset cash-out amounts, laid out three to a row as the design does.
class AmountChipRow extends StatelessWidget {
  const AmountChipRow({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<int> options;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final points in options) ...[
        if (points != options.first) const SizedBox(width: 10),
        Expanded(
          child: _AmountChip(
            points: points,
            isSelected: points == selected,
            onPressed: () => onSelect(points),
          ),
        ),
      ],
    ],
  );
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.points,
    required this.isSelected,
    required this.onPressed,
  });

  final int points;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    child: PressableScale(
      scale: 0.95,
      onPressed: onPressed,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: AppRadius.pill,
          boxShadow: isSelected ? null : AppShadows.soft,
        ),
        child: Text(
          NumberFormat.peso(points),
          style: AppTypography.figtree(
            size: 15,
            weight: 700,
            color: isSelected ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    ),
  );
}
