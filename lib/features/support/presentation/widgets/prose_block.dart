import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// A heading over a paragraph — the shape both the FAQ and the terms use.
class ProseBlock extends StatelessWidget {
  const ProseBlock({required this.heading, required this.body, super.key});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(heading, style: AppTypography.figtree(size: 14.5, weight: 800)),
        const SizedBox(height: 4),
        Text(
          body,
          style: AppTypography.figtree(
            size: 13.5,
            height: 1.55,
            color: AppColors.textMuted,
          ),
        ),
      ],
    ),
  );
}
