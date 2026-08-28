import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/catalogue.dart';

/// The messages a member actually sends, and the ways the app hands them over.
///
/// Copy-to-clipboard stands in for a share sheet: it works on every platform
/// with no dependency, and the wording is the part that matters.
abstract final class ShareActions {
  static String productMessage(Product product, String referralCode) =>
      'Try ${product.name} from Falcon Crest Ventures — ${product.price}. '
      'Use my code $referralCode.';

  static String inviteMessage(String referralCode) =>
      'Join me on Falcon Crest Ventures and use my code $referralCode when you '
      'sign up.';

  /// Copies [text] and tells the member it worked.
  static Future<void> copy(
    BuildContext context,
    String text, {
    required String confirmation,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
  }

  /// Hands [link] to the store's app, or the browser. A refusal — no browser
  /// on the device, a store app that will not take the URL — is a message,
  /// not a crash.
  static Future<void> open(
    BuildContext context,
    Uri link, {
    required String destination,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    bool opened;
    try {
      opened = await launchUrl(link, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (opened) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open $destination right now.')),
    );
  }
}
