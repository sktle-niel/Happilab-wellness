import 'dart:io';
import 'dart:math';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../domain/support_chat.dart';
import '../domain/support_desk.dart';

/// Stands in for the desk until the API is bound: a short line as often as
/// none, one of a few names on the other end, and a chat that moves one step
/// every time it is read — the way the real one moves between polls.
final class FakeSupportDesk implements SupportDesk {
  FakeSupportDesk({Random? random, DateTime Function()? clock})
    : _random = random ?? Random(),
      _now = clock ?? DateTime.now;

  static const List<SupportAgent> agents = [
    SupportAgent('Maria'),
    SupportAgent('Paolo'),
    SupportAgent('Jen'),
  ];

  /// What the agent says while a real answer is being worked out, in turn;
  /// once through them, the agent marks the chat resolved.
  static const List<String> replies = [
    'Got it — let me check that for you.',
    'Thanks, one moment while I look into it.',
    'Understood, I am on it. I will be right back with an answer.',
  ];

  /// The line is never longer than this.
  static const int longestLine = 3;

  final Random _random;
  final DateTime Function() _now;
  final Map<String, _Chat> _chats = {};
  int _ids = 0;

  @override
  Future<Result<SupportConversation>> open({
    String? topic,
    String? body,
    String? photoUrl,
  }) async {
    final chat = _Chat(
      id: 'chat-${++_ids}',
      topic: topic,
      position: 1 + _random.nextInt(longestLine),
      agent: agents[_random.nextInt(agents.length)],
    );
    _chats[chat.id] = chat;
    if (body != null || photoUrl != null) {
      _say(chat, const MemberSender(), body ?? '', photoUrl);
    }
    return Success(chat.snapshot());
  }

  @override
  Future<Result<SupportConversation>> conversation(String id) async {
    final chat = _chats[id];
    if (chat == null) return const Failure(ClientException(404, 'Not found.'));
    _advance(chat);
    return Success(chat.snapshot());
  }

  @override
  Future<Result<ChatMessage>> send(
    String id, {
    String? body,
    String? photoUrl,
  }) async {
    final chat = _chats[id];
    if (chat == null) return const Failure(ClientException(404, 'Not found.'));
    if (chat.status == ChatStatus.ended) {
      return const Failure(
        ClientException(400, 'That chat has ended. Open a new one.'),
      );
    }
    if (body == null && photoUrl == null) {
      return const Failure(
        ClientException(400, 'Say something, or send a photo.'),
      );
    }
    chat.awaitingReply = true;
    return Success(_say(chat, const MemberSender(), body ?? '', photoUrl));
  }

  /// The picture stays where it is; its address on this device is enough.
  @override
  Future<Result<String>> uploadPhoto(File file, {required int bytes}) async =>
      Success(file.absolute.uri.toString());

  /// One step of the desk: the line moves, then the agent joins, then the
  /// agent answers whatever the member said since.
  void _advance(_Chat chat) {
    switch (chat.status) {
      case ChatStatus.queued:
        chat.position -= 1;
        if (chat.position > 0) return;
        chat.status = ChatStatus.withAgent;
        chat.awaitingReply = false;
        _say(chat, const SystemSender(), '${chat.agent.name} joined the chat.');
        _say(
          chat,
          AgentSender(chat.agent),
          'Hi, I am ${chat.agent.name} from Falcon Crest support. I have '
          'read the thread — how can I help?',
        );
      case ChatStatus.withAgent:
        if (chat.awaitingReply) {
          chat.awaitingReply = false;
          _say(chat, AgentSender(chat.agent), replies[chat.replies++]);
        } else if (chat.replies >= replies.length) {
          chat.status = ChatStatus.ended;
          _say(
            chat,
            const SystemSender(),
            'Marked resolved by ${chat.agent.name}.',
          );
        }
      case ChatStatus.bot || ChatStatus.ended:
        return;
    }
  }

  ChatMessage _say(_Chat chat, ChatSender sender, String text, [String? url]) {
    final line = ChatMessage(
      id: 'line-${++_ids}',
      text: text,
      sentAt: _now(),
      sender: sender,
      photo: url == null ? null : ChatPhoto(Uri.parse(url)),
    );
    chat.messages.add(line);
    return line;
  }
}

class _Chat {
  _Chat({
    required this.id,
    required this.topic,
    required this.position,
    required this.agent,
  });

  final String id;
  final String? topic;
  final SupportAgent agent;
  final List<ChatMessage> messages = [];
  ChatStatus status = ChatStatus.queued;
  int position;
  int replies = 0;
  bool awaitingReply = false;

  SupportConversation snapshot() => SupportConversation(
    id: id,
    status: status,
    topic: topic,
    agentName: status == ChatStatus.queued ? null : agent.name,
    queuePosition: status == ChatStatus.queued ? position : null,
    messages: List.unmodifiable(messages),
  );
}
