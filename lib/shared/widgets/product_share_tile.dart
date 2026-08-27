import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../domain/catalogue.dart';
import 'app_card.dart';
import 'gap.dart';
import 'pressable_scale.dart';
import 'remote_image.dart';
import 'status_pill.dart';

/// One product in a two-column share grid — the home preview and the full
/// Suggestions list are the same tile.
///
/// [showDescription] is what separates them: the home grid is a glance, the
/// suggestions list is a decision.
class ProductShareTile extends StatelessWidget {
  const ProductShareTile({
    required this.product,
    required this.onShare,
    this.showDescription = false,
    super.key,
  });

  final Product product;
  final VoidCallback onShare;
  final bool showDescription;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Thumbnail(product: product),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                style: AppTypography.figtree(
                  size: 14.5,
                  weight: 800,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showDescription) ...[
                const Gap(2),
                Text(
                  product.blurb,
                  style: AppTypography.figtree(
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Gap.sm(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _PriceBlock(product: product)),
                  _ShareButton(onPressed: onShare),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      RemoteImage(
        url: product.imageUrl,
        height: 118,
        width: double.infinity,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      if (product.tag != null)
        Positioned(
          top: 8,
          left: 8,
          child: StatusPill(
            label: product.tag!,
            background: AppColors.accent,
            foreground: AppColors.surface,
          ),
        ),
    ],
  );
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(product.price, style: AppTypography.figtree(size: 15, weight: 800)),
      Text(
        product.earnShort,
        style: AppTypography.figtree(
          size: 11,
          weight: 800,
          color: AppColors.accentText,
        ),
      ),
    ],
  );
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Share',
    child: PressableScale(
      scale: 0.9,
      onPressed: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.cream,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.share_outlined,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
    ),
  );
}
