import 'package:flutter/material.dart';

import 'app_card.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../domain/catalogue.dart';
import 'circle_badge.dart';
import 'pressable_scale.dart';
import 'remote_image.dart';
import 'status_pill.dart';
import '../../app/theme/app_palette.dart';

/// A product card for the two-column grids: inset photo with its badge, the
/// name, two lines of blurb, the money with share beside it, then the one
/// button that gets the product.
///
/// The column spreads its ends apart, so when a grid row stretches the card to
/// match its neighbour the money stays on the bottom edge instead of floating.
class ProductShareTile extends StatelessWidget {
  const ProductShareTile({
    required this.product,
    required this.onShare,
    required this.onGet,
    super.key,
  });

  static const double _inset = 10;

  final Product product;
  final VoidCallback onShare;

  /// Opens the checkout for this product.
  final VoidCallback onGet;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(_inset),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Photo(product: product),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
          child: _Details(product: product, onShare: onShare, onGet: onGet),
        ),
      ],
    ),
  );
}

class _Photo extends StatelessWidget {
  const _Photo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final badge = product.badge;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: RemoteImage(
              url: product.imageUrl,
              width: double.infinity,
              height: double.infinity,
              borderRadius: AppRadius.input,
            ),
          ),
          if (badge != null)
            Positioned(top: 10, left: 10, child: _Badge(badge: badge)),
        ],
      ),
    );
  }
}

/// Each badge has its own colour in the design; the mapping lives here rather
/// than in the catalogue because it is presentation, not product data.
class _Badge extends StatelessWidget {
  const _Badge({required this.badge});

  final ProductBadge badge;

  (Color, Color) _colors(AppPalette palette) => switch (badge) {
    ProductBadge.topSale => (palette.accent, palette.onAccent),
    ProductBadge.newArrival => (palette.danger, Colors.white),
    ProductBadge.comingSoon => (palette.textPrimary, palette.canvas),
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors(context.palette);

    return StatusPill(
      label: badge.label,
      background: background,
      foreground: foreground,
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.product,
    required this.onShare,
    required this.onGet,
  });

  final Product product;
  final VoidCallback onShare;
  final VoidCallback onGet;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        product.name,
        style: AppTypography.figtree(size: 15, weight: 800, height: 1.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 3),
      Text(
        product.blurb,
        style: AppTypography.figtree(
          size: 12.5,
          height: 1.35,
          color: context.palette.textMuted,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _Money(product: product)),
          _ShareButton(onPressed: onShare, label: product.name),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      _GetButton(onPressed: onGet, label: product.name),
    ],
  );
}

class _Money extends StatelessWidget {
  const _Money({required this.product});

  final Product product;

  /// One line each: the card's height is fixed by the grid, so a wrapped
  /// money line would push the row out of the card at a large font size.
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        product.price,
        style: AppTypography.figtree(size: 17, weight: 800),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        product.earnShort,
        style: AppTypography.figtree(
          size: 11.5,
          weight: 800,
          color: context.palette.accentText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

/// The cream disc beside the price. Flat on purpose — a shadow here would make
/// it read as a second card.
class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onPressed, required this.label});

  static const double _size = 38;

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Share $label',
    child: PressableScale(
      scale: 0.9,
      onPressed: onPressed,
      child: CircleBadge(
        size: _size,
        child: Icon(
          Icons.share_outlined,
          size: 17,
          color: context.palette.textPrimary,
        ),
      ),
    ),
  );
}

/// The full-width lime bar under the money: the way a shop card sells, so
/// the member can get the product for themselves, not only pass it on.
class _GetButton extends StatelessWidget {
  const _GetButton({required this.onPressed, required this.label});

  static const double _height = 36;

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: 'Get $label',
      // The bar reads as one control, not a button and a word.
      excludeSemantics: true,
      child: PressableScale(
        scale: 0.96,
        onPressed: onPressed,
        child: Container(
          height: _height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            'Get',
            style: AppTypography.figtree(
              size: 13.5,
              weight: 800,
              color: palette.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}
