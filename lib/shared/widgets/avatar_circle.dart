import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import 'remote_image.dart';
import '../../app/theme/app_palette.dart';

/// Round avatar that falls back to initials when there is no photo — which is
/// most of the time in a referral list — and to a plain figure when there is
/// no name to take them from either.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    required this.name,
    this.imageUrl,
    this.photo,
    this.size = 44,
    this.bordered = false,
    super.key,
  });

  final String name;
  final String? imageUrl;

  /// A picture kept on this device — the member's own. Wins over [imageUrl].
  final File? photo;
  final double size;

  /// White ring, as the home top bar draws it.
  final bool bordered;

  @override
  Widget build(BuildContext context) => Container(
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
    child: _Face(name: name, photo: photo, imageUrl: imageUrl, size: size),
  );
}

/// What fills the circle: the member's own picture, a remote one, or the
/// fallback — in that order of preference.
class _Face extends StatelessWidget {
  const _Face({
    required this.name,
    required this.photo,
    required this.imageUrl,
    required this.size,
  });

  final String name;
  final File? photo;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    final url = imageUrl;

    if (photo != null) {
      return Image.file(
        photo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Decoded at the size it is drawn, not the size it was taken.
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _Fallback(name: name, size: size),
      );
    }
    if (url != null) return RemoteImage(url: url, width: size, height: size);
    return _Fallback(name: name, size: size);
  }
}

/// Initials while there is a name; a figure while there is not — the empty
/// slot on the sign-up photo step.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.name, required this.size});

  final String name;
  final double size;

  String get _initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final initials = _initials;
    if (initials.isEmpty) {
      return Icon(
        Icons.person_rounded,
        size: size * 0.52,
        color: context.palette.accentText,
      );
    }
    return Text(
      initials,
      style: AppTypography.figtree(
        size: size * 0.37,
        weight: 800,
        color: context.palette.accentText,
      ),
    );
  }
}
