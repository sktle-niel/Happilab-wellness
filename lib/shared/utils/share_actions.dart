import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/catalogue.dart';
import '../domain/messaging_app.dart';
import '../domain/program_terms.dart';
import '../widgets/app_toast.dart';
import 'native_share.dart';
import 'story_card.dart';

/// The messages a member actually sends, and the ways the app hands them over.
///
/// Copy-to-clipboard stands in for a share sheet: it works on every platform
/// with no dependency, and the wording is the part that matters.
abstract final class ShareActions {
  static String productMessage(Product product, String referralCode) =>
      'Try ${product.name} from Falcon Crest Ventures — ${product.price}. '
      'Use my code $referralCode.';

  /// The referral pitch, written the way referral apps write theirs: what the
  /// programme pays, the code that credits the sender, and the link that
  /// carries it.
  static String inviteMessage(String referralCode) =>
      'Come join me on Falcon Crest Ventures! 🌿 Share wellness products and '
      'earn real money — you get ${ProgramTerms.earnRate} of every order your '
      'friends make, and ${ProgramTerms.pointsConversion}.\n\n'
      'Use my referral code $referralCode when you sign up, or just tap my '
      'link:\n${inviteLink(referralCode)}';

  /// Where a new member lands: the public join page with the code attached,
  /// so the sign-up can credit the sender. The domain stands in until config
  /// carries the real one.
  static Uri inviteLink(String referralCode) =>
      Uri.https('happilab.app', '/join', {'ref': referralCode});

  /// Messenger's share composer with [link] prefilled — the deep link the
  /// platform's own share sheets use.
  static Uri messengerShare(Uri link) =>
      Uri.parse('fb-messenger://share?link=${Uri.encodeComponent('$link')}');

  /// Facebook's share dialog, ready to post [link] — the app claims it when
  /// installed and the web dialog stands in when it is not.
  static Uri facebookShare(Uri link) =>
      Uri.https('www.facebook.com', '/sharer/sharer.php', {'u': '$link'});

  /// WhatsApp's composer with [message] prefilled — wa.me opens the app when
  /// it is installed and its web client when it is not.
  static Uri whatsappShare(String message) =>
      Uri.https('wa.me', '/', {'text': message});

  /// Viber's forward screen with [message] prefilled.
  static Uri viberShare(String message) =>
      Uri.parse('viber://forward?text=${Uri.encodeComponent(message)}');

  /// TikTok's front door. It offers no prefilled composer, so callers copy
  /// the message first and open the app to paste.
  static Uri tiktokHome() => Uri.https('www.tiktok.com', '/');

  /// Copies [text] and tells the member it worked.
  static Future<void> copy(
    BuildContext context,
    String text, {
    required String confirmation,
  }) async {
    // Read before the await: the context may be gone by the time it returns.
    final overlay = Overlay.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    AppToast.showOn(overlay, ToastKind.success, confirmation);
  }

  /// Sends [text] with the picture behind [imageUrl] straight into [app].
  ///
  /// The picture rides the regular image cache, so a card already on screen
  /// shares instantly; when it cannot be fetched the text goes alone, and a
  /// missing app is a message, not a crash. The receiving app decides what it
  /// keeps — a few drop the caption of an image share.
  static Future<void> shareWithImage(
    BuildContext context, {
    required String text,
    required String imageUrl,
    required MessagingApp app,
  }) async {
    final overlay = Overlay.of(context);
    final image = await NativeShare.writeTempImage(NetworkImage(imageUrl));
    final sent = await NativeShare.send(
      text: text,
      image: image,
      toPackage: app.androidPackage,
    );
    if (sent) return;
    AppToast.showOn(
      overlay,
      ToastKind.error,
      'Could not open ${app.label}',
      detail: 'Check that the app is installed, then try again.',
    );
  }

  /// Puts the branded invite card on the member's Facebook story.
  static Future<void> shareInviteStory(
    BuildContext context, {
    required String referralCode,
  }) async {
    final overlay = Overlay.of(context);
    final card = await StoryCard.renderInvite(referralCode: referralCode);
    await _sendStory(overlay, card);
  }

  /// Puts one product's card — photo, price, code — on the member's story.
  static Future<void> shareProductStory(
    BuildContext context, {
    required Product product,
    required String referralCode,
  }) async {
    final overlay = Overlay.of(context);
    final card = await StoryCard.renderProduct(
      product: product,
      referralCode: referralCode,
    );
    await _sendStory(overlay, card);
  }

  static Future<void> _sendStory(OverlayState overlay, File? card) async {
    final sent =
        card != null && await NativeShare.sendToFacebookStory(image: card);
    if (sent) return;
    AppToast.showOn(
      overlay,
      ToastKind.error,
      'Could not open Facebook Stories',
      detail: 'Check that Facebook is installed, then try again.',
    );
  }

  /// Hands [link] to the store's app, or the browser. A refusal — no browser
  /// on the device, a store app that will not take the URL — is a message,
  /// not a crash.
  static Future<void> open(
    BuildContext context,
    Uri link, {
    required String destination,
  }) async {
    final overlay = Overlay.of(context);
    bool opened;
    try {
      opened = await launchUrl(link, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (opened) return;
    AppToast.showOn(
      overlay,
      ToastKind.error,
      'Could not open $destination',
      detail: 'Check that the app or a browser is installed, then try again.',
    );
  }
}
