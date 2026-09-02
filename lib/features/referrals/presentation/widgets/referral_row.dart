import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../shared/utils/number_format.dart';
import '../../../../shared/widgets/avatar_circle.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../domain/referral.dart';
import '../../../../app/theme/app_palette.dart';

/// One referred person: who they are, where they got to, what they earned.
class ReferralRow extends StatelessWidget {
  const ReferralRow({required this.referral, super.key});

  final Referral referral;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        AvatarCircle(name: referral.name, imageUrl: referral.avatarUrl),
        const Gap(12),
        Expanded(child: _Identity(referral: referral)),
        const Gap(10),
        _StageAndEarnings(referral: referral),
      ],
    ),
  );
}

/// Who they are and when they joined.
class _Identity extends StatelessWidget {
  const _Identity({required this.referral});

  final Referral referral;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        referral.name,
        style: AppTypography.figtree(size: 15, weight: 700),
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        referral.when,
        style: AppTypography.figtree(
          size: 12,
          color: context.palette.textFaint,
        ),
      ),
    ],
  );
}

/// How far they got, and what that was worth.
class _StageAndEarnings extends StatelessWidget {
  const _StageAndEarnings({required this.referral});

  final Referral referral;

  /// Someone who has bought is worth more than someone who has only signed up,
  /// and the badge says so at a glance.
  (Color, Color) _stageColors(AppPalette palette) => switch (referral.stage) {
    ReferralStage.repeat => (palette.accent, palette.onAccent),
    ReferralStage.purchased => (palette.tint, palette.accentText),
    ReferralStage.joined => (palette.divider, palette.textMuted),
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, foreground) = _stageColors(palette);
    final hasEarned = referral.pointsEarned > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusPill(
          label: referral.stage.label,
          background: background,
          foreground: foreground,
        ),
        const Gap(3),
        Text(
          hasEarned ? NumberFormat.points(referral.pointsEarned) : '—',
          style: AppTypography.figtree(
            size: 14,
            weight: 800,
            color: hasEarned ? palette.accentText : palette.textFaint,
          ),
        ),
      ],
    );
  }
}
