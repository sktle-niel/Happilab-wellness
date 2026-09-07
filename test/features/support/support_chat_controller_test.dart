import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/support/domain/support_chat.dart';
import 'package:happilab/features/support/presentation/support_chat_controller.dart';

/// A desk with a known line and a known person on it.
final class _FixedDesk implements SupportDesk {
  _FixedDesk({required this.ahead});

  static const SupportAgent maria = SupportAgent('Maria');

  final int ahead;

  @override
  int queueLength() => ahead;

  @override
  SupportAgent nextAgent() => maria;
}

void main() {
  group('SupportChatController', () {
    final clock = DateTime(2026, 9, 7, 15, 5);

    SupportChatController build({int ahead = 0}) {
      final controller = SupportChatController(
        now: () => clock,
        desk: _FixedDesk(ahead: ahead),
        replyDelay: Duration.zero,
        linePace: Duration.zero,
        joinDelay: Duration.zero,
      );
      addTearDown(controller.dispose);
      return controller;
    }

    List<String> textsOf(SupportChatController controller) =>
        controller.messages.map((m) => m.text).toList();

    test('opens with the bot saying hello', () {
      final controller = build();

      expect(controller.messages, hasLength(1));
      expect(controller.messages.single.text, SupportChatCopy.greeting);
      expect(controller.messages.single.sender, isA<BotSender>());
      expect(controller.handoff, isA<NoAgent>());
      expect(controller.canSend, isFalse);
    });

    test('a topic is sent in the member\'s words and answered', () async {
      final controller = build();

      controller.choose(SupportTopic.cashOut);
      expect(controller.isSupportTyping, isTrue);
      await pumpEventQueue();

      expect(textsOf(controller), contains(SupportTopic.cashOut.opener));
      expect(textsOf(controller).last, SupportTopic.cashOut.followUp);
      expect(controller.messages.last.sender, isA<BotSender>());
      expect(controller.isSupportTyping, isFalse);
    });

    test('a typed message goes out trimmed and is acknowledged', () async {
      final controller = build()..draft.text = '  My referral link is broken  ';
      expect(controller.canSend, isTrue);

      controller.sendDraft();
      await pumpEventQueue();

      expect(controller.draft.text, isEmpty);
      expect(controller.messages[1].text, 'My referral link is broken');
      expect(controller.messages[1].isFromMember, isTrue);
      expect(textsOf(controller).last, SupportChatCopy.acknowledgement);
    });

    test('an empty draft sends nothing', () {
      final controller = build()..draft.text = '   ';

      controller.sendDraft();

      expect(controller.messages, hasLength(1));
      expect(controller.isSupportTyping, isFalse);
    });

    test('the agent command brings a free agent straight in', () async {
      final controller = build()..draft.text = '/Agent';

      controller.sendDraft();
      await pumpEventQueue();

      final texts = textsOf(controller);
      expect(texts, contains(SupportChatCopy.requestingAgent));
      expect(texts, contains(SupportChatCopy.joined(_FixedDesk.maria)));
      expect(texts.last, _FixedDesk.maria.greeting);
      expect(controller.messages.last.sender, isA<AgentSender>());
      expect(controller.handoff, isA<WithAgent>());
      expect(controller.counterpartName, 'Maria');
      expect(controller.presenceLine, SupportChatCopy.agentStatus);
    });

    test('a busy desk gives a place in line that counts down', () async {
      final controller = build(ahead: 2)..requestAgent();

      expect(controller.handoff, isA<InLine>());
      expect(controller.presenceLine, SupportChatCopy.inLineStatus(2));
      expect(textsOf(controller), contains(SupportChatCopy.inLine(2)));

      await pumpEventQueue();

      final texts = textsOf(controller);
      expect(texts, contains(SupportChatCopy.inLine(1)));
      expect(texts, contains(SupportChatCopy.joined(_FixedDesk.maria)));
      expect(controller.handoff, isA<WithAgent>());
    });

    test('with an agent on the line, the agent answers, not the bot', () async {
      final controller = build()..requestAgent();
      await pumpEventQueue();

      controller.choose(SupportTopic.points);
      await pumpEventQueue();

      expect(textsOf(controller).last, SupportChatCopy.agentReplies.first);
      expect(controller.messages.last.sender, isA<AgentSender>());
    });

    test('ending the chat hands back to the bot', () async {
      final controller = build()..requestAgent();
      await pumpEventQueue();

      controller.endAgentChat();
      expect(controller.handoff, isA<NoAgent>());
      expect(textsOf(controller).last, SupportChatCopy.ended(_FixedDesk.maria));

      controller.choose(SupportTopic.other);
      await pumpEventQueue();
      expect(textsOf(controller).last, SupportTopic.other.followUp);
      expect(controller.messages.last.sender, isA<BotSender>());
    });

    test('asking twice does nothing more', () {
      final controller = build(ahead: 1)..requestAgent();
      final count = controller.messages.length;

      controller.requestAgent();

      expect(controller.messages, hasLength(count));
    });
  });

  group('ChatMessage', () {
    test('shares a minute only with a message from the same minute', () {
      final at = DateTime(2026, 9, 7, 15, 5, 10);
      const member = MemberSender();
      final same = ChatMessage(text: 'a', sentAt: at, sender: member);
      final later = ChatMessage(
        text: 'b',
        sentAt: at.add(const Duration(seconds: 40)),
        sender: member,
      );
      final next = ChatMessage(
        text: 'c',
        sentAt: at.add(const Duration(minutes: 1)),
        sender: member,
      );

      expect(same.sharesMinuteWith(later), isTrue);
      expect(same.sharesMinuteWith(next), isFalse);
    });
  });
}
