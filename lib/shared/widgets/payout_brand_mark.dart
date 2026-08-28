import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

/// The provider's logo beside a payout row, on a white tile so every wordmark
/// sits in the same footprint.
class PayoutBrandMark extends StatelessWidget {
  const PayoutBrandMark({required this.logoAsset, super.key});

  static const double _width = 56;
  static const double _height = 36;

  final String logoAsset;

  @override
  Widget build(BuildContext context) => Container(
    width: _width,
    height: _height,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    decoration: BoxDecoration(
      color: context.palette.surface,
      borderRadius: const BorderRadius.all(Radius.circular(9)),
      border: Border.all(color: context.palette.divider),
    ),
    // Decoded at tile size: the source files are far larger than the 56×36
    // they ever draw at.
    child: Image.asset(logoAsset, fit: BoxFit.contain, cacheWidth: 168),
  );
}
