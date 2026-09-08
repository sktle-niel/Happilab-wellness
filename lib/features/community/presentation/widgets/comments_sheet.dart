import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/draft_composer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../domain/feed_post.dart';
import '../comments_controller.dart';
import 'comment_tile.dart';

/// The thread under a post, as a sheet: a count, the lines, and a place to
/// add one. Rises to most of the screen and follows the keyboard up.
class CommentsSheet extends StatefulWidget {
  const CommentsSheet({required this.post, super.key});

  final FeedPost post;

  static Future<void> show(BuildContext context, {required FeedPost post}) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        elevation: 0,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => CommentsSheet(post: post),
      );

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  CommentsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= CommentsController(
      community: AppScope.of(context).repositories.community,
      postId: widget.post.id,
    )..load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final overlay = Overlay.of(context);
    final error = await _controller!.send();
    if (error != null) AppToast.failureOn(overlay, error);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    final height = MediaQuery.sizeOf(context).height * 0.8;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: height,
        child: AppCard(
          padding: EdgeInsets.zero,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          shadow: context.palette.shadowCard,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Column(
              children: [
                const Gap(10),
                const _Handle(),
                _Title(count: controller.count),
                Expanded(child: _Thread(controller: controller)),
                _Composer(controller: controller, onSend: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: context.palette.divider,
      borderRadius: AppRadius.pill,
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Comments ($count)',
        style: AppTypography.figtree(size: 18, weight: 800),
      ),
    ),
  );
}

/// The lines, or the wait for them, or the failure with a retry.
class _Thread extends StatelessWidget {
  const _Thread({required this.controller});

  final CommentsController controller;

  @override
  Widget build(BuildContext context) {
    final comments = controller.comments;
    final error = controller.error;
    if (comments == null) {
      return error == null
          ? const LoadingView()
          : ErrorView(error: error, onRetry: controller.load);
    }
    if (comments.isEmpty) return const _Empty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      itemCount: comments.length,
      itemBuilder: (context, index) =>
          CommentTile(comment: comments[index], controller: controller),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'Nothing here yet. Say something first.',
      style: AppTypography.footnote(context.palette),
    ),
  );
}

/// The foot of the sheet: who the line is for, when it is a reply, and the
/// line itself with the member's own face before it.
class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final CommentsController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppScope.of(context);
    final replyingTo = controller.replyingTo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null) ...[
            _ReplyingTo(
              handle: replyingTo.handle,
              onCancel: () => controller.replyTo(null),
            ),
            const Gap.sm(),
          ],
          DraftComposer(
            draft: controller.draft,
            hint: replyingTo == null
                ? 'Add a comment…'
                : 'Reply to ${replyingTo.handle}…',
            onSubmit: onSend,
            leading: MemberAvatar(
              photo: dependencies.profilePhoto,
              name: dependencies.member.summary?.name ?? '',
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyingTo extends StatelessWidget {
  const _ReplyingTo({required this.handle, required this.onCancel});

  final String handle;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          'Replying to $handle',
          style: AppTypography.footnote(context.palette),
        ),
      ),
      TextButton(onPressed: onCancel, child: const Text('Cancel')),
    ],
  );
}
