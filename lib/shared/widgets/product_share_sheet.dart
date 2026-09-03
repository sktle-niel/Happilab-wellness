import 'package:flutter/material.dart';

import '../domain/catalogue.dart';
import '../domain/messaging_app.dart';
import '../utils/share_actions.dart';
import 'app_share_sheet.dart';
import 'facebook_share_sheet.dart';
import '../../app/theme/app_palette.dart';

/// Where to send a product: into a chat with its picture and pitch, onto the
/// clipboard, or its listing on a storefront with the member's code attached.
abstract final class ProductShareSheet {
  static const String _note =
      'Your code is attached automatically — you earn on every sale';

  static Future<void> show(
    BuildContext context, {
    required Product product,
    required String referralCode,
  }) {
    final message = ShareActions.productMessage(product, referralCode);

    return AppShareSheet.show(
      context,
      title: 'Share ${product.name}',
      note: _note,
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
            confirmation: 'Message for ${product.name} copied.',
          ),
        ),
        for (final app in MessagingApp.values)
          ShareTarget.appLogo(
            label: app.label,
            asset: app.logoAsset,
            onChosen: () =>
                _shareTo(context, app, product, referralCode, message),
          ),
        for (final platform in SharePlatform.values)
          ShareTarget.appLogo(
            label: platform.label,
            asset: platform.logoAsset,
            onChosen: () => ShareActions.open(
              context,
              product.shareLink(platform, referralCode),
              destination: platform.label,
            ),
          ),
      ],
    );
  }

  /// Every chat app takes the picture and its caption straight; Facebook
  /// first asks whether it lands on the feed or on a story.
  static Future<void> _shareTo(
    BuildContext context,
    MessagingApp app,
    Product product,
    String referralCode,
    String message,
  ) {
    if (app != MessagingApp.facebook) {
      return ShareActions.shareWithImage(
        context,
        text: message,
        imageUrl: product.imageUrl,
        app: app,
      );
    }
    return FacebookShareSheet.show(
      context,
      onPost: () => ShareActions.shareWithImage(
        context,
        text: message,
        imageUrl: product.imageUrl,
        app: app,
      ),
      onStory: () => ShareActions.shareProductStory(
        context,
        product: product,
        referralCode: referralCode,
      ),
    );
  }
}
