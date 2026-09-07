import 'package:flutter/material.dart';

import '../../domain/support_chat.dart';
import 'chat_bubble.dart';

/// The messages, newest at the bottom. Reversed, so the latest is always in
/// view whatever the keyboard does, and built lazily: a long thread costs
/// only the rows on screen.
class ChatThread extends StatelessWidget {
  const ChatThread({
    required this.messages,
    required this.isSupportTyping,
    required this.responder,
    super.key,
  });

  final List<ChatMessage> messages;
  final bool isSupportTyping;

  /// Whose dots show while a reply is being typed — the bot or the agent.
  final ChatSender responder;

  /// One row per message, the day pill above them all, and the typing dots
  /// below them while a reply is being typed.
  int get _rowCount => messages.length + 1 + (isSupportTyping ? 1 : 0);

  /// A time is shown over the first message of each minute.
  bool _startsMinute(int index) =>
      index == 0 || !messages[index].sharesMinuteWith(messages[index - 1]);

  /// A face goes beside the last message of a run from one sender. While a
  /// reply is being typed, its dots close the responder's run, not its last
  /// message.
  bool _endsRun(int index) {
    final message = messages[index];
    if (index < messages.length - 1) {
      return !message.sender.isSameAs(messages[index + 1].sender);
    }
    return !isSupportTyping || !message.sender.isSameAs(responder);
  }

  /// Row 0 is the bottom of the thread. Keyed to the message, so the list
  /// shifting as one lands only rises the new row in.
  Widget _row(BuildContext context, int row) {
    var slot = row;
    if (isSupportTyping) {
      if (slot == 0) {
        return TypingBubble(key: const ValueKey('typing'), sender: responder);
      }
      slot -= 1;
    }
    if (slot == messages.length) {
      return const DayPill(key: ValueKey('day'), label: 'Today');
    }
    final index = messages.length - 1 - slot;
    final message = messages[index];
    return _MessageRow(
      key: ValueKey(message),
      message: message,
      showsTime: _startsMinute(index),
      showsAvatar: _endsRun(index),
    );
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
    reverse: true,
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    itemCount: _rowCount,
    itemBuilder: _row,
  );
}

/// One message, with the minute over it when it opens a new one — or a
/// note about the conversation, which carries neither time nor face.
class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.showsTime,
    required this.showsAvatar,
    super.key,
  });

  final ChatMessage message;
  final bool showsTime;
  final bool showsAvatar;

  @override
  Widget build(BuildContext context) {
    if (message.isNote) return SystemNote(text: message.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showsTime)
          TimeLabel(time: message.sentAt, atEnd: message.isFromMember),
        ChatBubble(message: message, showsAvatar: showsAvatar),
      ],
    );
  }
}
