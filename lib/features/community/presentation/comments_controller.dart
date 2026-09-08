import 'package:flutter/widgets.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/security/input_validator.dart';
import '../domain/community_repository.dart';
import '../domain/feed_comment.dart';

/// The thread under one post: what has been said, what is being typed, who
/// it is being said back to, and which lines the member has liked.
class CommentsController extends ChangeNotifier {
  CommentsController({required this._community, required this.postId});

  /// Long enough for a thought, short enough to stay a comment.
  static const int maxLength = 500;

  final CommunityRepository _community;
  final String postId;

  /// What is being typed. Its own listenable: a keystroke should redraw the
  /// send disc, not the thread.
  final TextEditingController draft = TextEditingController();

  List<FeedComment>? _comments;
  AppException? _error;
  FeedComment? _replyingTo;
  bool _isSending = false;
  bool _isDisposed = false;
  final Set<String> _liked = {};

  List<FeedComment>? get comments => _comments;
  AppException? get error => _error;

  /// The comment a reply is being written to, or null for a comment of
  /// the member's own.
  FeedComment? get replyingTo => _replyingTo;
  bool get isSending => _isSending;

  /// Every line in the thread, replies included.
  int get count => FeedComment.countAll(_comments ?? const []);

  /// Reads the thread; a failed read keeps its error for the sheet to show.
  Future<void> load() async {
    _error = null;
    final outcome = await _community.comments(postId);
    if (_isDisposed) return;
    outcome.fold((comments) => _comments = comments, (error) => _error = error);
    notifyListeners();
  }

  void replyTo(FeedComment? comment) {
    _replyingTo = comment;
    notifyListeners();
  }

  bool isLiked(FeedComment comment) => _liked.contains(comment.id);

  int likesOf(FeedComment comment) =>
      comment.likes + (isLiked(comment) ? 1 : 0);

  void toggleLike(FeedComment comment) {
    if (!_liked.remove(comment.id)) _liked.add(comment.id);
    notifyListeners();
  }

  /// Sends the draft. Answers the failure, for the sheet to word, or null
  /// once the line is in the thread.
  Future<AppException?> send() async {
    final body = InputValidator.sanitize(draft.text, maxLength: maxLength);
    if (body.isEmpty || _isSending) return null;
    _isSending = true;
    notifyListeners();
    final outcome = await _community.comment(
      postId,
      body,
      replyTo: _replyingTo?.id,
    );
    if (_isDisposed) return outcome.errorOrNull;
    _isSending = false;
    outcome.fold(_place, (_) {});
    notifyListeners();
    return outcome.errorOrNull;
  }

  /// A reply goes under its comment; a comment goes at the end.
  void _place(FeedComment written) {
    final thread = [...?_comments];
    final parent = _replyingTo;
    final at = parent == null
        ? -1
        : thread.indexWhere((comment) => comment.id == parent.id);
    if (at >= 0) {
      thread[at] = thread[at].withReply(written);
    } else {
      thread.add(written);
    }
    _comments = thread;
    _replyingTo = null;
    draft.clear();
  }

  @override
  void dispose() {
    _isDisposed = true;
    draft.dispose();
    super.dispose();
  }
}
