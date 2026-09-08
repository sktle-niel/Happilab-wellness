/// Where a message leads when it is tapped.
enum NotificationDestination { transactions, referrals, products }

/// A message from the brand.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.body,
    required this.when,
    required this.isUnread,
    this.destination,
  });

  static const String sender = 'Falcon Crest Ventures';

  final String id;
  final String body;
  final String when;
  final bool isUnread;

  /// Null when the message is only news, with nowhere to take the member.
  final NotificationDestination? destination;

  bool get isActionable => destination != null;

  AppNotification asRead() => AppNotification(
    id: id,
    body: body,
    when: when,
    isUnread: false,
    destination: destination,
  );

  static const List<AppNotification> placeholder = [
    AppNotification(
      id: 'n1',
      body: 'Maria placed her second order. 19 points are on the way.',
      when: '2h',
      isUnread: true,
      destination: NotificationDestination.transactions,
    ),
    AppNotification(
      id: 'n2',
      body: 'Your ₱500 cash out was sent to GCash.',
      when: '1d',
      isUnread: true,
      destination: NotificationDestination.transactions,
    ),
    AppNotification(
      id: 'n3',
      body: 'Sakura Glow Soap is back in stock — a good week to share it.',
      when: '2d',
      isUnread: true,
      destination: NotificationDestination.products,
    ),
    AppNotification(
      id: 'n4',
      body: 'Paolo joined using your code. Say hello!',
      when: '3d',
      isUnread: false,
      destination: NotificationDestination.referrals,
    ),
    AppNotification(
      id: 'n5',
      body: 'Payouts to Maya now arrive within 24 hours.',
      when: '1w',
      isUnread: false,
    ),
  ];
}
