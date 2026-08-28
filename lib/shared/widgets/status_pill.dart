import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';

/// Small uppercase badge — referral status, product tags, activity labels.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    this.background,
    this.foreground,
    super.key,
  });

  final String label;

  /// Defaults to the palette's tint.
  final Color? background;

  /// Defaults to the palette's accent text.
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? palette.tint,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.figtree(
            size: 10.5,
            weight: 800,
            letterSpacing: 0.42,
            color: foreground ?? palette.accentText,
          ),
        ),
      ),
    );
  }
}
