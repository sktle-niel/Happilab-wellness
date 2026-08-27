import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/password_policy.dart';

/// Live checklist under the password field.
///
/// Reads [PasswordRule] straight from the policy, so a rule added there shows up
/// here without touching this widget.
class PasswordRequirementChips extends StatelessWidget {
  const PasswordRequirementChips({required this.unmetRules, super.key});

  final Set<PasswordRule> unmetRules;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final rule in PasswordRule.values)
        _Chip(label: rule.label, isMet: !unmetRules.contains(rule)),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppDuration.fast,
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: isMet
          ? AppColors.accent.withValues(alpha: 0.16)
          : AppColors.surface,
      borderRadius: AppRadius.pill,
    ),
    child: Text(
      label,
      style: AppTypography.chip.copyWith(
        color: isMet ? AppColors.accentPressed : AppColors.textMuted,
      ),
    ),
  );
}
