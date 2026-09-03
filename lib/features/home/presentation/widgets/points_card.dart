import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/member_summary.dart';
import '../../../../shared/widgets/circle_badge.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/pressable_scale.dart';

/// The accent hero card, cut like a ticket: the balance on the left, the two
/// things the member can do about it as round buttons on the right.
///
/// It sits at a slight tilt — a ticket is something you are handed, not a
/// panel in a form.
class PointsCard extends StatelessWidget {
  const PointsCard({
    required this.summary,
    required this.onCashOut,
    required this.onShareCode,
    super.key,
  });

  static const double _tiltDegrees = -2.5;

  final MemberSummary summary;
  final VoidCallback onCashOut;
  final VoidCallback onShareCode;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: _tiltDegrees * math.pi / 180,
    child: PhysicalShape(
      clipper: const _TicketClipper(),
      color: context.palette.accent,
      elevation: 8,
      shadowColor: context.palette.shadow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 20, 22, 18),
        child: Row(
          children: [
            Expanded(child: _Balance(summary: summary)),
            const Gap(12),
            _RoundAction(
              label: 'Cash out',
              icon: Icons.account_balance_wallet_outlined,
              onPressed: onCashOut,
            ),
            const Gap(10),
            _RoundAction(
              label: 'Share code',
              icon: Icons.share_outlined,
              onPressed: onShareCode,
            ),
          ],
        ),
      ),
    ),
  );
}

/// A rounded card with a semicircle bitten out of each side at mid-height —
/// the tear notches that make it read as a ticket.
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  static const double _cornerRadius = 22;
  static const double _notchRadius = 12;

  @override
  Path getClip(Size size) {
    final card = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_cornerRadius),
        ),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(0, size.height / 2),
          radius: _notchRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, size.height / 2),
          radius: _notchRadius,
        ),
      );
    return Path.combine(PathOperation.difference, card, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}

class _Balance extends StatelessWidget {
  const _Balance({required this.summary});

  final MemberSummary summary;

  @override
  Widget build(BuildContext context) {
    final ink = context.palette.onAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'YOUR POINTS',
          style: AppTypography.figtree(
            size: 11,
            weight: 700,
            letterSpacing: 1.1,
            color: ink.withValues(alpha: 0.75),
          ),
        ),
        const Gap(6),
        Text(
          '${summary.pointsFormatted} POINTS',
          style: AppTypography.figtree(
            size: 26,
            weight: 800,
            height: 1.1,
            letterSpacing: -0.5,
            color: ink,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(4),
        Text(
          '= ${summary.pesoValue}',
          style: AppTypography.figtree(
            size: 13,
            weight: 700,
            color: ink.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

/// A disc with its name beneath — the action reads at a glance and the label
/// keeps it honest.
class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  static const double _size = 48;

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: label,
      child: PressableScale(
        scale: 0.94,
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleBadge(
              size: _size,
              color: palette.surface,
              child: Icon(icon, size: 21, color: palette.accentText),
            ),
            const Gap(6),
            Text(
              label,
              style: AppTypography.figtree(
                size: 11.5,
                weight: 700,
                color: palette.onAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
