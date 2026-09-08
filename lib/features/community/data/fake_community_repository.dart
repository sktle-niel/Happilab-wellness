import '../../../core/errors/result.dart';
import '../domain/community_repository.dart';
import '../domain/feed_comment.dart';
import '../domain/feed_post.dart';
import '../domain/testimonial.dart';

/// The bundled feed and stories, until the API serves them. Comments are
/// remembered for the session, so a line the member writes is still there
/// when the sheet opens again.
final class FakeCommunityRepository implements CommunityRepository {
  FakeCommunityRepository({this.memberName = 'Ivy Santos'});

  /// Who signs what the member writes.
  final String memberName;

  final Map<String, List<FeedComment>> _comments = {};
  int _written = 0;

  @override
  Future<Result<List<FeedPost>>> posts() async =>
      const Success(FeedPost.placeholder);

  @override
  Future<Result<List<Testimonial>>> testimonials() async =>
      const Success(Testimonial.placeholder);

  @override
  Future<Result<List<FeedComment>>> comments(String postId) async =>
      Success(List.unmodifiable(_thread(postId)));

  @override
  Future<Result<FeedComment>> comment(
    String postId,
    String body, {
    String? replyTo,
  }) async {
    final written = FeedComment(
      id: 'w${++_written}',
      author: memberName,
      handle: FeedComment.handleFor(memberName),
      when: 'Just now',
      body: body,
    );
    final thread = _thread(postId);
    final parent = thread.indexWhere((comment) => comment.id == replyTo);
    if (parent >= 0) {
      thread[parent] = thread[parent].withReply(written);
    } else {
      thread.add(written);
    }
    return Success(written);
  }

  /// The first post carries the bundled thread; the rest start empty.
  List<FeedComment> _thread(String postId) => _comments.putIfAbsent(
    postId,
    () => [
      if (postId == FeedPost.placeholder.first.id) ...FeedComment.placeholder,
    ],
  );
}
