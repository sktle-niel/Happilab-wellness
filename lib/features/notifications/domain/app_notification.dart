/// A message from the brand.
class AppNotification {
  const AppNotification({
    required this.body,
    required this.when,
    required this.isUnread,
  });

  static const String sender = 'Falcon Crest Ventures';

  final String body;
  final String when;
  final bool isUnread;

  AppNotification asRead() =>
      AppNotification(body: body, when: when, isUnread: false);

  static const List<AppNotification> placeholder = [
    AppNotification(
      body: 'Maria placed her second order. 19 points are on the way.',
      when: '2h',
      isUnread: true,
    ),
    AppNotification(
      body: 'Your ₱500 cash out was sent to GCash.',
      when: '1d',
      isUnread: true,
    ),
    AppNotification(
      body: 'Sakura Glow Soap is back in stock — a good week to share it.',
      when: '2d',
      isUnread: true,
    ),
    AppNotification(
      body: 'Paolo joined using your code. Say hello!',
      when: '3d',
      isUnread: false,
    ),
    AppNotification(
      body: 'Payouts to Maya now arrive within 24 hours.',
      when: '1w',
      isUnread: false,
    ),
  ];
}
