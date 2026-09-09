import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/features/support/domain/support_chat.dart';
import 'package:happilab/features/support/presentation/support_chat_controller.dart';
import 'package:happilab/shared/domain/profile_photo.dart';

import '../../support/fake_photo_library.dart';

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

  group('SupportChatController photos', () {
    final clock = DateTime(2026, 9, 7, 15, 5);

    Future<File> fileOf(int bytes) async {
      final file = File('${Directory.systemTemp.path}/chat-photo-$bytes.jpg');
      await file.writeAsBytes(List.filled(bytes, 0));
      addTearDown(file.delete);
      return file;
    }

    SupportChatController build([FakePhotoLibrary? library]) {
      final controller = SupportChatController(
        now: () => clock,
        library: library,
        replyDelay: Duration.zero,
      );
      addTearDown(controller.dispose);
      return controller;
    }

    test('a photo within the limit goes out and is acknowledged', () async {
      final file = await fileOf(1024);
      final library = FakePhotoLibrary()..onAttach = (_) async => Success(file);
      final controller = build(library);

      final error = await controller.attachPhoto(PhotoSource.gallery);
      await pumpEventQueue();

      expect(error, isNull);
      expect(library.attachments, [PhotoSource.gallery]);
      // Sent, not worn: the profile picture is untouched.
      expect(library.stored, isNull);
      final sent = controller.messages[1];
      expect(sent.isFromMember, isTrue);
      expect(sent.text, isEmpty);
      expect(sent.photo?.file.path, file.path);
      expect(sent.photo?.bytes, 1024);
      expect(
        controller.messages.last.text,
        SupportChatCopy.photoAcknowledgement,
      );
    });

    test('a photo over the limit is refused and nothing goes out', () async {
      final file = await fileOf(ChatPhoto.maxBytes + 1);
      final controller = build(
        FakePhotoLibrary()..onAttach = (_) async => Success(file),
      );

      final error = await controller.attachPhoto(PhotoSource.camera);

      expect(error, isA<ValidationException>());
      expect(error?.message, contains('5 MB'));
      expect(controller.messages, hasLength(1));
    });

    test(
      'a source that will not open is reported; backing out is not',
      () async {
        final library = FakePhotoLibrary()
          ..onAttach = (_) async =>
              const Failure(UnknownException('Could not open the camera.'));
        final controller = build(library);

        expect(
          await controller.attachPhoto(PhotoSource.camera),
          isA<UnknownException>(),
        );

        library.onAttach = (_) async => const Success(null);
        expect(await controller.attachPhoto(PhotoSource.gallery), isNull);
        expect(controller.messages, hasLength(1));
      },
    );

    test('without a library, photos are unavailable', () async {
      final error = await build().attachPhoto(PhotoSource.gallery);

      expect(error?.message, SupportChatCopy.photosUnavailable);
    });
  });

  group('ChatPhoto', () {
    test('fits under five megabytes, and says so when it does not', () {
      expect(ChatPhoto.validate(ChatPhoto.maxBytes), isNull);
      expect(ChatPhoto.validate(ChatPhoto.maxBytes + 1), contains('5.0 MB'));
      expect(
        ChatPhoto.validate(8 * 1024 * 1024),
        'That photo is 8.0 MB; the most is 5 MB.',
      );
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
