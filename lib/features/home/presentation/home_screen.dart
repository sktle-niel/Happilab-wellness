import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/app_tab.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/product_share_grid.dart';
import '../../../shared/widgets/section_header.dart';
import 'widgets/affiliate_banner.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/points_card.dart';

/// The member's landing screen: what they have earned, and the products worth
/// sharing next.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Products the home preview puts forward. The full list lives on Products.
  static const int _featuredCount = 4;

  /// Page margin. The list itself runs edge to edge so the product carousel
  /// can bleed past it; everything else is inset by hand.
  static const double _inset = 20;

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

    return AppScaffold(
      child: ListView(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: FaithNavBar.contentInset,
        ),
        children: [
          _Inset(
            child: HomeTopBar(
              summary: summary,
              onNotifications: () =>
                  Navigator.of(context).pushNamed(AppRoutes.notifications),
            ),
          ),
          const Gap(AppSpacing.md),
          _Inset(
            child: PointsCard(
              summary: summary,
              onCashOut: () =>
                  Navigator.of(context).pushNamed(AppRoutes.rewards),
              onShareCode: () =>
                  _open(context, AppTab.refer, AppRoutes.myReferrals),
            ),
          ),
          const Gap(AppSpacing.lg),
          _Inset(
            child: SectionHeader(
              title: 'Products to share',
              actionLabel: 'See all',
              onAction: () =>
                  _open(context, AppTab.products, AppRoutes.suggestions),
            ),
          ),
          const Gap(12),
          ProductShareCarousel(
            products: featured,
            referralCode: summary.referralCode,
            edgeInset: _inset,
          ),
          const Gap(AppSpacing.lg),
          _Inset(
            child: AffiliateBanner(
              onHowItWorks: () =>
                  Navigator.of(context).pushNamed(AppRoutes.howItWorks),
            ),
          ),
        ],
      ),
    );
  }
}

class _Inset extends StatelessWidget {
  const _Inset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: HomeScreen._inset),
    child: child,
  );
}
