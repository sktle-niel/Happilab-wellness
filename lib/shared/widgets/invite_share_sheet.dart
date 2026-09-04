import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../domain/catalogue.dart';
import '../domain/messaging_app.dart';
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
        ShareTarget.icon(
          label: 'Copy link',
          icon: Icons.link_rounded,
          color: context.palette.accentText,
          onChosen: () => ShareActions.copy(
            context,
            message,
            confirmation: 'Invite message copied.',
          ),
        ),
        _chat(
          MessagingApp.messenger,
          () => ShareActions.open(
            context,
            ShareActions.messengerShare(link),
            destination: MessagingApp.messenger.label,
          ),
        ),
        ShareTarget.appLogo(
          label: SharePlatform.tiktok.label,
          asset: SharePlatform.tiktok.logoAsset,
          onChosen: () => _copyThenOpenTikTok(context, message),
        ),
        _chat(
          MessagingApp.facebook,
          () => _shareToFacebook(context, link, referralCode),
        ),
        _chat(
          MessagingApp.whatsapp,
          () => ShareActions.open(
            context,
            ShareActions.whatsappShare(message),
            destination: MessagingApp.whatsapp.label,
          ),
        ),
        _chat(
          MessagingApp.viber,
          () => ShareActions.open(
            context,
            ShareActions.viberShare(message),
            destination: MessagingApp.viber.label,
          ),
        ),
      ],
    );
  }

  static ShareTarget _chat(MessagingApp app, VoidCallback onChosen) =>
      ShareTarget.appLogo(
        label: app.label,
        asset: app.logoAsset,
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
      destination: MessagingApp.facebook.label,
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
      destination: SharePlatform.tiktok.label,
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
