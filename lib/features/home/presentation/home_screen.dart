import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/app_tab.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/domain/activity_entry.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/utils/share_actions.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/product_share_tile.dart';
import '../../../shared/widgets/section_header.dart';
import 'widgets/activity_card.dart';
import 'widgets/affiliate_banner.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/points_card.dart';
import 'widgets/referral_code_card.dart';

/// The member's landing screen: what they have earned, their code, and the
/// products worth sharing next.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Products the home grid puts forward. The full list lives on Suggestions.
  static const int _featuredCount = 4;

  /// Switches tabs when home is inside the shell, and pushes the screen when
  /// it is not — the same tap should not stack a second copy of a destination.
  static void _open(BuildContext context, AppTab tab, String route) {
    if (AppShellScope.open(context, tab)) return;
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    const summary = MemberSummary.placeholder;
    final featured = Product.showcase.take(_featuredCount).toList();

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
            HomeTopBar(
              summary: summary,
              onNotifications: () =>
                  Navigator.of(context).pushNamed(AppRoutes.notifications),
            ),
            const Gap(AppSpacing.md),
            PointsCard(
              summary: summary,
              onCashOut: () =>
                  _open(context, AppTab.rewards, AppRoutes.rewards),
              onShareCode: () =>
                  _open(context, AppTab.refer, AppRoutes.myReferrals),
            ),
            const Gap(AppSpacing.md),
            ReferralCodeCard(code: summary.referralCode),
            const Gap(AppSpacing.md),
            AffiliateBanner(
              onHowItWorks: () =>
                  Navigator.of(context).pushNamed(AppRoutes.howItWorks),
            ),
            const Gap(AppSpacing.md),
            SectionHeader(
              title: 'Products to share',
              actionLabel: 'See all',
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.suggestions),
            ),
            const Gap(12),
            _ProductGrid(products: featured, code: summary.referralCode),
            const Gap(AppSpacing.md),
            const SectionHeader(title: 'Recent activity'),
            const Gap(AppSpacing.sm),
            const ActivityCard(entries: ActivityEntry.placeholder),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.code});

  final List<Product> products;
  final String code;

  Future<void> _share(BuildContext context, Product product) =>
      ShareActions.copy(
        context,
        ShareActions.productMessage(product, code),
        confirmation: 'Message for ${product.name} copied.',
      );

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: products.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      // Extra vertical room: the share button overhangs the card's bottom
      // corner, and would otherwise sit on the row below.
      mainAxisSpacing: 20,
      crossAxisSpacing: 12,
      // A square photo plus the name and the money underneath it.
      // A square photo plus two lines of name and the money under it. The
      // smaller share button freed the width that was forcing a third line.
      childAspectRatio: 0.68,
    ),
    itemBuilder: (context, index) {
      final product = products[index];
      return ProductShareTile(
        product: product,
        onShare: () => _share(context, product),
      );
    },
  );
}
