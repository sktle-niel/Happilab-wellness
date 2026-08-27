import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/activity_entry.dart';
import '../domain/member_summary.dart';
import 'widgets/activity_card.dart';
import 'widgets/affiliate_banner.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/points_card.dart';
import 'widgets/referral_code_card.dart';
import 'widgets/share_product_tile.dart';

/// The member's landing screen: what they have earned, their code, and the
/// products worth sharing next.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Products the home grid puts forward. The full list lives on Suggestions.
  static const int _featuredCount = 4;

  @override
  Widget build(BuildContext context) {
    const summary = MemberSummary.placeholder;
    final featured = Product.showcase.take(_featuredCount).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
                  Navigator.of(context).pushNamed(AppRoutes.rewards),
              onShareCode: () =>
                  Navigator.of(context).pushNamed(AppRoutes.myReferrals),
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

  /// Sharing is a clipboard copy until a share sheet is wired up; the message
  /// is the one thing a member would actually send.
  Future<void> _share(BuildContext context, Product product) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(
        text:
            'Try ${product.name} from Faith Wellness — ${product.price}. '
            'Use my code $code.',
      ),
    );
    messenger.showSnackBar(
      SnackBar(content: Text('Message for ${product.name} copied.')),
    );
  }

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: products.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      // Tall enough for a two-line name above the price row.
      childAspectRatio: 0.72,
    ),
    itemBuilder: (context, index) {
      final product = products[index];
      return ShareProductTile(
        product: product,
        onShare: () => _share(context, product),
      );
    },
  );
}
