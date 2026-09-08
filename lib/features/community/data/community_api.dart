import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/domain/catalogue.dart';
import '../domain/community_repository.dart';
import '../domain/feed_post.dart';
import '../domain/testimonial.dart';

/// [CommunityRepository] over the API. Both feeds are cached briefly: a
/// member flicking between tabs should not refetch the same posts.
final class CommunityApi implements CommunityRepository {
  const CommunityApi(this._client);

  static const Duration _maxAge = Duration(minutes: 2);

  final ApiClient _client;

  @override
  Future<Result<List<FeedPost>>> posts() =>
      _client.get(ApiEndpoints.feed, parse: parsePosts, maxAge: _maxAge);

  @override
  Future<Result<List<Testimonial>>> testimonials() => _client.get(
    ApiEndpoints.testimonials,
    parse: parseTestimonials,
    maxAge: _maxAge,
  );

  static List<FeedPost> parsePosts(Object? json) => JsonReader.listOf(
    json,
    (item) => FeedPost(
      author: item.string('author'),
      when: item.string('when'),
      body: item.string('body'),
      media: item.enumerated('media', PostMedia.values),
      mediaUrl: item.optionalString('media_url'),
      likes: item.integer('likes'),
      comments: item.integer('comments'),
    ),
  );

  static List<Testimonial> parseTestimonials(Object? json) =>
      JsonReader.listOf(json, _testimonial);

  static Testimonial _testimonial(JsonReader item) {
    final source = item.optionalString('source');
    return Testimonial(
      name: item.string('name'),
      credential: item.string('credential'),
      date: item.string('date'),
      headline: item.optionalString('headline'),
      quote: item.optionalString('quote'),
      videoAsset: item.optionalString('video_url'),
      source: source == null
          ? null
          : item.enumerated('source', SharePlatform.values),
      rating: item.optionalInteger('rating') ?? 5,
    );
  }
}
