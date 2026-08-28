import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/gap.dart';
import '../domain/app_notification.dart';
import '../../../app/theme/app_palette.dart';

/// Everything the brand has told this member, newest first.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = AppNotification.placeholder;

  bool get _hasUnread => _notifications.any((entry) => entry.isUnread);

  void _markAllRead() => setState(
    () => _notifications = [for (final entry in _notifications) entry.asRead()],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Row(
            children: [
              CircleIconButton(
                icon: Icons.arrow_back,
                semanticLabel: 'Back',
                onPressed: Navigator.of(context).pop,
              ),
              Expanded(
                child: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: AppTypography.figtree(
                    size: 22,
                    weight: 800,
                    letterSpacing: -0.44,
                  ),
                ),
              ),
              CircleIconButton(
                icon: Icons.done_all_rounded,
                semanticLabel: 'Mark all read',
                color: context.palette.accentText,
                onPressed: _hasUnread ? _markAllRead : null,
              ),
            ],
          ),
          const Gap(14),
          if (!_hasUnread)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                'You are all caught up',
                textAlign: TextAlign.center,
                style: AppTypography.figtree(
                  size: 12,
                  weight: 700,
                  color: context.palette.textFaint,
                ),
              ),
            ),
          for (final entry in _notifications) ...[
            _NotificationTile(notification: entry),
            const Gap(12),
          ],
        ],
      ),
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      // Unread sits on cream so the eye finds it without a badge.
      color: notification.isUnread
          ? context.palette.tint
          : context.palette.surface,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      boxShadow: context.palette.shadowInput,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: context.palette.tint,
            shape: BoxShape.circle,
          ),
          child: const BrandMark(size: 26),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppNotification.sender,
                      style: AppTypography.figtree(size: 13.5, weight: 800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    notification.when,
                    style: AppTypography.figtree(
                      size: 11.5,
                      weight: 700,
                      color: context.palette.textFaint,
                    ),
                  ),
                  if (notification.isUnread) ...[
                    const Gap.sm(),
                    const _UnreadDot(),
                  ],
                ],
              ),
              const Gap(2),
              Text(
                notification.body,
                style: AppTypography.figtree(
                  size: 13.5,
                  weight: 500,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 8,
    height: 8,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.accent,
        shape: BoxShape.circle,
      ),
    ),
  );
}
