import '../../../core/errors/result.dart';
import 'feed_post.dart';
import 'testimonial.dart';

/// What the brand posts, and what members say back.
abstract interface class CommunityRepository {
  Future<Result<List<FeedPost>>> posts();

  Future<Result<List<Testimonial>>> testimonials();
}
