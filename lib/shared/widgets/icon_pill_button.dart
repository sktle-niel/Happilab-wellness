import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'pressable_scale.dart';

/// Compact pill with an icon and a label — copy, share, and the small inline
/// actions on the content screens.
///
/// Distinct from [AppButton]: that one is a full-width primary action, this one
/// sits inside a card next to other content.
class IconPillButton extends StatelessWidget {
  const IconPillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.background,
    this.foreground,
    this.height = 44,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  /// Defaults to the palette's tint.
  final Color? background;

  /// Defaults to the palette's primary text colour.
  final Color? foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = this.foreground ?? palette.textPrimary;

    return Semantics(
      button: true,
      label: label,
      child: PressableScale(
        scale: 0.95,
        onPressed: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: background ?? palette.tint,
            borderRadius: AppRadius.pill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTypography.figtree(
                  size: 13.5,
                  weight: 700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
