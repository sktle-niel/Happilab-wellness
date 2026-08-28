import 'package:flutter/material.dart';

/// The Falcon Crest Ventures emblem.
///
/// One widget so the asset path lives in a single place — screens ask for a
/// size, not for a file.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 84, super.key});

  static const String _asset = 'assets/images/brand-mark.png';

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    _asset,
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: 'Falcon Crest Ventures',
  );
}
