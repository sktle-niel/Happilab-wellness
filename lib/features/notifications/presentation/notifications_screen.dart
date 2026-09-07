import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/circle_badge.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/pressable_scale.dart';
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

  /// Reading one is opening it: it is marked read, then the member is taken
  /// where it points. One with nowhere to point never gets here.
  void _open(AppNotification notification) {
    final destination = notification.destination;
    if (destination == null) return;
    setState(
      () => _notifications = [
        for (final entry in _notifications)
          if (identical(entry, notification)) entry.asRead() else entry,
      ],
    );
    Navigator.of(context).pushNamed(_routeFor(destination));
  }

  static String _routeFor(NotificationDestination destination) =>
      switch (destination) {
        NotificationDestination.transactions => AppRoutes.accountActivity,
        NotificationDestination.referrals => AppRoutes.myReferrals,
        NotificationDestination.products => AppRoutes.suggestions,
      };

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: AppSpacing.pageInset,
      children: [
        ScreenHeader(
          title: 'Notifications',
          trailing: CircleIconButton(
            icon: Icons.done_all_rounded,
            semanticLabel: 'Mark all read',
            color: context.palette.accentText,
            onPressed: _hasUnread ? _markAllRead : null,
          ),
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
          _NotificationTile(notification: entry, onOpen: _open),
          const Gap(12),
        ],
      ],
    ),
  );
}

/// One message. Tappable only when it leads somewhere — the rest give no
/// response at all, so a tap is never a promise the tile cannot keep.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onOpen});

  final AppNotification notification;
  final ValueChanged<AppNotification> onOpen;

  VoidCallback? get _onPressed =>
      notification.isActionable ? () => onOpen(notification) : null;

  @override
  Widget build(BuildContext context) => Semantics(
    button: notification.isActionable,
    child: PressableScale(
      scale: 0.98,
      onPressed: _onPressed,
      child: _TileSurface(notification: notification),
    ),
  );
}

class _TileSurface extends StatelessWidget {
  const _TileSurface({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      // Unread sits on the tint so the eye finds it without a badge.
      color: notification.isUnread
          ? context.palette.tint
          : context.palette.glass,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      border: Border.all(color: context.palette.glassEdge),
      boxShadow: context.palette.shadowInput,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SenderAvatar(),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _TileHeading(notification: notification),
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

/// The brand mark every notification comes from.
class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar();

  @override
  Widget build(BuildContext context) => const CircleBadge(
    size: 38,
    padding: EdgeInsets.all(6),
    child: BrandMark(size: 26),
  );
}

/// Who sent it, when, and whether it has been read.
class _TileHeading extends StatelessWidget {
  const _TileHeading({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) => Row(
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
      if (notification.isUnread) ...[const Gap.sm(), const _UnreadDot()],
    ],
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
