import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/icon_pill_button.dart';

/// The member's code, with the one action they take on it most.
class ReferralCodeCard extends StatefulWidget {
  const ReferralCodeCard({required this.code, super.key});

  final String code;

  @override
  State<ReferralCodeCard> createState() => _ReferralCodeCardState();
}

class _ReferralCodeCardState extends State<ReferralCodeCard> {
  bool _hasCopied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    // Confirming in place beats a snackbar the user has to look away for.
    setState(() => _hasCopied = true);
  }

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'YOUR REFERRAL CODE',
                style: AppTypography.figtree(
                  size: 11,
                  weight: 700,
                  letterSpacing: 0.66,
                  color: AppColors.textMuted,
                ),
              ),
              const Gap(2),
              Text(
                widget.code,
                style: AppTypography.figtree(
                  size: 17,
                  weight: 800,
                  letterSpacing: 0.51,
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        IconPillButton(
          label: _hasCopied ? 'Copied' : 'Copy link',
          icon: _hasCopied ? Icons.check_rounded : Icons.link_rounded,
          onPressed: _copy,
        ),
      ],
    ),
  );
}
