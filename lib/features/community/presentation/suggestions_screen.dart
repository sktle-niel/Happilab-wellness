import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/domain/program_terms.dart';
import '../../../shared/utils/share_actions.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/product_share_tile.dart';
import '../../../shared/widgets/screen_header.dart';

/// The full catalogue, framed as what to send a friend next.
class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = MemberSummary.placeholder;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeader(title: 'Products to share'),
                    const Gap(14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        'Suggested for your friends — you earn '
                        '${ProgramTerms.earnRate} on each sale.',
                        style: AppTypography.figtree(
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverGrid.builder(
                itemCount: Product.showcase.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // Taller than the home grid: this tile also carries the
                  // product description.
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final product = Product.showcase[index];
                  return ProductShareTile(
                    product: product,
                    showDescription: true,
                    onShare: () => ShareActions.copy(
                      context,
                      ShareActions.productMessage(
                        product,
                        summary.referralCode,
                      ),
                      confirmation: 'Message for ${product.name} copied.',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
