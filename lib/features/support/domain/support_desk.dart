import 'dart:io';

import '../../../core/errors/result.dart';
import 'support_chat.dart';

/// Where a chat stands with the desk, as the API names it.
enum ChatStatus {
  bot('bot'),
  queued('queued'),
  withAgent('with_agent'),
  ended('ended');

  const ChatStatus(this.wire);

  /// The name on the wire.
  final String wire;

  static ChatStatus fromWire(String name) =>
      values.firstWhere((status) => status.wire == name);
}

/// One chat as the desk holds it: where it stands, who is on it, and every
/// line said so far.
class SupportConversation {
  const SupportConversation({
    required this.id,
    required this.status,
    required this.messages,
    this.topic,
    this.agentName,
    this.queuePosition,
  });

  final String id;
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? topic;

  /// The person on the chat, once one has joined.
  final String? agentName;

  /// One-based place in line while queued; null otherwise.
  final int? queuePosition;

  bool get isEnded => status == ChatStatus.ended;
}

/// The desk, as the member reaches it.
///
/// Opening a chat puts the member in line at once. There is no push channel
/// yet, so the chat is read again while the screen shows it, and what the
/// desk said since comes back with the rest.
abstract interface class SupportDesk {
  /// Opens a chat with what the member first said: words, a photo, or both,
  /// under a topic when one was picked.
  Future<Result<SupportConversation>> open({
    String? topic,
    String? body,
    String? photoUrl,
  });

  /// The chat as it stands now, every line included.
  Future<Result<SupportConversation>> conversation(String id);

  /// Says something in the chat; one of the two must be given.
  Future<Result<ChatMessage>> send(String id, {String? body, String? photoUrl});

  /// Puts a picture where the desk can see it and answers its address.
  /// [bytes] is its size, already checked against [ChatPhoto.maxBytes].
  Future<Result<String>> uploadPhoto(File file, {required int bytes});
}
