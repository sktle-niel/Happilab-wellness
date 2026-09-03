import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../utils/share_actions.dart';
import 'app_share_sheet.dart';
import 'facebook_share_sheet.dart';
import '../../app/theme/app_palette.dart';

/// Where an invite goes: straight into the apps members actually use, or onto
/// the clipboard.
abstract final class InviteShareSheet {
  static Future<void> show(
    BuildContext context, {
    required String referralCode,
  }) {
    final link = ShareActions.inviteLink(referralCode);
    final message = ShareActions.inviteMessage(referralCode);

    return AppShareSheet.show(
      context,
      title: 'Invite a friend',
      preview: _InvitePreview(message: message),
      targets: [
        ShareTarget(
          label: 'Copy link',
          child: Icon(
            Icons.link_rounded,
            size: 24,
            color: context.palette.accentText,
          ),
          onChosen: () => ShareActions.copy(
            context,
            message,
            confirmation: 'Invite message copied.',
          ),
        ),
        _app(
          'Messenger',
          'messenger',
          () => ShareActions.open(
            context,
            ShareActions.messengerShare(link),
            destination: 'Messenger',
          ),
        ),
        _app('TikTok', 'tiktok', () => _copyThenOpenTikTok(context, message)),
        _app(
          'Facebook',
          'facebook',
          () => _shareToFacebook(context, link, referralCode),
        ),
        _app(
          'WhatsApp',
          'whatsapp',
          () => ShareActions.open(
            context,
            ShareActions.whatsappShare(message),
            destination: 'WhatsApp',
          ),
        ),
        _app(
          'Viber',
          'viber',
          () => ShareActions.open(
            context,
            ShareActions.viberShare(message),
            destination: 'Viber',
          ),
        ),
      ],
    );
  }

  static ShareTarget _app(String label, String logo, VoidCallback onChosen) =>
      ShareTarget.appLogo(
        label: label,
        asset: 'assets/images/share/$logo.png',
        onChosen: onChosen,
      );

  /// Facebook takes an invite two ways — the chooser asks which.
  static Future<void> _shareToFacebook(
    BuildContext context,
    Uri link,
    String referralCode,
  ) => FacebookShareSheet.show(
    context,
    onPost: () => ShareActions.open(
      context,
      ShareActions.facebookShare(link),
      destination: 'Facebook',
    ),
    onStory: () =>
        ShareActions.shareInviteStory(context, referralCode: referralCode),
  );

  /// TikTok offers no prefilled composer, so the invite is copied first and
  /// the app opened ready for a paste.
  static Future<void> _copyThenOpenTikTok(
    BuildContext context,
    String message,
  ) async {
    await ShareActions.copy(
      context,
      message,
      confirmation: 'Invite copied — paste it on TikTok.',
    );
    if (!context.mounted) return;
    await ShareActions.open(
      context,
      ShareActions.tiktokHome(),
      destination: 'TikTok',
    );
  }
}

/// Exactly what will be sent, read before choosing where — the way referral
/// apps let the member see their own pitch, code and link.
class _InvitePreview extends StatelessWidget {
  const _InvitePreview({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: context.palette.canvas,
      borderRadius: AppRadius.input,
    ),
    child: Text(
      message,
      style: AppTypography.figtree(
        size: 12.5,
        height: 1.45,
        color: context.palette.textMuted,
      ),
    ),
  );
}
