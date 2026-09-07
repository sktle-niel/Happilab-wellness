/// Where a message leads when it is tapped.
enum NotificationDestination { transactions, referrals, products }

/// A message from the brand.
class AppNotification {
  const AppNotification({
    required this.body,
    required this.when,
    required this.isUnread,
    this.destination,
  });

  static const String sender = 'Falcon Crest Ventures';

  final String body;
  final String when;
  final bool isUnread;

  /// Null when the message is only news, with nowhere to take the member.
  final NotificationDestination? destination;

  bool get isActionable => destination != null;

  AppNotification asRead() => AppNotification(
    body: body,
    when: when,
    isUnread: false,
    destination: destination,
  );

  static const List<AppNotification> placeholder = [
    AppNotification(
      body: 'Maria placed her second order. 19 points are on the way.',
      when: '2h',
      isUnread: true,
      destination: NotificationDestination.transactions,
    ),
    AppNotification(
      body: 'Your ₱500 cash out was sent to GCash.',
      when: '1d',
      isUnread: true,
      destination: NotificationDestination.transactions,
    ),
    AppNotification(
      body: 'Sakura Glow Soap is back in stock — a good week to share it.',
      when: '2d',
      isUnread: true,
      destination: NotificationDestination.products,
    ),
    AppNotification(
      body: 'Paolo joined using your code. Say hello!',
      when: '3d',
      isUnread: false,
      destination: NotificationDestination.referrals,
    ),
    AppNotification(
      body: 'Payouts to Maya now arrive within 24 hours.',
      when: '1w',
      isUnread: false,
    ),
  ];
}
