import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/avatar_circle.dart';
import '../../../../shared/widgets/gap.dart';
import '../../domain/feed_comment.dart';
import '../comments_controller.dart';

/// One comment: who, when, what, the heart and a way to reply — and the
/// replies beneath it, indented and a size smaller.
class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    required this.controller,
    this.isReply = false,
    super.key,
  });

  final FeedComment comment;
  final CommentsController controller;
  final bool isReply;

  double get _avatar => isReply ? 28 : 36;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: isReply ? 10 : 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarCircle(
          name: comment.author,
          imageUrl: comment.avatarUrl,
          size: _avatar,
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Byline(handle: comment.handle, when: comment.when),
              const Gap(3),
              Text(
                comment.body,
                style: AppTypography.figtree(size: 14, height: 1.45),
              ),
              if (!isReply) ...[
                const Gap(6),
                _Actions(comment: comment, controller: controller),
              ],
              if (comment.hasReplies) ...[
                const Gap(12),
                for (final reply in comment.replies)
                  CommentTile(
                    key: ValueKey(reply.id),
                    comment: reply,
                    controller: controller,
                    isReply: true,
                  ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _Byline extends StatelessWidget {
  const _Byline({required this.handle, required this.when});

  final String handle;
  final String when;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(handle, style: AppTypography.figtree(size: 13.5, weight: 800)),
      const Gap.sm(),
      Text(
        when,
        style: AppTypography.figtree(
          size: 12,
          color: context.palette.textFaint,
        ),
      ),
    ],
  );
}

/// The heart with its count, and Reply.
class _Actions extends StatelessWidget {
  const _Actions({required this.comment, required this.controller});

  final FeedComment comment;
  final CommentsController controller;

  @override
  Widget build(BuildContext context) {
    final liked = controller.isLiked(comment);
    final palette = context.palette;
    return Row(
      children: [
        _Action(
          icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: '${controller.likesOf(comment)}',
          semanticsLabel: liked ? 'Unlike' : 'Like',
          color: liked ? palette.danger : palette.textMuted,
          onPressed: () => controller.toggleLike(comment),
        ),
        const Gap(16),
        _Action(
          icon: Icons.mode_comment_outlined,
          label: 'Reply',
          color: palette.textMuted,
          onPressed: () => controller.replyTo(comment),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.semanticsLabel,
  });

  final IconData icon;
  final String label;
  final String? semanticsLabel;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticsLabel ?? label,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.figtree(size: 12.5, weight: 700, color: color),
          ),
        ],
      ),
    ),
  );
}
