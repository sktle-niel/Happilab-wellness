import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/catalogue.dart';

/// The messages a member actually sends, and the one way the app hands them
/// over.
///
/// Copy-to-clipboard stands in for a share sheet: it works on every platform
/// with no dependency, and the wording is the part that matters.
abstract final class ShareActions {
  static String productMessage(Product product, String referralCode) =>
      'Try ${product.name} from Faith Wellness — ${product.price}. '
      'Use my code $referralCode.';

  static String inviteMessage(String referralCode) =>
      'Join me on Faith Wellness and use my code $referralCode when you '
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
}
