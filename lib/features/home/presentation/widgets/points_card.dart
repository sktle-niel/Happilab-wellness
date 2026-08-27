import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/member_summary.dart';
import '../../../../shared/widgets/faith_mascot.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/pressable_scale.dart';

/// The gold hero card: what the member has earned, and the two things they can
/// do about it.
class PointsCard extends StatelessWidget {
  const PointsCard({
    required this.summary,
    required this.onCashOut,
    required this.onShareCode,
    super.key,
  });

  static const String mascotMessage = 'Keep sharing!';

  final MemberSummary summary;
  final VoidCallback onCashOut;
  final VoidCallback onShareCode;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: const BoxDecoration(
      color: AppColors.accent,
      borderRadius: AppRadius.hero,
      boxShadow: AppShadows.soft,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Balance(summary: summary)),
            const Gap.sm(),
            const _MascotAside(),
          ],
        ),
        const Gap(18),
        Row(
          children: [
            Expanded(
              child: _CardAction(
                label: 'Cash out',
                onPressed: onCashOut,
                background: AppColors.surface,
                foreground: AppColors.accentText,
              ),
            ),
            const Gap.sm(),
            Expanded(
              child: _CardAction(
                label: 'Share code',
                onPressed: onShareCode,
                background: Colors.white.withValues(alpha: 0.22),
                foreground: AppColors.surface,
                outlined: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Balance extends StatelessWidget {
  const _Balance({required this.summary});

  final MemberSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'YOUR POINTS',
        style: AppTypography.figtree(
          size: 11.5,
          weight: 700,
          letterSpacing: 0.92,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
      const Gap(3),
      Text.rich(
        TextSpan(
          text: summary.pointsFormatted,
          style: AppTypography.figtree(
            size: 27,
            weight: 800,
            height: 1.15,
            letterSpacing: -0.54,
            color: AppColors.surface,
          ),
          children: [
            TextSpan(
              text: '  pts',
              style: AppTypography.figtree(
                size: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      const Gap(2),
      Text(
        '= ${summary.pesoValue}',
        style: AppTypography.figtree(
          size: 13,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    ],
  );
}

/// The mascot and its speech bubble, which is what stops the balance card from
/// reading like a bank statement.
class _MascotAside extends StatelessWidget {
  const _MascotAside();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 2),
        child: _SpeechBubble(message: PointsCard.mascotMessage),
      ),
      const Gap(6),
      SizedBox(
        width: 72,
        height: 70,
        child: FittedBox(fit: BoxFit.contain, child: const FaithMascot()),
      ),
    ],
  );
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
        bottomLeft: Radius.circular(14),
        bottomRight: Radius.circular(4),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: AppTypography.figtree(
            size: 12,
            weight: 800,
            color: AppColors.accentText,
          ),
        ),
        const SizedBox(width: 2),
        const _BlinkingCaret(),
      ],
    ),
  );
}

/// The typing caret from the design — a small sign of life on a static card.
class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret();

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _blink,
    builder: (context, child) =>
        Opacity(opacity: _blink.value < 0.5 ? 1 : 0, child: child),
    child: const SizedBox(
      width: 2,
      height: 11,
      child: ColoredBox(color: AppColors.accentText),
    ),
  );
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: PressableScale(
      scale: 0.96,
      onPressed: onPressed,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pill,
          border: outlined
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                )
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.figtree(
            size: 15,
            weight: 700,
            color: foreground,
          ),
        ),
      ),
    ),
  );
}
