import '../../../core/errors/result.dart';
import 'feed_comment.dart';
import 'feed_post.dart';
import 'testimonial.dart';

/// What the brand posts, and what members say back.
abstract interface class CommunityRepository {
  Future<Result<List<FeedPost>>> posts();

  Future<Result<List<Testimonial>>> testimonials();

  /// What members said under the post, oldest first, replies under their
  /// comment.
  Future<Result<List<FeedComment>>> comments(String postId);

  /// Says [body] under the post — or back to [replyTo] — in the member's
  /// name, and answers it as kept.
  Future<Result<FeedComment>> comment(
    String postId,
    String body, {
    String? replyTo,
  });
}
