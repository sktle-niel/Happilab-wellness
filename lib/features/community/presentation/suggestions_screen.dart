import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/domain/program_terms.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/product_share_grid.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../app/theme/app_palette.dart';

/// The full catalogue, framed as what to send a friend next.
class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = MemberSummary.placeholder;

    return AppScaffold(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeader(
                    title: 'Products to share',
                    showBack: !AppShellScope.contains(context),
                  ),
                  const Gap(14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      'Suggested for your friends — you earn '
                      '${ProgramTerms.earnRate} on each sale.',
                      style: AppTypography.figtree(
                        size: 14,
                        color: context.palette.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              FaithNavBar.contentInset,
            ),
            sliver: SliverToBoxAdapter(
              child: ProductShareGrid(
                products: Product.showcase,
                referralCode: summary.referralCode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
