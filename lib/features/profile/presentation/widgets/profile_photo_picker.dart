import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/profile_photo.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../../../shared/widgets/profile_photo_sheet.dart';

/// The member's picture with the way to change it: tap it, say what the new
/// one is, and every avatar in the app follows.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    required this.photo,
    required this.name,
    super.key,
  });

  final ProfilePhoto photo;
  final String name;

  void _open(BuildContext context) =>
      ProfilePhotoSheet.show(context, photo: photo);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: photo,
    builder: (context, _) => Column(
      children: [
        Semantics(
          button: true,
          label: 'Change photo',
          child: PressableScale(
            scale: 0.96,
            onPressed: photo.isBusy ? null : () => _open(context),
            child: _Portrait(photo: photo, name: name),
          ),
        ),
        const Gap(12),
        Text(
          'Tap the photo to change it',
          textAlign: TextAlign.center,
          style: AppTypography.figtree(
            size: 11.5,
            color: context.palette.textFaint,
          ),
        ),
      ],
    ),
  );
}

/// The avatar with the camera badge on its shoulder — the badge is the cue
/// that this one, unlike the others, can be tapped.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.photo, required this.name});

  static const double _size = 84;

  final ProfilePhoto photo;
  final String name;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      MemberAvatar(photo: photo, name: name, size: _size, bordered: true),
      Positioned(
        right: -2,
        bottom: -2,
        child: _CameraBadge(isBusy: photo.isBusy),
      ),
    ],
  );
}

class _CameraBadge extends StatelessWidget {
  const _CameraBadge({required this.isBusy});

  static const double _size = 30;

  final bool isBusy;

  @override
  Widget build(BuildContext context) => Container(
    width: _size,
    height: _size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.palette.accent,
      shape: BoxShape.circle,
      border: Border.all(color: context.palette.surface, width: 2),
    ),
    child: isBusy
        ? SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.palette.onAccent,
            ),
          )
        : Icon(
            Icons.photo_camera_rounded,
            size: 15,
            color: context.palette.onAccent,
          ),
  );
}
