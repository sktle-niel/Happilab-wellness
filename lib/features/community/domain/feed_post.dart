/// What a post carries above its text.
enum PostMedia { none, image, video }

/// A post in the news feed.
class FeedPost {
  const FeedPost({
    required this.author,
    required this.when,
    required this.body,
    required this.media,
    required this.likes,
    required this.comments,
    this.mediaUrl,
  });

  final String author;
  final String when;
  final String body;
  final PostMedia media;

  /// Asset path for a video, remote URL for an image.
  final String? mediaUrl;
  final int likes;
  final int comments;

  static const String _brand = 'Falcon Crest Ventures';

  static const List<FeedPost> placeholder = [
    FeedPost(
      author: _brand,
      when: 'Just now',
      body:
          'New batch of Sakura Glow Soap is in. Share your code this week — '
          'every order counts double toward your streak.',
      media: PostMedia.video,
      mediaUrl: 'assets/video/onboarding-routine.mp4',
      likes: 128,
      comments: 14,
    ),
    FeedPost(
      author: _brand,
      when: '2 hours ago',
      body:
          'Sunscreen SPF50 restocked. It is the easiest first product to '
          'recommend to a friend who is new to the routine.',
      media: PostMedia.image,
      mediaUrl: 'https://images.unsplash.com/photo-1526947425960-945c6e72858f?w=800&q=80',
      likes: 86,
      comments: 9,
    ),
    FeedPost(
      author: _brand,
      when: 'Yesterday',
      body:
          'Payouts now land within 24 hours for GCash and Maya. Nothing to '
          'do on your side — it is already live.',
      media: PostMedia.none,
      likes: 204,
      comments: 31,
    ),
  ];
}
