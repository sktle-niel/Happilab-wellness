import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_typography.dart';

/// The brand's monogram: the two letters the name is built on.
///
/// One widget so the mark lives in a single place — callers ask for a size and
/// get letters that fit it, the way they asked the emblem for one before. It
/// carries no circle of its own: the rows that use it already draw theirs.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 40, super.key});

  /// The square the letters are fitted into.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: FittedBox(
      fit: BoxFit.contain,
      child: Text(
        'AC',
        style: AppTypography.figtree(
          size: 40,
          weight: 800,
          letterSpacing: -1,
          color: context.palette.brand,
        ),
        semanticsLabel: 'AC Falcon Crest Ventures',
      ),
    ),
  );
}
