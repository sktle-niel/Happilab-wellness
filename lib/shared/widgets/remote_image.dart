import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import 'skeleton.dart';

/// Network image with the two states a photo actually has on a phone: still
/// loading, and failed.
///
/// While it loads, a skeleton breathes in its place; when it fails, a plain
/// tinted box stays — a placeholder that kept breathing would promise a
/// picture that is not coming.
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
          progress == null ? child : _loading,
      errorBuilder: (context, error, stackTrace) => _failed,
    );

    final radius = borderRadius;
    return radius == null
        ? image
        : ClipRRect(borderRadius: radius, child: image);
  }

  Widget get _loading => SkeletonBox(
    width: width,
    height: height,
    borderRadius: borderRadius ?? BorderRadius.zero,
  );

  Widget get _failed => _Failed(width: width, height: height);
}

class _Failed extends StatelessWidget {
  const _Failed({required this.width, required this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: ColoredBox(color: context.palette.tint),
  );
}
