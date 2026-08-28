import 'package:flutter/material.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/brand_mark.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/remote_image.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../domain/feed_post.dart';
import 'post_video.dart';
import '../../../../app/theme/app_palette.dart';

/// One post: who wrote it, what it shows, and the two things a member does
/// with it.
class FeedPostCard extends StatefulWidget {
  const FeedPostCard({required this.post, required this.onShare, super.key});

  final FeedPost post;
  final VoidCallback onShare;

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _isLiked = false;

  int get _likes => widget.post.likes + (_isLiked ? 1 : 0);

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    borderRadius: AppRadius.hero,
    clip: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _PostHeader(post: widget.post),
        if (widget.post.media != PostMedia.none)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              child: _PostMedia(post: widget.post),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _PostAction(
                    icon: _isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: '$_likes',
                    color: _isLiked
                        ? context.palette.danger
                        : context.palette.textMuted,
                    onPressed: () => setState(() => _isLiked = !_isLiked),
                  ),
                  const Gap(18),
                  _PostAction(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: context.palette.textMuted,
                    onPressed: widget.onShare,
                  ),
                  const Spacer(),
                  Text(
                    '${widget.post.comments} comments',
                    style: AppTypography.figtree(
                      size: 12.5,
                      color: context.palette.textFaint,
                    ),
                  ),
                ],
              ),
              const Gap.sm(),
              Text(
                widget.post.body,
                style: AppTypography.figtree(size: 14.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: context.palette.surface,
            shape: BoxShape.circle,
            border: Border.all(color: context.palette.tint, width: 1.5),
          ),
          child: const BrandMark(size: 28),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                post.author,
                style: AppTypography.figtree(size: 14.5, weight: 800),
              ),
              Text(
                post.when,
                style: AppTypography.figtree(
                  size: 12,
                  color: context.palette.textFaint,
                ),
              ),
            ],
          ),
        ),
        if (post.media == PostMedia.video)
          StatusPill(
            label: 'Video',
            background: context.palette.danger,
            foreground: Colors.white,
          ),
      ],
    ),
  );
}

class _PostMedia extends StatelessWidget {
  const _PostMedia({required this.post});

  static const double _height = 260;

  final FeedPost post;

  @override
  Widget build(BuildContext context) => switch (post.media) {
    PostMedia.video => PostVideo(assetPath: post.mediaUrl!, height: _height),
    PostMedia.image => RemoteImage(
      url: post.mediaUrl!,
      height: _height,
      width: double.infinity,
    ),
    PostMedia.none => const SizedBox.shrink(),
  };
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 32,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.figtree(size: 14, weight: 700, color: color),
            ),
          ],
        ),
      ),
    ),
  );
}
