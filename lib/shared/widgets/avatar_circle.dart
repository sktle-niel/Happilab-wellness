import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import 'remote_image.dart';
import '../../app/theme/app_palette.dart';

/// Round avatar that falls back to initials when there is no photo — which is
/// most of the time in a referral list.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    required this.name,
    this.imageUrl,
    this.size = 44,
    this.bordered = false,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final double size;

  /// White ring, as the home top bar draws it.
  final bool bordered;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.tint,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(color: context.palette.surface, width: 2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? Text(
              _initials,
              style: AppTypography.figtree(
                size: size * 0.37,
                weight: 800,
                color: context.palette.accentText,
              ),
            )
          : RemoteImage(url: url, width: size, height: size),
    );
  }
}
