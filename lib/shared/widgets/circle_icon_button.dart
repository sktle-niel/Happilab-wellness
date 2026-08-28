import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'pressable_scale.dart';
import '../../app/theme/app_palette.dart';

/// White circular icon button — the back affordance and the notification bell
/// in the design share this shape.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.color,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  /// Defaults to the palette's primary text colour.
  final Color? color;

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
        decoration: BoxDecoration(
          color: context.palette.surface,
          shape: BoxShape.circle,
          boxShadow: context.palette.shadowInput,
        ),
        child: Icon(
          icon,
          size: 20,
          color: color ?? context.palette.textPrimary,
        ),
      ),
    ),
  );
}
