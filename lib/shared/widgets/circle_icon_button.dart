import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import 'pressable_scale.dart';

/// White circular icon button — the back affordance and the notification bell
/// in the design share this shape.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.color = AppColors.textPrimary,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: PressableScale(
      scale: 0.94,
      onPressed: onPressed,
      child: Container(
        width: AppSpacing.iconButtonSize,
        height: AppSpacing.iconButtonSize,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.input,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    ),
  );
}
