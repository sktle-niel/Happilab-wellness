import 'package:flutter/material.dart';

import 'app_share_sheet.dart';
import '../../app/theme/app_palette.dart';

/// The two places Facebook can take a share: the feed, or a story.
abstract final class FacebookShareSheet {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPost,
    required VoidCallback onStory,
  }) => AppShareSheet.show(
    context,
    title: 'Share to Facebook',
    targets: [
      ShareTarget.icon(
        label: 'Post',
        icon: Icons.dynamic_feed_rounded,
        color: context.palette.accentText,
        onChosen: onPost,
      ),
      ShareTarget.icon(
        label: 'Story',
        icon: Icons.amp_stories_rounded,
        color: context.palette.accentText,
        onChosen: onStory,
      ),
    ],
  );
}
