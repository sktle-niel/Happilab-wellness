import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';

/// Small uppercase badge — referral status, product tags, activity labels.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    this.background = AppColors.cream,
    this.foreground = AppColors.accentText,
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: background, borderRadius: AppRadius.pill),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.figtree(
          size: 10.5,
          weight: 800,
          letterSpacing: 0.42,
          color: foreground,
        ),
      ),
    ),
  );
}
