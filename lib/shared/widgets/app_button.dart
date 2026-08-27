import 'package:flutter/material.dart';

import 'gap.dart';

enum AppButtonVariant { primary, secondary }

/// The app's button. Screens use this instead of raw Material buttons so
/// sizing, loading behaviour and disabled state stay identical everywhere.
///
/// While [isLoading] is true the button is inert — the single most common
/// source of duplicate submissions is a button that stays tappable.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  const AppButton.secondary({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;
    final child = isLoading
        ? const _ButtonProgress()
        : _ButtonContent(label: label, icon: icon);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        child: child,
      ),
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[Icon(icon, size: 20), const Gap.sm()],
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
    ],
  );
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
