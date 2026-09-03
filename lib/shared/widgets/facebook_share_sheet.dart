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
      ShareTarget(
        label: 'Post',
        child: Icon(
          Icons.dynamic_feed_rounded,
          size: 24,
          color: context.palette.accentText,
        ),
        onChosen: onPost,
      ),
      ShareTarget(
        label: 'Story',
        child: Icon(
          Icons.amp_stories_rounded,
          size: 24,
          color: context.palette.accentText,
        ),
        onChosen: onStory,
      ),
    ],
  );
}
