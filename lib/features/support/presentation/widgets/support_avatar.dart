import 'package:flutter/material.dart';

/// Support's face in the thread: the app's own icon, the perched bird,
/// cropped in a little so it fills a small disc the way a portrait would.
class SupportAvatar extends StatelessWidget {
  const SupportAvatar({this.size = 28, super.key});

  static const String _asset = 'assets/icon/app-icon.jpg';

  /// How far in to crop: the bird sits in the middle third of the icon.
  static const double _zoom = 1.5;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: ClipOval(
      child: Transform.scale(
        scale: _zoom,
        child: Image.asset(
          _asset,
          fit: BoxFit.cover,
          // Decoded near the size it draws at, not the 1024px it ships at.
          cacheWidth: (size * _zoom * MediaQuery.devicePixelRatioOf(context))
              .ceil(),
          semanticLabel: 'Falcon Crest support',
        ),
      ),
    ),
  );
}
