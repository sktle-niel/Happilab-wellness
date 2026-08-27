import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../domain/catalogue.dart';
import 'pressable_scale.dart';
import 'remote_image.dart';
import 'status_pill.dart';

/// A product card: inset photo with its badge, then the name, the money, and
/// the one action — share.
///
/// The share button sits in the bottom-right corner with a ring of page colour
/// around it, so it reads as sitting on the card rather than inside it.
/// [showDescription] is what separates the two grids that use this: the home
/// preview is a glance, the suggestions list is a decision.
class ProductShareTile extends StatelessWidget {
  const ProductShareTile({
    required this.product,
    required this.onShare,
    this.showDescription = false,
    super.key,
  });

  static const double _cardRadius = 28;
  static const double _imageRadius = 20;
  static const double _inset = 12;

  final Product product;
  final VoidCallback onShare;
  final bool showDescription;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        padding: const EdgeInsets.all(_inset),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Photo(product: product),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
              child: _Details(
                product: product,
                showDescription: showDescription,
              ),
            ),
          ],
        ),
      ),
      Positioned(
        right: -2,
        bottom: -2,
        child: _ShareButton(onPressed: onShare, label: product.name),
      ),
    ],
  );
}

class _Photo extends StatelessWidget {
  const _Photo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: Stack(
      children: [
        Positioned.fill(
          child: RemoteImage(
            url: product.imageUrl,
            width: double.infinity,
            height: double.infinity,
            borderRadius: const BorderRadius.all(
              Radius.circular(ProductShareTile._imageRadius),
            ),
          ),
        ),
        if (product.tag != null)
          Positioned(
            top: 10,
            left: 10,
            child: StatusPill(
              label: product.tag!,
              background: AppColors.accent,
              foreground: AppColors.surface,
            ),
          ),
      ],
    ),
  );
}

class _Details extends StatelessWidget {
  const _Details({required this.product, required this.showDescription});

  final Product product;
  final bool showDescription;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        product.name,
        style: AppTypography.figtree(size: 17, weight: 800, height: 1.2),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      if (showDescription) ...[
        const SizedBox(height: 6),
        Text(
          product.blurb,
          style: AppTypography.figtree(
            size: 13,
            height: 1.45,
            color: AppColors.textMuted,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      const SizedBox(height: 10),
      // The share button overhangs this corner, so the money keeps clear of it.
      Padding(
        padding: const EdgeInsets.only(right: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.price,
              style: AppTypography.figtree(size: 18, weight: 800),
            ),
            Text(
              product.earnShort,
              style: AppTypography.figtree(
                size: 12,
                weight: 800,
                color: AppColors.accentText,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

/// The corner action. The ring is painted in the page colour so the button
/// looks notched into the card, as the reference layout does.
class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Share $label',
    child: PressableScale(
      scale: 0.9,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(19)),
            boxShadow: AppShadows.input,
          ),
          child: const Icon(
            Icons.share_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ),
  );
}
