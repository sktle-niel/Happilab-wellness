import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../core/errors/result.dart';
import '../domain/profile_photo.dart';
import 'app_share_sheet.dart';
import 'app_toast.dart';

/// What the profile picture can be — one of the bundled avatars, or a photo
/// from the phone — and what choosing one does. The edit screen opens it as a
/// sheet; the sign-up step lays the same [targets] out on the page.
abstract final class ProfilePhotoSheet {
  static Future<void> show(
    BuildContext context, {
    required ProfilePhoto photo,
  }) => AppShareSheet.show(
    context,
    title: 'Profile photo',
    note: 'Pick an avatar, or use a photo of your own.',
    targets: targets(context, photo: photo, withRemoval: photo.hasPhoto),
  );

  /// The choices, wired to [photo]. [withRemoval] adds the way back to
  /// initials, for a member who already has a picture.
  static List<ShareTarget> targets(
    BuildContext context, {
    required ProfilePhoto photo,
    bool withRemoval = false,
  }) => [
    for (final avatar in Avatar.values)
      ShareTarget.appLogo(
        label: avatar.label,
        asset: avatar.asset,
        onChosen: () => _replace(context, photo.wear(avatar)),
      ),
    ShareTarget.icon(
      label: 'Gallery',
      icon: Icons.photo_library_outlined,
      color: context.palette.accentText,
      onChosen: () => _replace(context, photo.change(PhotoSource.gallery)),
    ),
    ShareTarget.icon(
      label: 'Camera',
      icon: Icons.photo_camera_outlined,
      color: context.palette.accentText,
      onChosen: () => _replace(context, photo.change(PhotoSource.camera)),
    ),
    if (withRemoval)
      ShareTarget.icon(
        label: 'Remove',
        icon: Icons.delete_outline_rounded,
        color: context.palette.danger,
        onChosen: photo.remove,
      ),
  ];

  /// The avatars follow the replacement on their own, so only one that would
  /// not take has anything to say.
  static Future<void> _replace(
    BuildContext context,
    Future<Result<File?>> replacement,
  ) async {
    final overlay = Overlay.of(context);
    final error = (await replacement).errorOrNull;
    if (error != null) AppToast.failureOn(overlay, error);
  }
}
