/// What a member said under a post, and what others said back to it.
class FeedComment {
  const FeedComment({
    required this.id,
    required this.author,
    required this.handle,
    required this.when,
    required this.body,
    this.likes = 0,
    this.replies = const [],
    this.avatarUrl,
  });

  final String id;

  /// The member's name, for the avatar.
  final String author;

  /// How the line is signed: `@mariacruz`.
  final String handle;
  final String when;
  final String body;
  final int likes;

  /// What was said back, oldest first. Replies do not nest further.
  final List<FeedComment> replies;
  final String? avatarUrl;

  bool get hasReplies => replies.isNotEmpty;

  /// This comment with [reply] added under it.
  FeedComment withReply(FeedComment reply) => FeedComment(
    id: id,
    author: author,
    handle: handle,
    when: when,
    body: body,
    likes: likes,
    replies: [...replies, reply],
    avatarUrl: avatarUrl,
  );

  /// Everything said in [comments], replies included.
  static int countAll(List<FeedComment> comments) =>
      comments.fold(0, (total, comment) => total + 1 + comment.replies.length);

  /// `@` and the name run together, lower case — how the fakes and the API
  /// sign a member who has no username of their own.
  static String handleFor(String name) =>
      '@${name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}';

  static const List<FeedComment> placeholder = [
    FeedComment(
      id: 'k1',
      author: 'Ralph Yap',
      handle: '@ralphy',
      when: '2 days ago',
      body:
          'How does this hold up after 8 hours? I need something that '
          'survives my work shifts',
      likes: 18,
      replies: [
        FeedComment(
          id: 'k2',
          author: 'Jess Cruz',
          handle: '@jess123',
          when: '1 hour ago',
          body:
              'Still going strong at hour 10! I set it with the translucent '
              'powder and did not touch up once. Game changer for long days',
        ),
      ],
    ),
    FeedComment(
      id: 'k3',
      author: 'Anna Jimenez',
      handle: '@annaj',
      when: '2 days ago',
      body: 'Need a full tutorial on this makeup look immediately!',
    ),
    FeedComment(
      id: 'k4',
      author: 'Paolo Mendoza',
      handle: '@paolom',
      when: 'Yesterday',
      body: 'Ordered two for my sister. The code worked on Shopee, thanks!',
      likes: 4,
    ),
    FeedComment(
      id: 'k5',
      author: 'Kim Bautista',
      handle: '@kimb',
      when: '3 hours ago',
      body: 'Is the coffee coming to Lazada too?',
      likes: 1,
    ),
  ];
}
