import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';

import 'package:flutter/services.dart';

import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/utils/share_actions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/referral.dart';
import 'widgets/referral_row.dart';
import '../../../app/theme/app_palette.dart';

/// The member's code and everyone who has used it.
class MyReferralsScreen extends StatelessWidget {
  const MyReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = MemberSummary.placeholder;

    return AppScaffold(
      child: ListView(
        padding: FaithNavBar.pageInset,
        children: [
          ScreenHeader(
            showBack: !AppShellScope.contains(context),
            title: 'My referrals',
          ),
          const Gap(AppSpacing.md),
          _CodeCard(code: summary.referralCode),
          const Gap(14),
          _ReferralSummary(text: summary.referralSummary),
          const Gap(AppSpacing.sm),
          AppCard.flush(
            child: DividedColumn(
              children: [
                for (final referral in Referral.placeholder)
                  ReferralRow(referral: referral),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The headline count, marked with the people it counts.
class _ReferralSummary extends StatelessWidget {
  const _ReferralSummary({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Row(
      children: [
        Icon(Icons.group_outlined, size: 18, color: context.palette.accentText),
        const Gap.sm(),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: AppTypography.figtree(
              size: 12.5,
              weight: 800,
              letterSpacing: 0.6,
              color: context.palette.textMuted,
            ),
          ),
        ),
      ],
    ),
  );
}

/// The code, with the two ways a member passes it on.
class _CodeCard extends StatefulWidget {
  const _CodeCard({required this.code});

  final String code;

  @override
  State<_CodeCard> createState() => _CodeCardState();
}

class _CodeCardState extends State<_CodeCard> {
  bool _hasCopied = false;

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _hasCopied = true);
  }

  Future<void> _shareInvite() => ShareActions.copy(
    context,
    ShareActions.inviteMessage(widget.code),
    confirmation: 'Invite message copied.',
  );

  @override
  Widget build(BuildContext context) => AppCard(
    borderRadius: AppRadius.hero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'YOUR CODE',
                    style: AppTypography.figtree(
                      size: 11.5,
                      weight: 700,
                      letterSpacing: 0.69,
                      color: context.palette.textMuted,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    widget.code,
                    style: AppTypography.figtree(
                      size: 26,
                      weight: 800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            const _GiftBadge(),
          ],
        ),
        const Gap(14),
        Row(
          children: [
            Expanded(
              child: _CodeAction(
                label: _hasCopied ? 'Copied' : 'Copy code',
                icon: _hasCopied ? Icons.check_rounded : Icons.copy_rounded,
                onPressed: _copyCode,
                background: context.palette.accent,
                foreground: context.palette.onAccent,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _CodeAction(
                label: 'Share',
                icon: Icons.share_outlined,
                onPressed: _shareInvite,
                background: context.palette.tint,
                foreground: context.palette.accentText,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// The gift in the corner of the code card — what a shared code is.
class _GiftBadge extends StatelessWidget {
  const _GiftBadge();

  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: context.palette.tint,
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.card_giftcard_rounded,
      size: 26,
      color: context.palette.accent,
    ),
  );
}

class _CodeAction extends StatelessWidget {
  const _CodeAction({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foreground),
              const Gap(6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.figtree(
                  size: 14.5,
                  weight: 700,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
