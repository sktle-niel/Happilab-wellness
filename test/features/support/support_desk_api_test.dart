import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/config/app_config.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/logging/app_logger.dart';
import 'package:happilab/core/network/api_client.dart';
import 'package:happilab/core/network/http_transport.dart';
import 'package:happilab/core/security/token_store.dart';
import 'package:happilab/features/support/data/support_desk_api.dart';
import 'package:happilab/features/support/domain/support_chat.dart';
import 'package:happilab/features/support/domain/support_desk.dart';

import '../../support/fake_http_transport.dart';

void main() {
  const queued =
      '{"id":"c1","topic":"Missing points","status":"queued",'
      '"agent_name":null,"resolution":null,"queue_position":1,'
      '"opened_at":"2026-09-10T02:00:00.000Z","ended_at":null,'
      '"messages":[{"id":"m1","sender":"member","body":"My points did not '
      'arrive","attachment_url":"https://files.test/receipts/a.jpg",'
      '"agent_name":null,"sent_at":"2026-09-10T02:00:00.000Z"}]}';
  const withAgent =
      '{"id":"c1","topic":null,"status":"with_agent","agent_name":"Sol Desk",'
      '"resolution":null,"queue_position":null,'
      '"opened_at":"2026-09-10T02:00:00.000Z","ended_at":null,"messages":['
      '{"id":"m1","sender":"member","body":"Hi","attachment_url":null,'
      '"agent_name":null,"sent_at":"2026-09-10T02:00:00.000Z"},'
      '{"id":"m2","sender":"system","body":"Sol Desk joined the chat.",'
      '"attachment_url":null,"agent_name":null,'
      '"sent_at":"2026-09-10T02:01:00.000Z"},'
      '{"id":"m3","sender":"agent","body":"Checking now.",'
      '"attachment_url":null,"agent_name":"Sol Desk",'
      '"sent_at":"2026-09-10T02:02:00.000Z"}]}';

  SupportDeskApi desk(FakeHttpTransport transport) => SupportDeskApi(
    ApiClient(
      config: AppConfig(
        environment: AppEnvironment.dev,
        apiBaseUrl: Uri.parse('https://api.test.local'),
        maxRetries: 0,
      ),
      transport: transport,
      credentials: InMemoryTokenStore()..write('t0k3n'),
      logger: AppLogger.forEnvironment(isProduction: true),
    ),
  );

  Future<File> fileOf(String name, int bytes) async {
    final file = File('${Directory.systemTemp.path}/$name');
    await file.writeAsBytes(List.filled(bytes, 7));
    addTearDown(file.delete);
    return file;
  }

  group('SupportDeskApi', () {
    test('reads a chat in line off the wire', () {
      final chat = SupportDeskApi.parseConversation(jsonDecode(queued));

      expect(chat.id, 'c1');
      expect(chat.status, ChatStatus.queued);
      expect(chat.topic, 'Missing points');
      expect(chat.agentName, isNull);
      expect(chat.queuePosition, 1);
      expect(chat.messages, hasLength(1));
      expect(chat.messages.single.id, 'm1');
      expect(chat.messages.single.isFromMember, isTrue);
      expect(chat.messages.single.photo?.isLocal, isFalse);
      expect(
        chat.messages.single.photo?.url,
        'https://files.test/receipts/a.jpg',
      );
    });

    test('reads a chat with a person on it, naming them', () {
      final chat = SupportDeskApi.parseConversation(jsonDecode(withAgent));

      expect(chat.status, ChatStatus.withAgent);
      expect(chat.agentName, 'Sol Desk');
      expect(chat.queuePosition, isNull);
      expect(chat.messages.map((m) => m.sender.runtimeType), [
        MemberSender,
        SystemSender,
        AgentSender,
      ]);
      final agent = chat.messages.last.sender as AgentSender;
      expect(agent.agent.name, 'Sol Desk');
      expect(chat.messages[1].isNote, isTrue);
    });

    test('a standing off the contract is a data failure', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(
            statusCode: 200,
            body: '{"id":"c1","status":"lost","messages":[]}',
          ),
        ],
      );

      final outcome = await desk(transport).conversation('c1');

      expect(outcome.errorOrNull, isA<DataFormatException>());
    });

    test('opening posts the topic and the first line, nothing else', () async {
      final transport = FakeHttpTransport(
        responses: const [HttpTransportResponse(statusCode: 201, body: queued)],
      );

      final outcome = await desk(transport)
          .open(topic: 'Missing points', body: 'My points did not arrive');

      expect(outcome.valueOrNull?.id, 'c1');
      final request = transport.sentRequests.single;
      expect(request.method, HttpMethod.post);
      expect(request.url.path, '/v1/support/conversations');
      expect(request.headers['authorization'], 'Bearer t0k3n');
      expect(request.body, {
        'topic': 'Missing points',
        'body': 'My points did not arrive',
      });
    });

    test('a line goes to the chat it belongs to', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(
            statusCode: 201,
            body:
                '{"id":"m9","sender":"member","body":"Thanks",'
                '"attachment_url":null,"sent_at":"2026-09-10T02:03:00.000Z"}',
          ),
        ],
      );

      final outcome = await desk(transport).send('c1', body: 'Thanks');

      expect(outcome.valueOrNull?.id, 'm9');
      expect(
        transport.sentRequests.single.url.path,
        '/v1/support/conversations/c1/messages',
      );
      expect(transport.sentRequests.single.body, {'body': 'Thanks'});
    });
  });

  group('SupportDeskApi photos', () {
    const signed =
        '{"path":"chat/x.jpg","upload_url":"https://files.test/storage/v1/'
        'object/upload/sign/assets/chat/x.jpg","token":"tok",'
        '"public_url":"https://files.test/storage/v1/object/public/assets/'
        'chat/x.jpg"}';

    test(
      'signs, puts the bytes at the signed address, and answers the public one',
      () async {
        final file = await fileOf('desk-photo.jpg', 1024);
        final transport = FakeHttpTransport(
          responses: const [
            HttpTransportResponse(statusCode: 200, body: signed),
            HttpTransportResponse(statusCode: 200, body: '{"Key":"x"}'),
          ],
        );

        final outcome = await desk(transport).uploadPhoto(file, bytes: 1024);

        expect(
          outcome.valueOrNull,
          'https://files.test/storage/v1/object/public/assets/chat/x.jpg',
        );
        final [sign, put] = transport.sentRequests;
        expect(sign.url.path, '/v1/support/uploads/sign');
        expect(sign.body, {
          'content_type': 'image/jpeg',
          'content_length': 1024,
        });
        expect(put.method, HttpMethod.put);
        expect(put.url.host, 'files.test');
        expect(put.url.queryParameters['token'], 'tok');
        expect(put.headers['content-type'], 'image/jpeg');
        expect(put.headers['x-upsert'], 'false');
        expect(put.headers.containsKey('authorization'), isFalse);
        expect(put.body, isA<Uint8List>());
        expect((put.body as Uint8List).length, 1024);
      },
    );

    test('a store the API cannot sign for stops before a byte moves', () async {
      final file = await fileOf('desk-photo-refused.jpg', 1024);
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(
            statusCode: 503,
            body:
                '{"error":"unavailable","message":"Uploads are not configured '
                'on this server."}',
          ),
        ],
      );

      final outcome = await desk(transport).uploadPhoto(file, bytes: 1024);

      expect(outcome.errorOrNull, isA<ServerException>());
      expect(
        outcome.errorOrNull?.message,
        'Uploads are not configured on this server.',
      );
      expect(transport.sentRequests, hasLength(1));
    });

    test(
      'a kind of file the desk does not take is refused on the device',
      () async {
        final file = await fileOf('desk-photo.gif', 16);
        final transport = FakeHttpTransport();

        final outcome = await desk(transport).uploadPhoto(file, bytes: 16);

        expect(outcome.errorOrNull, isA<ValidationException>());
        expect(transport.sentRequests, isEmpty);
      },
    );
  });
}
