import 'package:flutter/material.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/icon_pill_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/support_content.dart';
import 'widgets/prose_block.dart';
import '../../../app/theme/app_palette.dart';

/// Answers to what members ask most, and a way to reach a person.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: AppSpacing.pageInset,
      children: [
        const ScreenHeader(title: 'Help center'),
        const Gap(14),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: DividedColumn(
            children: [
              for (final faq in SupportContent.faqs)
                ProseBlock(heading: faq.question, body: faq.answer),
            ],
          ),
        ),
        const Gap(14),
        const _ContactCard(),
      ],
    ),
  );
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        Text(
          'Still need help?',
          style: AppTypography.figtree(size: 14.5, weight: 800),
        ),
        const Gap(4),
        Text(
          'Our team replies within 24 hours.',
          style: AppTypography.figtree(
            size: 13,
            color: context.palette.textMuted,
          ),
        ),
        const Gap(12),
        IconPillButton(
          label: 'Chat with support',
          icon: Icons.chat_bubble_outline_rounded,
          background: context.palette.accent,
          foreground: context.palette.onAccent,
          onPressed: () => AppToast.info(
            context,
            'Support chat is not connected yet',
            detail: 'Email us in the meantime and we will pick it up there.',
          ),
        ),
      ],
    ),
  );
}
