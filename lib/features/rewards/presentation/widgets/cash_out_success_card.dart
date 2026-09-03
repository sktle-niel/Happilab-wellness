import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/circle_badge.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/icon_pill_button.dart';
import '../../domain/cash_out.dart';
import '../../../../app/theme/app_palette.dart';

/// Confirmation that the request went out.
///
/// It replaces the form rather than sitting above it: the member has nothing
/// left to fill in, and a stale form invites a second request.
class CashOutSuccessCard extends StatelessWidget {
  const CashOutSuccessCard({
    required this.message,
    required this.onDone,
    super.key,
  });

  final String message;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
    borderRadius: const BorderRadius.all(Radius.circular(28)),
    shadow: context.palette.shadowCard,
    child: Column(
      children: [
        CircleBadge(
          size: 72,
          color: context.palette.accent,
          child: Icon(
            Icons.check_rounded,
            size: 34,
            color: context.palette.onAccent,
          ),
        ),
        const Gap(12),
        Text(
          'Request sent!',
          style: AppTypography.figtree(size: 22, weight: 800),
        ),
        const Gap(4),
        Text(
          '$message ${CashOutTerms.arrivalNote}',
          textAlign: TextAlign.center,
          style: AppTypography.figtree(
            size: 14.5,
            height: 1.5,
            color: context.palette.textMuted,
          ),
        ),
        const Gap(18),
        IconPillButton(
          label: 'Done',
          icon: Icons.done_all_rounded,
          height: 48,
          foreground: context.palette.accentText,
          onPressed: onDone,
        ),
      ],
    ),
  );
}
