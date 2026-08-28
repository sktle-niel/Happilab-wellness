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

  /// Someone who has bought is worth more than someone who has only signed up,
  /// and the badge says so at a glance.
  (Color, Color) _stageColors(AppPalette palette) => switch (referral.stage) {
    ReferralStage.repeat => (palette.accent, palette.onAccent),
    ReferralStage.purchased => (palette.tint, palette.accentText),
    ReferralStage.joined => (palette.divider, palette.textMuted),
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _stageColors(context.palette);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          AvatarCircle(name: referral.name, imageUrl: referral.avatarUrl),
          const Gap(12),
          Expanded(
            child: Column(
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
            ),
          ),
          const Gap(10),
          Column(
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
                referral.pointsEarned == 0
                    ? '—'
                    : NumberFormat.points(referral.pointsEarned),
                style: AppTypography.figtree(
                  size: 14,
                  weight: 800,
                  color: referral.pointsEarned == 0
                      ? context.palette.textFaint
                      : context.palette.accentText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
