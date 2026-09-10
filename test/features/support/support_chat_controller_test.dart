import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/features/support/data/fake_support_desk.dart';
import 'package:happilab/features/support/domain/open_chat.dart';
import 'package:happilab/features/support/domain/support_chat.dart';
import 'package:happilab/features/support/domain/support_desk.dart';
import 'package:happilab/features/support/presentation/support_chat_controller.dart';
import 'package:happilab/shared/domain/profile_photo.dart';

import '../../support/fake_photo_library.dart';
import '../../support/fixed_random.dart';

/// A desk that refuses everything with one failure.
final class _RefusingDesk implements SupportDesk {
  const _RefusingDesk(this.failure);

  final AppException failure;

  @override
  Future<Result<SupportConversation>> open({
    String? topic,
    String? body,
    String? photoUrl,
  }) async => Failure(failure);

  @override
  Future<Result<SupportConversation>> conversation(String id) async =>
      Failure(failure);

  @override
  Future<Result<ChatMessage>> send(
    String id, {
    String? body,
    String? photoUrl,
  }) async => Failure(failure);

  @override
  Future<Result<String>> uploadPhoto(File file, {required int bytes}) async =>
      Failure(failure);
}

/// The fake desk, with one read that can be made to fail.
final class _FlakyDesk implements SupportDesk {
  final FakeSupportDesk _desk = FakeSupportDesk(random: const FixedRandom(0));

  AppException? readFailure;

  @override
  Future<Result<SupportConversation>> open({
    String? topic,
    String? body,
    String? photoUrl,
  }) => _desk.open(topic: topic, body: body, photoUrl: photoUrl);

  @override
  Future<Result<SupportConversation>> conversation(String id) async {
    final failure = readFailure;
    if (failure != null) return Failure(failure);
    return _desk.conversation(id);
  }

  @override
  Future<Result<ChatMessage>> send(
    String id, {
    String? body,
    String? photoUrl,
  }) => _desk.send(id, body: body, photoUrl: photoUrl);

  @override
  Future<Result<String>> uploadPhoto(File file, {required int bytes}) =>
      _desk.uploadPhoto(file, bytes: bytes);
}

void main() {
  final clock = DateTime(2026, 9, 7, 15, 5);

  List<String> textsOf(SupportChatController controller) =>
      controller.messages.map((m) => m.text).toList();

  group('SupportChatController', () {
    /// [line] picks the fake's draw: 0 is first in line with Maria, 0.5 is
    /// second with Paolo.
    SupportChatController build({
      double line = 0,
      SupportDesk? desk,
      OpenChat? openChat,
    }) {
      final controller = SupportChatController(
        desk: desk ?? FakeSupportDesk(random: FixedRandom(line)),
        openChat: openChat ?? OpenChat(),
        now: () => clock,
      );
      addTearDown(controller.dispose);
      return controller;
    }

    test('opens with the bot saying hello and the openers', () {
      final controller = build();

      expect(controller.messages, hasLength(1));
      expect(controller.messages.single.text, SupportChatCopy.greeting);
      expect(controller.messages.single.sender, isA<BotSender>());
      expect(controller.handoff, isA<NoAgent>());
      expect(controller.canChooseTopic, isTrue);
      expect(controller.canSend, isFalse);
      expect(controller.presenceLine, SupportChatCopy.status);
    });

    test('a topic opens the chat in the member\'s words', () async {
      final openChat = OpenChat();
      final controller = build(line: 0.5, openChat: openChat);

      expect(await controller.choose(SupportTopic.cashOut), isNull);

      expect(textsOf(controller), [
        SupportChatCopy.greeting,
        SupportTopic.cashOut.opener,
        SupportTopic.cashOut.followUp,
        SupportChatCopy.inLine(2),
      ]);
      expect(controller.messages[1].isFromMember, isTrue);
      expect(controller.messages[2].sender, isA<BotSender>());
      expect(controller.messages[3].isNote, isTrue);
      expect(controller.handoff, isA<InLine>());
      expect(controller.presenceLine, SupportChatCopy.inLineStatus(2));
      expect(controller.canChooseTopic, isFalse);
      expect(openChat.id, isNotNull);
    });

    test(
      'a typed line opens the chat and the draft clears once it is in',
      () async {
        final controller = build()
          ..draft.text = '  My referral link is broken  ';
        expect(controller.canSend, isTrue);

        expect(await controller.sendDraft(), isNull);

        expect(controller.draft.text, isEmpty);
        expect(controller.messages[1].text, 'My referral link is broken');
        expect(controller.messages[1].isFromMember, isTrue);
        expect(textsOf(controller).last, SupportChatCopy.inLine(1));
      },
    );

    test('an empty draft sends nothing', () async {
      final controller = build()..draft.text = '   ';

      await controller.sendDraft();

      expect(controller.messages, hasLength(1));
      expect(controller.handoff, isA<NoAgent>());
    });

    test('each read moves the line until an agent joins', () async {
      final controller = build(line: 0.5);
      await controller.choose(SupportTopic.points);

      await controller.refresh();
      expect(controller.presenceLine, SupportChatCopy.inLineStatus(1));

      await controller.refresh();
      expect(controller.handoff, isA<WithAgent>());
      expect(controller.counterpartName, 'Paolo');
      expect(controller.presenceLine, SupportChatCopy.agentStatus);
      expect(textsOf(controller), contains('Paolo joined the chat.'));
      expect(controller.messages.last.sender, isA<AgentSender>());
    });

    test('the agent answers each line, then closes the chat', () async {
      final openChat = OpenChat();
      final controller = build(openChat: openChat);
      await controller.choose(SupportTopic.other);
      await controller.refresh();
      expect(controller.handoff, isA<WithAgent>());

      for (final reply in FakeSupportDesk.replies) {
        controller.draft.text = 'More detail';
        await controller.sendDraft();
        await controller.refresh();
        expect(textsOf(controller).last, reply);
        expect(controller.messages.last.sender, isA<AgentSender>());
      }

      await controller.refresh();
      expect(controller.handoff, isA<ChatEnded>());
      expect(controller.canType, isFalse);
      expect(controller.presenceLine, SupportChatCopy.endedStatus);
      expect(textsOf(controller).last, 'Marked resolved by Maria.');
      expect(openChat.id, isNull);

      controller.draft.text = 'One more';
      final count = controller.messages.length;
      expect(await controller.sendDraft(), isNull);
      expect(controller.messages, hasLength(count));

      controller.startNewChat();
      expect(textsOf(controller), [SupportChatCopy.greeting]);
      expect(controller.handoff, isA<NoAgent>());
      expect(controller.canChooseTopic, isTrue);
    });

    test('a chat kept from earlier is read back, not started over', () async {
      final desk = FakeSupportDesk(random: const FixedRandom(0.5));
      final openChat = OpenChat();
      final earlier = build(desk: desk, openChat: openChat);
      await earlier.choose(SupportTopic.account);

      final later = build(desk: desk, openChat: openChat);
      await pumpEventQueue();

      expect(textsOf(later), contains(SupportTopic.account.opener));
      expect(later.handoff, isA<InLine>());
      expect(later.canChooseTopic, isFalse);
    });

    test('a refused line keeps the draft and says why', () async {
      const refusal = ServerException(503, 'The desk is closed.');
      final controller = build(desk: const _RefusingDesk(refusal))
        ..draft.text = 'Hello?';

      expect(await controller.sendDraft(), refusal);

      expect(controller.draft.text, 'Hello?');
      expect(controller.messages, hasLength(1));
      expect(controller.handoff, isA<NoAgent>());
    });

    test('a read the desk did not answer reads as reconnecting', () async {
      final desk = _FlakyDesk();
      final controller = build(desk: desk);
      await controller.choose(SupportTopic.payout);

      desk.readFailure = const NetworkException();
      await controller.refresh();
      expect(controller.isOffline, isTrue);
      expect(controller.presenceLine, SupportChatCopy.reconnecting);

      desk.readFailure = null;
      await controller.refresh();
      expect(controller.isOffline, isFalse);
      expect(controller.handoff, isA<WithAgent>());
    });

    test('a chat the desk no longer has is let go', () async {
      final desk = _FlakyDesk();
      final openChat = OpenChat();
      final controller = build(desk: desk, openChat: openChat);
      await controller.choose(SupportTopic.referral);

      desk.readFailure = const ClientException(404, 'Not found.');
      await controller.refresh();

      expect(openChat.id, isNull);
      expect(controller.handoff, isA<NoAgent>());
      expect(controller.canChooseTopic, isTrue);
    });
  });

  group('SupportChatController photos', () {
    Future<File> fileOf(int bytes) async {
      final file = File('${Directory.systemTemp.path}/chat-photo-$bytes.jpg');
      await file.writeAsBytes(List.filled(bytes, 0));
      addTearDown(file.delete);
      return file;
    }

    SupportChatController build({
      FakePhotoLibrary? library,
      SupportDesk? desk,
    }) {
      final controller = SupportChatController(
        desk: desk ?? FakeSupportDesk(random: const FixedRandom(0)),
        openChat: OpenChat(),
        library: library,
        now: () => clock,
      );
      addTearDown(controller.dispose);
      return controller;
    }

    test('a photo within the limit opens the chat with its picture', () async {
      final file = await fileOf(1024);
      final library = FakePhotoLibrary()..onAttach = (_) async => Success(file);
      final controller = build(library: library);

      final error = await controller.attachPhoto(PhotoSource.gallery);

      expect(error, isNull);
      expect(library.attachments, [PhotoSource.gallery]);
      // Sent, not worn: the profile picture is untouched.
      expect(library.stored, isNull);
      final sent = controller.messages[1];
      expect(sent.isFromMember, isTrue);
      expect(sent.text, isEmpty);
      expect(sent.photo?.isLocal, isTrue);
      expect(sent.photo?.uri, file.absolute.uri);
      expect(textsOf(controller).last, SupportChatCopy.inLine(1));
      expect(controller.isAttaching, isFalse);
    });

    test('a photo over the limit is refused and nothing goes out', () async {
      final file = await fileOf(ChatPhoto.maxBytes + 1);
      final controller = build(
        library: FakePhotoLibrary()..onAttach = (_) async => Success(file),
      );

      final error = await controller.attachPhoto(PhotoSource.camera);

      expect(error, isA<ValidationException>());
      expect(error?.message, contains('5 MB'));
      expect(controller.messages, hasLength(1));
    });

    test('a desk that will not take the photo says so', () async {
      final file = await fileOf(1024);
      const refusal = ServerException(503, 'Uploads are not configured.');
      final controller = build(
        library: FakePhotoLibrary()..onAttach = (_) async => Success(file),
        desk: const _RefusingDesk(refusal),
      );

      expect(await controller.attachPhoto(PhotoSource.gallery), refusal);
      expect(controller.messages, hasLength(1));
    });

    test(
      'a source that will not open is reported; backing out is not',
      () async {
        final library = FakePhotoLibrary()
          ..onAttach = (_) async =>
              const Failure(UnknownException('Could not open the camera.'));
        final controller = build(library: library);

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
      expect(ChatPhoto.validate(ChatPhoto.maxBytes + 1), contains('5.1 MB'));
      expect(
        ChatPhoto.validate(8 * 1024 * 1024),
        'That photo is 8.0 MB; the most is 5 MB.',
      );
    });

    test('knows a picture still on the device from one at an address', () {
      expect(ChatPhoto(Uri.file('/tmp/a.jpg')).isLocal, isTrue);
      expect(ChatPhoto(Uri.parse('https://files.test/a.jpg')).isLocal, isFalse);
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
