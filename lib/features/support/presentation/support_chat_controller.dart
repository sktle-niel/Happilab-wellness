import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/security/input_validator.dart';
import '../../../shared/domain/profile_photo.dart';
import '../domain/open_chat.dart';
import '../domain/support_chat.dart';
import '../domain/support_desk.dart';

/// The conversation with support: what has been said and shown, what is
/// being typed, and where the chat stands with the desk.
///
/// The desk is the truth. The app says its greeting and, under a topic, the
/// first question back; every other line came from the desk, which is read
/// again every few seconds while the chat is open because there is no push
/// channel yet. A chat the member walked away from is still theirs: its id
/// is kept for the session and read back when the screen opens again.
class SupportChatController extends ChangeNotifier {
  SupportChatController({
    required this._desk,
    required this._openChat,
    this._library,
    DateTime Function()? now,
    this.pollEvery = const Duration(seconds: 6),
  }) : _now = now ?? DateTime.now {
    _greet();
    final id = _openChat.id;
    if (id != null) unawaited(_resume(id));
  }

  final SupportDesk _desk;
  final OpenChat _openChat;

  /// Where a photo to send comes from; null where the platform has none.
  final PhotoLibrary? _library;
  final DateTime Function() _now;

  /// How often an open chat is read for what the desk said since. Ten reads
  /// a minute leave room, in the desk's budget, for what the member sends.
  final Duration pollEvery;

  /// What is being typed. Its own listenable, deliberately: a keystroke
  /// should redraw the send button, not the thread.
  final TextEditingController draft = TextEditingController();

  final List<ChatMessage> _messages = [];
  final Set<String> _seen = {};
  String? _id;
  SupportConversation? _conversation;
  Timer? _poll;
  Future<void>? _reading;
  bool _isSending = false;
  bool _isAttaching = false;
  bool _isOffline = false;
  bool _isDisposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Handoff get handoff {
    final conversation = _conversation;
    if (conversation == null) return const NoAgent();
    return switch (conversation.status) {
      ChatStatus.bot => const NoAgent(),
      ChatStatus.queued => InLine(position: conversation.queuePosition ?? 1),
      ChatStatus.withAgent => WithAgent(
        SupportAgent(conversation.agentName ?? 'Support'),
      ),
      ChatStatus.ended => const ChatEnded(),
    };
  }

  bool get isEnded => _conversation?.isEnded ?? false;

  /// True from a line going out until the desk has it.
  bool get isSending => _isSending;

  /// True while a photo is being chosen and delivered; the button goes inert.
  bool get isAttaching => _isAttaching;

  /// True after a read the desk did not answer, until one it does.
  bool get isOffline => _isOffline;

  /// The openers show until something has been sent.
  bool get canChooseTopic => _id == null && !_isSending;

  /// Whether a line may be typed and sent right now.
  bool get canType => !isEnded && !_isSending;

  bool get canSend => canType && draft.text.trim().isNotEmpty;

  /// The agent on the line, when there is one.
  SupportAgent? get agent => switch (handoff) {
    WithAgent(agent: final agent) => agent,
    NoAgent() || InLine() || ChatEnded() => null,
  };

  /// Who the header names.
  String get counterpartName => agent?.name ?? SupportChatCopy.agentName;

  /// The line under the name.
  String get presenceLine {
    if (_isOffline) return SupportChatCopy.reconnecting;
    return switch (handoff) {
      NoAgent() => SupportChatCopy.status,
      InLine(position: final position) => SupportChatCopy.inLineStatus(
        position,
      ),
      WithAgent() => SupportChatCopy.agentStatus,
      ChatEnded() => SupportChatCopy.endedStatus,
    };
  }

  /// Opens the conversation on [topic], in the member's words, and asks the
  /// first question back while the desk is reached.
  Future<AppException?> choose(SupportTopic topic) {
    if (!canChooseTopic) return Future.value();
    return _deliver(
      topic: topic.label,
      body: topic.opener,
      followUp: topic.followUp,
    );
  }

  /// Sends what is in the composer, if anything. Answers the failure, for
  /// the screen to word, or null once the line is in the thread; the draft
  /// stays until then, so a refused line is not lost.
  Future<AppException?> sendDraft() async {
    final text = InputValidator.sanitize(draft.text);
    if (text.isEmpty || !canType) return null;
    final error = await _deliver(body: text);
    if (error == null && !_isDisposed) draft.clear();
    return error;
  }

  /// Opens [source] and sends what the member picks as a photo, when it is
  /// within the limit. Answers the failure for the screen to word — too
  /// heavy, a source that will not open, a desk that will not take it — or
  /// null; backing out is null too.
  Future<AppException?> attachPhoto(PhotoSource source) async {
    final library = _library;
    if (library == null) {
      return const UnknownException(SupportChatCopy.photosUnavailable);
    }
    if (_isAttaching || !canType) return null;
    _setAttaching(true);
    try {
      final handed = await library.attach(source);
      final file = handed.valueOrNull;
      if (file == null) return handed.errorOrNull;
      final int bytes;
      try {
        bytes = await file.length();
      } on FileSystemException {
        return const UnknownException('Could not read that photo.');
      }
      final refusal = ChatPhoto.validate(bytes);
      if (refusal != null) return ValidationException(refusal);
      final uploaded = await _desk.uploadPhoto(file, bytes: bytes);
      final url = uploaded.valueOrNull;
      if (url == null) return uploaded.errorOrNull;
      return await _deliver(photoUrl: url);
    } finally {
      _setAttaching(false);
    }
  }

  /// After the desk has closed the chat: the greeting again, and the openers.
  void startNewChat() {
    if (!isEnded) return;
    _stopPolling();
    _openChat.forget();
    _id = null;
    _conversation = null;
    _messages.clear();
    _seen.clear();
    _greet();
  }

  /// Reads the chat again for what the desk said since. One read at a time:
  /// a tick that lands while one is out is skipped, not queued.
  Future<void> refresh() =>
      _reading ??= _read().whenComplete(() => _reading = null);

  Future<void> _read() async {
    final id = _id;
    if (id == null) return;
    final outcome = await _desk.conversation(id);
    if (_isDisposed) return;
    outcome.fold(_absorb, _lost);
  }

  /// The chat the member left earlier, read back in place of a fresh start.
  Future<void> _resume(String id) {
    _id = id;
    return refresh();
  }

  /// Opens the chat with its first line, or says one more in it. What the
  /// desk answers goes into the thread; a refusal comes back for the screen.
  Future<AppException?> _deliver({
    String? topic,
    String? body,
    String? photoUrl,
    String? followUp,
  }) async {
    _setSending(true);
    final id = _id;
    final AppException? error;
    if (id == null) {
      final opened = await _desk.open(
        topic: topic,
        body: body,
        photoUrl: photoUrl,
      );
      if (_isDisposed) return opened.errorOrNull;
      error = opened.errorOrNull;
      final conversation = opened.valueOrNull;
      if (conversation != null) {
        _absorb(conversation);
        if (followUp != null) _say(followUp, from: const BotSender());
        if (conversation.status == ChatStatus.queued) {
          _say(SupportChatCopy.inLine(conversation.queuePosition ?? 1));
        }
      }
    } else {
      final sent = await _desk.send(id, body: body, photoUrl: photoUrl);
      if (_isDisposed) return sent.errorOrNull;
      error = sent.errorOrNull;
      final line = sent.valueOrNull;
      if (line != null) _place(line);
    }
    _setSending(false);
    return error;
  }

  /// The chat as the desk holds it now: its standing, and every line the
  /// thread does not have yet.
  void _absorb(SupportConversation conversation) {
    _isOffline = false;
    _id = conversation.id;
    _conversation = conversation;
    conversation.messages.forEach(_place);
    if (conversation.isEnded) {
      _stopPolling();
      _openChat.forget();
    } else {
      _openChat.id = conversation.id;
      _startPolling();
    }
    notifyListeners();
  }

  /// A read the desk refused. A chat it no longer has is let go; anything
  /// else is a bad moment, tried again on the next tick.
  void _lost(AppException error) {
    if (error is ClientException && error.statusCode == 404) {
      _stopPolling();
      _openChat.forget();
      _id = null;
      _conversation = null;
    } else {
      _isOffline = true;
      _startPolling();
    }
    notifyListeners();
  }

  /// A line from the desk, once: the member's own send and the next read
  /// both carry it.
  void _place(ChatMessage line) {
    final id = line.id;
    if (id != null && !_seen.add(id)) return;
    _messages.add(line);
  }

  void _greet() => _say(SupportChatCopy.greeting, from: const BotSender());

  void _say(String text, {ChatSender from = const SystemSender()}) {
    _messages.add(ChatMessage(text: text, sentAt: _now(), sender: from));
    notifyListeners();
  }

  void _startPolling() =>
      _poll ??= Timer.periodic(pollEvery, (_) => unawaited(refresh()));

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  void _setSending(bool sending) {
    if (_isDisposed) return;
    _isSending = sending;
    notifyListeners();
  }

  void _setAttaching(bool attaching) {
    if (_isDisposed) return;
    _isAttaching = attaching;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopPolling();
    draft.dispose();
    super.dispose();
  }
}
