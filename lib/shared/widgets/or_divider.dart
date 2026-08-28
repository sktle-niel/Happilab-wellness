import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_palette.dart';

/// The rule-OR-rule separator between provider sign-in and the manual form.
class OrDivider extends StatelessWidget {
  const OrDivider({this.label = 'OR', super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: _Rule()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4),
        child: Text(
          label,
          style: AppTypography.figtree(
            size: 12,
            weight: 700,
            color: context.palette.textFaint,
          ),
        ),
      ),
      const Expanded(child: _Rule()),
    ],
  );
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 1, child: ColoredBox(color: context.palette.divider));
}
