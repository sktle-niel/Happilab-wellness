import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const ScreenHeader(title: 'Terms & privacy'),
          const Gap(14),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: DividedColumn(
              children: [
                for (final section in SupportContent.terms)
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
        ],
      ),
    ),
  );
}
