import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'rise_in.dart';
import '../../app/theme/app_palette.dart';

/// AC FALCON CREST over a ruled VENTURES, with the optional tagline beneath —
/// the brand lockup, and the only place the name is spelled out.
///
/// Pass [entrance] to stagger it in; leave it null and everything renders at
/// rest, which is what a still preview or a test wants.
class FaithWordmark extends StatelessWidget {
  const FaithWordmark({
    this.entrance,
    this.showTagline = true,
    this.scale = 1,
    this.color,
    super.key,
  });

  static const String tagline = 'BUILDING OPPORTUNITIES. CREATING LEGACIES.';

  final Animation<double>? entrance;
  final bool showTagline;

  /// Shrinks the whole lockup — a header uses a smaller variant.
  final double scale;

  /// Overrides the lockup's own gold. A lockup laid over footage needs it: the
  /// canvas colours were picked to sit on cream, and they vanish on video.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final title = AppTypography.wordmark(context.palette);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Staggered(
          entrance: entrance,
          begin: 0.15,
          end: 0.6,
          child: Padding(
            // Letter spacing adds a trailing gap; nudging by half of it keeps
            // the wordmark optically centred.
            padding: EdgeInsets.only(left: (title.letterSpacing ?? 0) / 2),
            // The full name at this tracking is wider than a narrow phone;
            // scaleDown gives way only where it has to.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'AC FALCON CREST',
                style: title.copyWith(
                  fontSize: title.fontSize! * scale,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        _Staggered(
          entrance: entrance,
          begin: 0.3,
          end: 0.75,
          child: _Ventures(scale: scale, color: color),
        ),
        if (showTagline)
          _Staggered(
            entrance: entrance,
            begin: 0.45,
            end: 1,
            child: const _Tagline(),
          ),
      ],
    );
  }
}

/// Rises its child in on the entrance, or renders it plainly when there is no
/// entrance to ride — the loader animates, a static lockup does not.
class _Staggered extends StatelessWidget {
  const _Staggered({
    required this.entrance,
    required this.begin,
    required this.end,
    required this.child,
  });

  final Animation<double>? entrance;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = entrance;
    if (animation == null) return child;
    return RiseIn(animation: animation, begin: begin, end: end, child: child);
  }
}

/// The second line: VENTURES held between two rules.
class _Ventures extends StatelessWidget {
  const _Ventures({required this.scale, this.color});

  final double scale;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final sub = AppTypography.wordmarkSub(context.palette);
    final rule = _Rule(color: color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        rule,
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.sm + 2,
            right: AppSpacing.sm + 2 + (sub.letterSpacing ?? 0),
          ),
          child: Text(
            'VENTURES',
            style: sub.copyWith(fontSize: sub.fontSize! * scale, color: color),
          ),
        ),
        rule,
      ],
    );
  }
}

/// The line under the lockup.
class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: Text(
      FaithWordmark.tagline,
      style: AppTypography.tagline(context.palette),
    ),
  );
}

class _Rule extends StatelessWidget {
  const _Rule({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 42,
    height: 1.5,
    child: ColoredBox(color: color ?? context.palette.accentText),
  );
}
