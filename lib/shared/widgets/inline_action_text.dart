import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../../app/theme/app_palette.dart';

/// A centred sentence ending in a tappable phrase — "Already a member? Sign in".
///
/// Built from two widgets rather than a rich-text recogniser so there is no
/// gesture recogniser to dispose, and the phrase keeps a full tap target.
class InlineActionText extends StatelessWidget {
  const InlineActionText({
    required this.text,
    required this.actionLabel,
    required this.onPressed,
    super.key,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(text, style: AppTypography.footnote(context.palette)),
      GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            actionLabel,
            style: AppTypography.figtree(
              size: 13,
              weight: 800,
              color: context.palette.accentText,
            ),
          ),
        ),
      ),
    ],
  );
}
