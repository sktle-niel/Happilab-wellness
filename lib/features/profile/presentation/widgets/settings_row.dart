import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../app/theme/app_palette.dart';

/// Rows of the settings list.
///
/// Three shapes over one layout — an icon, a label, then a toggle, a read-only
/// value, or an arrow onward. Sharing the frame is what makes the list read as
/// a list.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => _SettingsRow(
    icon: icon,
    label: label,
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: context.palette.accent,
    ),
  );
}

class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => _SettingsRow(
    icon: icon,
    label: label,
    trailing: Text(
      value,
      style: AppTypography.figtree(
        size: 13.5,
        color: context.palette.textMuted,
      ),
    ),
  );
}

class SettingsLinkRow extends StatelessWidget {
  const SettingsLinkRow({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: _SettingsRow(
        icon: icon,
        label: label,
        trailing: const _ArrowBadge(),
      ),
    ),
  );
}

/// The small tinted disc a row's icon sits in. Public so the profile's
/// highlight card can open with the same mark as the rows beneath it.
class SettingsIcon extends StatelessWidget {
  const SettingsIcon({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: context.palette.tint,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 17, color: context.palette.accentDeep),
  );
}

class _ArrowBadge extends StatelessWidget {
  const _ArrowBadge();

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: context.palette.canvas,
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.arrow_forward_rounded,
      size: 14,
      color: context.palette.textPrimary,
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          SettingsIcon(icon: icon),
          const Gap(12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.figtree(size: 14.5, weight: 700),
            ),
          ),
          trailing,
        ],
      ),
    ),
  );
}
