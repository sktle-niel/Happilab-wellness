import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/profile_photo.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_share_sheet.dart';
import '../../../shared/widgets/avatar_circle.dart';
import '../../../shared/widgets/centered_scroll_view.dart';
import '../../../shared/widgets/faith_wordmark.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/profile_photo_sheet.dart';

/// The last step of joining: the picture the programme will know the member
/// by — one of the avatars, or a photo of their own. The account already
/// exists by now; only the way into the app waits on the choice.
class ChoosePhotoScreen extends StatefulWidget {
  const ChoosePhotoScreen({super.key});

  @override
  State<ChoosePhotoScreen> createState() => _ChoosePhotoScreenState();
}

class _ChoosePhotoScreenState extends State<ChoosePhotoScreen> {
  bool _isEntering = false;

  ProfilePhoto get _photo => AppScope.of(context).profilePhoto;

  bool get _canContinue => _photo.hasPhoto && !_photo.isBusy && !_isEntering;

  /// The first-run stack is already gone; this screen goes with it.
  void _enter() {
    setState(() => _isEntering = true);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: CenteredScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenInset,
        AppSpacing.md,
        AppSpacing.screenInset,
        40,
      ),
      children: [
        const _ChoosePhotoHeader(),
        const Gap(AppSpacing.lg),
        ListenableBuilder(
          listenable: _photo,
          builder: (context, _) => _PhotoChoice(
            photo: _photo,
            onContinue: _canContinue ? _enter : null,
            isEntering: _isEntering,
          ),
        ),
      ],
    ),
  );
}

class _ChoosePhotoHeader extends StatelessWidget {
  const _ChoosePhotoHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const FaithWordmark(showTagline: false, scale: 0.62),
      const Gap(12),
      Text('Add your photo', style: AppTypography.screenTitle),
      const Gap(2),
      Text(
        'Pick an avatar, or use a photo of your own.\n'
        'You can change it any time from your profile.',
        style: AppTypography.screenSubtitle(context.palette),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

/// The preview, the choices beneath it, and the way in once one is made.
class _PhotoChoice extends StatelessWidget {
  const _PhotoChoice({
    required this.photo,
    required this.onContinue,
    required this.isEntering,
  });

  final ProfilePhoto photo;
  final VoidCallback? onContinue;
  final bool isEntering;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Center(
        child: _Preview(photo: photo.file, isBusy: photo.isBusy),
      ),
      const Gap(AppSpacing.lg),
      ShareTargetRow(
        targets: ProfilePhotoSheet.targets(context, photo: photo),
        onChosen: (target) => target.onChosen(),
        enabled: !photo.isBusy,
      ),
      const Gap(AppSpacing.xl),
      AppButton(
        label: 'Continue',
        onPressed: onContinue,
        isLoading: isEntering,
      ),
    ],
  );
}

/// The slot the choice fills — a plain figure until it does.
class _Preview extends StatelessWidget {
  const _Preview({required this.photo, required this.isBusy});

  static const double _size = 132;

  final File? photo;
  final bool isBusy;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      AvatarCircle(name: '', photo: photo, size: _size, bordered: true),
      if (isBusy)
        Positioned(
          right: 4,
          bottom: 4,
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.palette.accentText,
            ),
          ),
        ),
    ],
  );
}
