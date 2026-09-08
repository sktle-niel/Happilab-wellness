import 'package:flutter/material.dart';

import '../../../shared/widgets/card_skeleton.dart';
import '../../../shared/widgets/member_view.dart';
import '../../../shared/widgets/repository_view.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/invite_share_sheet.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/feed_post.dart';
import 'widgets/feed_post_card.dart';
import '../../../app/theme/app_palette.dart';

/// What the brand is telling members, newest first.
class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: MemberView(
      builder: (context, member) => RepositoryView<List<FeedPost>>(
        read: (repositories) => repositories.community.posts(),
        skeleton: const _FeedSkeleton(),
        builder: (context, posts) => _Feed(posts: posts, member: member),
      ),
    ),
  );
}

/// The header, then the posts, in one lazy list.
class _Feed extends StatelessWidget {
  const _Feed({required this.posts, required this.member});

  final List<FeedPost> posts;
  final MemberSummary member;

  void _share(BuildContext context) =>
      InviteShareSheet.show(context, referralCode: member.referralCode);

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, FaithNavBar.contentInset),
    itemCount: posts.length + 1,
    separatorBuilder: (context, index) => const Gap(AppSpacing.md),
    itemBuilder: (context, index) => index == 0
        ? const _FeedHeader()
        : FeedPostCard(post: posts[index - 1], onShare: () => _share(context)),
  );
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ScreenHeader(
      showBack: !AppShellScope.contains(context),
      title: 'News feed',
      trailing: IconButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.testimonials),
        icon: const Icon(Icons.auto_stories_outlined),
        color: context.palette.accentText,
        tooltip: 'Member stories',
      ),
    ),
  );
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, FaithNavBar.contentInset),
    children: const [
      _FeedHeader(),
      Gap(AppSpacing.md),
      CardSkeleton(withImage: true),
      Gap(AppSpacing.md),
      CardSkeleton(),
    ],
  );
}
