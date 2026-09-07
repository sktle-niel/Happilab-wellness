import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'gap.dart';
import 'pressable_scale.dart';
import '../../app/theme/app_palette.dart';

enum AppButtonVariant {
  /// Gold pill — the single primary action on a screen.
  primary,

  /// Glass pill on the page — the second action on a screen.
  secondary,

  /// Surface pill drawn with a hairline instead of a shadow — for a surface
  /// that already carries one, like a sheet.
  outlined,
}

/// The app's button. Screens use this instead of raw Material buttons so
/// sizing, press feedback, loading behaviour and disabled state stay identical
/// everywhere.
///
/// While [isLoading] is true the button is inert — the single most common source
/// of duplicate submissions is a button that stays tappable.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.leading,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  const AppButton.secondary({
    required this.label,
    this.onPressed,
    this.icon,
    this.leading,
    this.isLoading = false,
    super.key,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    required this.label,
    this.onPressed,
    this.icon,
    this.leading,
    this.isLoading = false,
    super.key,
  }) : variant = AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Arbitrary leading widget — used for multi-colour provider marks that an
  /// [IconData] cannot express.
  final Widget? leading;
  final bool isLoading;
  final AppButtonVariant variant;

  bool get _isPrimary => variant == AppButtonVariant.primary;

  BoxDecoration _decorationFor(AppPalette palette) => BoxDecoration(
    color: switch (variant) {
      AppButtonVariant.primary => palette.accent,
      AppButtonVariant.secondary => palette.glass,
      AppButtonVariant.outlined => palette.surface,
    },
    borderRadius: AppRadius.pill,
    boxShadow: switch (variant) {
      AppButtonVariant.secondary => palette.shadowRaised,
      AppButtonVariant.primary || AppButtonVariant.outlined => null,
    },
    border: switch (variant) {
      AppButtonVariant.primary => null,
      AppButtonVariant.secondary => Border.all(color: palette.glassEdge),
      AppButtonVariant.outlined => Border.all(
        color: palette.divider,
        width: 1.5,
      ),
    },
  );

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final foreground = _isPrimary
        ? context.palette.onAccent
        : context.palette.textPrimary;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: PressableScale(
        onPressed: isEnabled ? onPressed : null,
        child: Opacity(
          opacity: isEnabled ? 1 : 0.55,
          child: Container(
            height: AppSpacing.buttonHeight,
            alignment: Alignment.center,
            decoration: _decorationFor(context.palette),
            child: isLoading
                ? _ButtonProgress(color: foreground)
                : _ButtonContent(
                    label: label,
                    icon: icon,
                    leading: leading,
                    style: _isPrimary
                        ? AppTypography.buttonPrimary(context.palette)
                        : AppTypography.buttonSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.style,
    this.icon,
    this.leading,
  });

  final String label;
  final TextStyle style;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (leading != null) ...[leading!, const Gap.sm()],
      if (leading == null && icon != null) ...[
        Icon(icon, size: 19, color: style.color),
        const Gap.sm(),
      ],
      Flexible(
        child: Text(label, style: style, overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: color),
  );
}
