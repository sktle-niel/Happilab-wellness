import 'package:flutter/material.dart';

import '../domain/catalogue.dart';
import 'gap.dart';
import 'product_share_sheet.dart';
import 'product_share_tile.dart';

/// Products two to a row, each with the member's share action wired in.
///
/// Plain rows rather than a lazy grid: a lazy grid needs a fixed card height,
/// which real text cannot promise, and the catalogue is a handful of cards.
/// Each row stretches both cards to the taller one so the pair lines up.
class ProductShareGrid extends StatelessWidget {
  const ProductShareGrid({
    required this.products,
    required this.referralCode,
    super.key,
  });

  static const double _gap = 12;

  final List<Product> products;
  final String referralCode;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < products.length; i += 2) ...[
        if (i > 0) const Gap(_gap),
        _GridRow(
          referralCode: referralCode,
          left: products[i],
          right: i + 1 < products.length ? products[i + 1] : null,
        ),
      ],
    ],
  );
}

/// The same cards in one row that scrolls sideways past the screen edge —
/// the home preview, where a glance matters more than the whole set.
class ProductShareCarousel extends StatelessWidget {
  const ProductShareCarousel({
    required this.products,
    required this.referralCode,
    this.edgeInset = 0,
    super.key,
  });

  static const double _cardWidth = 236;

  /// Tall enough for a square photo, a one-line name, two lines of blurb and
  /// the money row at [_cardWidth]; the card fills it from both ends.
  static const double _height = 354;

  static const double _gap = 12;

  final List<Product> products;
  final String referralCode;

  /// Horizontal padding the first and last card keep from the screen edge.
  final double edgeInset;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: edgeInset),
      itemCount: products.length,
      separatorBuilder: (context, index) => const Gap(_gap),
      itemBuilder: (context, index) => SizedBox(
        width: _cardWidth,
        child: ProductShareCell(
          product: products[index],
          referralCode: referralCode,
        ),
      ),
    ),
  );
}

class _GridRow extends StatelessWidget {
  const _GridRow({required this.referralCode, required this.left, this.right});

  final String referralCode;
  final Product left;
  final Product? right;

  @override
  Widget build(BuildContext context) {
    final second = right;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ProductShareCell(product: left, referralCode: referralCode),
          ),
          const Gap(ProductShareGrid._gap),
          Expanded(
            child: second == null
                ? const SizedBox.shrink()
                : ProductShareCell(product: second, referralCode: referralCode),
          ),
        ],
      ),
    );
  }
}

/// One card whose share button opens the share sheet.
class ProductShareCell extends StatelessWidget {
  const ProductShareCell({
    required this.product,
    required this.referralCode,
    super.key,
  });

  final Product product;
  final String referralCode;

  @override
  Widget build(BuildContext context) => ProductShareTile(
    product: product,
    onShare: () => ProductShareSheet.show(
      context,
      product: product,
      referralCode: referralCode,
    ),
  );
}
