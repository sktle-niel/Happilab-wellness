import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

/// Network image with the two states a photo actually has on a phone: still
/// loading, and failed.
///
/// Without this every remote image is a silent grey box on a bad connection.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder,
      errorBuilder: (context, error, stackTrace) => _placeholder,
    );

    final radius = borderRadius;
    return radius == null
        ? image
        : ClipRRect(borderRadius: radius, child: image);
  }

  Widget get _placeholder => SizedBox(
    width: width,
    height: height,
    child: const ColoredBox(color: AppPalette.mascotBody),
  );
}
