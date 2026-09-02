import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/catalogue.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/avatar_circle.dart';
import '../../../../shared/widgets/gap.dart';
import '../../domain/testimonial.dart';
import 'testimonial_video.dart';

/// One member story.
///
/// Every card carries the same three parts — who said it, what they said, and
/// how they rated it — and only the stacking changes: over the clip when the
/// clip is the whole story, under it when there are words as well.
class TestimonialCard extends StatelessWidget {
  const TestimonialCard({required this.testimonial, super.key});

  /// A clip with nothing to read fills the card; one with words above them
  /// takes a band, so the quote is not pushed past the fold.
  static const double _heroHeight = 380;
  static const double _bandHeight = 210;

  final Testimonial testimonial;

  @override
  Widget build(BuildContext context) {
    if (!testimonial.hasVideo) return _WordsCard(testimonial: testimonial);
    return testimonial.hasWords
        ? _ClipAndWordsCard(testimonial: testimonial, height: _bandHeight)
        : _ClipCard(testimonial: testimonial, height: _heroHeight);
  }
}

/// Words alone, on the surface.
class _WordsCard extends StatelessWidget {
  const _WordsCard({required this.testimonial});

  final Testimonial testimonial;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(18),
    borderRadius: AppRadius.hero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Attribution(testimonial: testimonial),
        const Gap(14),
        _Quote(testimonial: testimonial),
        const Gap(16),
        _Rating(testimonial: testimonial),
      ],
    ),
  );
}

/// The clip is the whole story, so everything else sits over it.
class _ClipCard extends StatelessWidget {
  const _ClipCard({required this.testimonial, required this.height});

  final Testimonial testimonial;
  final double height;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    borderRadius: AppRadius.hero,
    clip: true,
    child: SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TestimonialVideo(assetPath: testimonial.videoAsset!),
          // The overlay must not swallow the tap that starts the clip.
          const IgnorePointer(child: _Scrim()),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Attribution(testimonial: testimonial, onMedia: true),
                  _Rating(testimonial: testimonial, onMedia: true),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// The clip takes a band, and the words are read underneath it.
class _ClipAndWordsCard extends StatelessWidget {
  const _ClipAndWordsCard({required this.testimonial, required this.height});

  final Testimonial testimonial;
  final double height;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    borderRadius: AppRadius.hero,
    clip: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: TestimonialVideo(assetPath: testimonial.videoAsset!),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Attribution(testimonial: testimonial),
              const Gap(14),
              _Quote(testimonial: testimonial),
              const Gap(16),
              _Rating(testimonial: testimonial),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Who is speaking, what earns them the hearing, and where they posted it.
class _Attribution extends StatelessWidget {
  const _Attribution({required this.testimonial, this.onMedia = false});

  final Testimonial testimonial;

  /// True when this is drawn over the clip, where the palette's text colours
  /// would disappear into the footage.
  final bool onMedia;

  @override
  Widget build(BuildContext context) {
    final source = testimonial.source;

    return Row(
      children: [
        AvatarCircle(name: testimonial.name, size: 40, bordered: onMedia),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                testimonial.name,
                style: AppTypography.figtree(
                  size: 14.5,
                  weight: 800,
                  color: onMedia ? Colors.white : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                testimonial.credential,
                style: AppTypography.figtree(
                  size: 12,
                  weight: 600,
                  color: onMedia
                      ? Colors.white.withValues(alpha: 0.8)
                      : context.palette.textFaint,
                ),
              ),
            ],
          ),
        ),
        if (source != null) _SourceMark(platform: source),
      ],
    );
  }
}

/// The storefront the member posted their story on.
class _SourceMark extends StatelessWidget {
  const _SourceMark({required this.platform});

  static const double _size = 26;

  final SharePlatform platform;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Shared on ${platform.label}',
    child: Container(
      width: _size,
      height: _size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Image.asset(platform.logoAsset, fit: BoxFit.contain),
    ),
  );
}

/// The headline the card leads with, then the rest of what they said.
class _Quote extends StatelessWidget {
  const _Quote({required this.testimonial});

  final Testimonial testimonial;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: '“${testimonial.headline!}',
      style: AppTypography.figtree(size: 16.5, weight: 800, height: 1.4),
      children: [
        TextSpan(
          text: ' ${testimonial.quote ?? ''}”',
          style: AppTypography.figtree(
            size: 14.5,
            weight: 500,
            height: 1.55,
            color: context.palette.textMuted,
          ),
        ),
      ],
    ),
  );
}

/// The stars and the date, on one line at the foot of the card.
class _Rating extends StatelessWidget {
  const _Rating({required this.testimonial, this.onMedia = false});

  final Testimonial testimonial;
  final bool onMedia;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Stars(count: testimonial.rating),
      const Spacer(),
      Text(
        testimonial.date,
        style: AppTypography.figtree(
          size: 12.5,
          weight: 600,
          color: onMedia
              ? Colors.white.withValues(alpha: 0.85)
              : context.palette.textFaint,
        ),
      ),
    ],
  );
}

/// The score, in the emblem's gold rather than the accent — a green star reads
/// as one more button.
class _Stars extends StatelessWidget {
  const _Stars({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$count out of 5 stars',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < count; index++)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(
              Icons.star_rounded,
              size: 17,
              color: context.palette.brand,
            ),
          ),
      ],
    ),
  );
}

/// Darkens the head and foot of a clip so white text holds against whatever
/// frame is behind it. Black whatever the palette: it sits on footage, not on
/// the canvas.
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.3, 0.65, 1],
        colors: [
          Colors.black.withValues(alpha: 0.5),
          Colors.black.withValues(alpha: 0),
          Colors.black.withValues(alpha: 0),
          Colors.black.withValues(alpha: 0.6),
        ],
      ),
    ),
  );
}
