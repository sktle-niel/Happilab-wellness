import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/utils/share_actions.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/feed_post.dart';
import 'widgets/feed_post_card.dart';

/// What the brand is telling members, newest first.
class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = MemberSummary.placeholder;
    const posts = FeedPost.placeholder;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            FaithNavBar.contentInset,
          ),
          itemCount: posts.length + 1,
          separatorBuilder: (context, index) => const Gap(AppSpacing.md),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ScreenHeader(
                  showBack: !AppShellScope.contains(context),
                  title: 'News feed',
                  trailing: IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.testimonials),
                    icon: const Icon(Icons.auto_stories_outlined),
                    color: AppColors.accentText,
                    tooltip: 'Member stories',
                  ),
                ),
              );
            }

            final post = posts[index - 1];
            return FeedPostCard(
              post: post,
              onShare: () => ShareActions.copy(
                context,
                ShareActions.inviteMessage(summary.referralCode),
                confirmation: 'Invite message copied.',
              ),
            );
          },
        ),
      ),
    );
  }
}
