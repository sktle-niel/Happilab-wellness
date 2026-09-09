import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/community/data/community_api.dart';

void main() {
  group('CommunityApi comment parsers', () {
    test('reads a thread with a reply under its comment', () {
      final comments = CommunityApi.parseComments([
        {
          'id': 'k1',
          'author': 'Ralph Yap',
          'handle': '@ralphy',
          'when': '2 days ago',
          'body': 'How does this hold up?',
          'likes': 18,
          'replies': [
            {
              'id': 'k2',
              'author': 'Jess Cruz',
              'when': '1 hour ago',
              'body': 'Still going strong.',
            },
          ],
        },
        {
          'id': 'k3',
          'author': 'Anna Jimenez',
          'when': 'Yesterday',
          'body': 'Need a tutorial!',
        },
      ]);

      expect(comments, hasLength(2));
      expect(comments.first.handle, '@ralphy');
      expect(comments.first.likes, 18);
      expect(comments.first.replies.single.handle, '@jesscruz');
      expect(comments.last.replies, isEmpty);
    });

    test('a written comment comes back as one line', () {
      final comment = CommunityApi.parseComment({
        'id': 'w1',
        'author': 'Ivy Santos',
        'when': 'Just now',
        'body': 'Thanks!',
      });

      expect(comment.id, 'w1');
      expect(comment.handle, '@ivysantos');
      expect(comment.likes, 0);
    });
  });
}
