import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/config/app_config.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/core/logging/app_logger.dart';
import 'package:happilab/core/network/api_client.dart';
import 'package:happilab/core/network/http_transport.dart';
import 'package:happilab/core/network/retry_policy.dart';
import 'package:happilab/core/security/token_store.dart';

import '../../support/fake_http_transport.dart';

void main() {
  late InMemoryTokenStore tokenStore;

  AppConfig config() => AppConfig(
    environment: AppEnvironment.dev,
    apiBaseUrl: Uri.parse('https://api.test.local'),
  );

  ApiClient buildClient(FakeHttpTransport transport) => ApiClient(
    config: config(),
    transport: transport,
    tokenStore: tokenStore,
    logger: const AppLogger(minimumLevel: LogLevel.error),
    // Real backoff would make this suite wait seconds for nothing, and a
    // server-sent `Retry-After: 30` is obeyed literally — the clamp is what
    // keeps that honest and fast here.
    retryPolicy: RetryPolicy(
      maxAttempts: 3,
      initialDelay: const Duration(milliseconds: 1),
      maxDelay: const Duration(milliseconds: 2),
      maxServerCooldown: const Duration(milliseconds: 2),
    ),
  );

  String? parseName(Object? json) => (json! as Map)['name'] as String?;

  setUp(() => tokenStore = InMemoryTokenStore());

  group('ApiClient', () {
    test(
      'resolves the path against the base url and parses the body',
      () async {
        final transport = FakeHttpTransport(
          responses: const [
            HttpTransportResponse(statusCode: 200, body: '{"name":"Ivy"}'),
          ],
        );

        final result = await buildClient(transport)
            .get('v1/profile', parse: parseName);

        expect(result, isA<Success<String?>>());
        expect(result.valueOrNull, 'Ivy');
        expect(
          transport.sentRequests.single.url,
          Uri.parse('https://api.test.local/v1/profile'),
        );
      },
    );

    test('attaches the stored token as a bearer header', () async {
      await tokenStore.write('token-123');
      final transport = FakeHttpTransport(
        responses: const [HttpTransportResponse(statusCode: 200, body: '{}')],
      );

      await buildClient(transport).get('v1/profile', parse: parseName);

      expect(
        transport.sentRequests.single.headers['authorization'],
        'Bearer token-123',
      );
    });

    test('drops a token the server has rejected', () async {
      await tokenStore.write('stale-token');
      final transport = FakeHttpTransport(
        responses: const [HttpTransportResponse(statusCode: 401, body: '')],
      );

      final result = await buildClient(transport)
          .get('v1/profile', parse: parseName);

      expect(result.errorOrNull, isA<UnauthorizedException>());
      expect(await tokenStore.read(), isNull);
    });

    test('surfaces 429 with the cooldown the server asked for', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(
            statusCode: 429,
            body: '',
            headers: {'retry-after': '30'},
          ),
          HttpTransportResponse(
            statusCode: 429,
            body: '',
            headers: {'retry-after': '30'},
          ),
          HttpTransportResponse(
            statusCode: 429,
            body: '',
            headers: {'retry-after': '30'},
          ),
        ],
      );

      final result = await buildClient(transport)
          .get('v1/profile', parse: parseName);

      final error = result.errorOrNull;
      expect(error, isA<RateLimitedException>());
      expect(
        (error! as RateLimitedException).retryAfter,
        const Duration(seconds: 30),
      );
      expect(transport.sentRequests, hasLength(3));
    });

    test('retries a server error and returns the eventual success', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(statusCode: 503, body: ''),
          HttpTransportResponse(statusCode: 200, body: '{"name":"Ivy"}'),
        ],
      );

      final result = await buildClient(transport)
          .get('v1/profile', parse: parseName);

      expect(result.valueOrNull, 'Ivy');
      expect(transport.sentRequests, hasLength(2));
    });

    test('never retries a request the server called malformed', () async {
      final transport = FakeHttpTransport(
        responses: const [HttpTransportResponse(statusCode: 400, body: '')],
      );

      final result = await buildClient(transport)
          .get('v1/profile', parse: parseName);

      expect(result.errorOrNull, isA<ClientException>());
      expect(transport.sentRequests, hasLength(1));
    });

    test('reports an unparseable body instead of throwing', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(statusCode: 200, body: 'not json'),
        ],
      );

      final result = await buildClient(transport)
          .get('v1/profile', parse: parseName);

      expect(result.errorOrNull, isA<DataFormatException>());
    });
  });
}
