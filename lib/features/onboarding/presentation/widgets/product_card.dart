import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/catalogue.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/remote_image.dart';

/// One product in the intro showcase.
///
/// The cards rest at a slight tilt in the design, which is what stops the stack
/// from reading as a plain list.
class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, this.tiltDegrees = 0, super.key});

  final Product product;
  final double tiltDegrees;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: tiltDegrees * 3.1415926535 / 180,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(child: _ProductDetails(product: product)),
          const Gap(14),
          RemoteImage(
            url: product.imageUrl,
            width: 84,
            height: 88,
            borderRadius: AppRadius.input,
          ),
        ],
      ),
    ),
  );
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        product.name,
        style: AppTypography.figtree(
          size: 18,
          weight: 800,
          height: 1.15,
          letterSpacing: -0.18,
        ),
      ),
      const Gap(4),
      Text(
        product.blurb,
        style: AppTypography.figtree(size: 12.5, color: AppColors.textMuted),
      ),
      const Gap(4),
      Text(
        product.earnLine,
        style: AppTypography.figtree(
          size: 12.5,
          weight: 800,
          color: AppColors.accentText,
        ),
      ),
    ],
  );
}
