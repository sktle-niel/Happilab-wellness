import 'package:flutter/material.dart';

import '../../../shared/widgets/card_skeleton.dart';
import '../../../shared/widgets/repository_view.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/support_content.dart';
import 'widgets/prose_block.dart';
import '../../../app/theme/app_palette.dart';

/// The agreement, in the plainest wording the design allows.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: AppSpacing.pageInset,
      children: [
        const ScreenHeader(title: 'Terms & privacy'),
        const Gap(14),
        RepositoryView<List<TermsSection>>(
          read: (repositories) => repositories.support.terms(),
          skeleton: const CardSkeleton(lines: 6),
          builder: (context, sections) => AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: DividedColumn(
              children: [
                for (final section in sections)
                  ProseBlock(heading: section.heading, body: section.body),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    SupportContent.lastUpdated,
                    style: AppTypography.figtree(
                      size: 12,
                      color: context.palette.textFaint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
