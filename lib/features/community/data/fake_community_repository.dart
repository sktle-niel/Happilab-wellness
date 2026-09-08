import '../../../core/errors/result.dart';
import '../domain/community_repository.dart';
import '../domain/feed_post.dart';
import '../domain/testimonial.dart';

/// The bundled feed and stories, until the API serves them.
final class FakeCommunityRepository implements CommunityRepository {
  const FakeCommunityRepository();

  @override
  Future<Result<List<FeedPost>>> posts() async =>
      const Success(FeedPost.placeholder);

  @override
  Future<Result<List<Testimonial>>> testimonials() async =>
      const Success(Testimonial.placeholder);
}
