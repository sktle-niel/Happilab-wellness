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
import '../../../shared/widgets/circle_badge.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/icon_pill_button.dart';
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
        _CodeDisplay(code: widget.code),
        const Gap(14),
        _CodeActions(
          hasCopied: _hasCopied,
          onCopy: _copyCode,
          onShare: _shareInvite,
        ),
      ],
    ),
  );
}

/// The code itself, with the gift badge beside it.
class _CodeDisplay extends StatelessWidget {
  const _CodeDisplay({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) => Row(
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
              code,
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
  );
}

/// The two ways to pass the code on. Copy reports itself for a moment, so the
/// label it carries is state, not a constant.
class _CodeActions extends StatelessWidget {
  const _CodeActions({
    required this.hasCopied,
    required this.onCopy,
    required this.onShare,
  });

  static const double _height = 48;

  final bool hasCopied;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: IconPillButton(
          label: hasCopied ? 'Copied' : 'Copy code',
          icon: hasCopied ? Icons.check_rounded : Icons.copy_rounded,
          height: _height,
          onPressed: onCopy,
          background: context.palette.accent,
          foreground: context.palette.onAccent,
        ),
      ),
      const Gap(10),
      Expanded(
        child: IconPillButton(
          label: 'Share',
          icon: Icons.share_outlined,
          height: _height,
          onPressed: onShare,
          background: context.palette.tint,
          foreground: context.palette.accentText,
        ),
      ),
    ],
  );
}

/// The gift in the corner of the code card — what a shared code is.
class _GiftBadge extends StatelessWidget {
  const _GiftBadge();

  @override
  Widget build(BuildContext context) => CircleBadge(
    size: 56,
    child: Icon(
      Icons.card_giftcard_rounded,
      size: 26,
      color: context.palette.accent,
    ),
  );
}
