import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'rise_in.dart';
import '../../app/theme/app_palette.dart';

/// FALCON CREST over a ruled VENTURES, with the optional tagline beneath — the
/// brand lockup used by the loader and the onboarding cover.
///
/// Pass [entrance] to stagger it in; leave it null and everything renders at
/// rest, which is what a still preview or a test wants.
class FaithWordmark extends StatelessWidget {
  const FaithWordmark({
    this.entrance,
    this.showTagline = true,
    this.scale = 1,
    super.key,
  });

  static const String tagline = 'BUILDING OPPORTUNITIES. CREATING LEGACIES.';

  final Animation<double>? entrance;
  final bool showTagline;

  /// Shrinks the whole lockup — the onboarding cover uses a smaller variant.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final title = AppTypography.wordmark(context.palette);
    final sub = AppTypography.wordmarkSub(context.palette);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _staggered(
          begin: 0.15,
          end: 0.6,
          child: Padding(
            // Letter spacing adds a trailing gap; nudging by half of it keeps
            // the wordmark optically centred.
            padding: EdgeInsets.only(left: (title.letterSpacing ?? 0) / 2),
            child: Text(
              'FALCON CREST',
              style: title.copyWith(fontSize: title.fontSize! * scale),
            ),
          ),
        ),
        _staggered(
          begin: 0.3,
          end: 0.75,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Rule(),
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.sm + 2,
                  right: AppSpacing.sm + 2 + (sub.letterSpacing ?? 0),
                ),
                child: Text(
                  'VENTURES',
                  style: sub.copyWith(fontSize: sub.fontSize! * scale),
                ),
              ),
              const _Rule(),
            ],
          ),
        ),
        if (showTagline)
          _staggered(
            begin: 0.45,
            end: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                FaithWordmark.tagline,
                style: AppTypography.tagline(context.palette),
              ),
            ),
          ),
      ],
    );
  }

  Widget _staggered({
    required double begin,
    required double end,
    required Widget child,
  }) {
    final animation = entrance;
    if (animation == null) return child;
    return RiseIn(animation: animation, begin: begin, end: end, child: child);
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 42,
    height: 1.5,
    child: ColoredBox(color: context.palette.brand),
  );
}
