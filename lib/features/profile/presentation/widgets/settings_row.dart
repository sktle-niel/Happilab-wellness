import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Rows of the settings list.
///
/// Three shapes over one layout: a toggle, a read-only value, and a link
/// onward. Sharing the frame is what makes the list read as a list.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => _SettingsRow(
    label: label,
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.accent,
    ),
  );
}

class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => _SettingsRow(
    label: label,
    trailing: Text(
      value,
      style: AppTypography.figtree(size: 13.5, color: AppColors.textMuted),
    ),
  );
}

class SettingsLinkRow extends StatelessWidget {
  const SettingsLinkRow({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: _SettingsRow(
        label: label,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppColors.textFaint,
        ),
      ),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.figtree(size: 15, weight: 700),
            ),
          ),
          trailing,
        ],
      ),
    ),
  );
}
