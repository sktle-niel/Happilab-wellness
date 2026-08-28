import 'package:flutter/material.dart';

/// Google's four-colour G, for the provider sign-in buttons.
class GoogleMark extends StatelessWidget {
  const GoogleMark({this.size = 19, super.key});

  static const String _asset = 'assets/images/google-mark.png';

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    _asset,
    width: size,
    height: size,
    // The source is 256px; decode close to the ~19px it draws at.
    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil(),
  );
}
