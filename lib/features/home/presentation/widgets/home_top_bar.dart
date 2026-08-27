import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/member_summary.dart';
import '../../../../shared/widgets/avatar_circle.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/gap.dart';

/// Who is signed in, and the way to their notifications.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    required this.summary,
    required this.onNotifications,
    super.key,
  });

  final MemberSummary summary;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AvatarCircle(name: summary.name, size: 46, bordered: true),
      const Gap(12),
      Expanded(
        child: Text(
          summary.name,
          style: AppTypography.figtree(size: 15, weight: 800),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _NotificationBell(
        unreadCount: summary.unreadNotifications,
        onPressed: onNotifications,
      ),
    ],
  );
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unreadCount, required this.onPressed});

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      CircleIconButton(
        icon: Icons.notifications_none_rounded,
        semanticLabel: 'Notifications',
        color: AppColors.accentText,
        onPressed: onPressed,
      ),
      if (unreadCount > 0)
        Positioned(top: -2, right: -2, child: _UnreadBadge(count: unreadCount)),
    ],
  );
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 18),
    height: 18,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: AppColors.danger,
      borderRadius: AppRadius.pill,
      border: Border.all(color: AppColors.canvas, width: 2),
    ),
    child: Text(
      '$count',
      style: AppTypography.figtree(
        size: 10.5,
        weight: 800,
        color: AppColors.surface,
      ),
    ),
  );
}
