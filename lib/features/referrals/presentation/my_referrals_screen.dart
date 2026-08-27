import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_colors.dart';
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

/// The member's code and everyone who has used it.
class MyReferralsScreen extends StatelessWidget {
  const MyReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = MemberSummary.placeholder;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            FaithNavBar.contentInset,
          ),
          children: [
            ScreenHeader(
              showBack: !AppShellScope.contains(context),
              title: 'My referrals',
            ),
            const Gap(AppSpacing.md),
            _CodeCard(code: summary.referralCode),
            const Gap(14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                summary.referralSummary.toUpperCase(),
                style: AppTypography.figtree(
                  size: 13,
                  weight: 800,
                  letterSpacing: 0.65,
                  color: AppColors.textMuted,
                ),
              ),
            ),
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
      ),
    );
  }
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
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'YOUR CODE',
              style: AppTypography.figtree(
                size: 11.5,
                weight: 700,
                letterSpacing: 0.69,
                color: AppColors.textMuted,
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                widget.code,
                style: AppTypography.figtree(
                  size: 22,
                  weight: 800,
                  letterSpacing: 0.66,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _CodeAction(
                label: _hasCopied ? 'Copied' : 'Copy code',
                onPressed: _copyCode,
                background: AppColors.accent,
                foreground: AppColors.surface,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _CodeAction(
                label: 'Share',
                icon: Icons.share_outlined,
                onPressed: _shareInvite,
                background: AppColors.cream,
                foreground: AppColors.accentText,
              ),
            ),
          ],
        ),
      ],
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
              const Gap.sm(),
            ],
            Text(
              label,
              style: AppTypography.figtree(
                size: 15,
                weight: 700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
