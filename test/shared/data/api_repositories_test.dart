import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/config/app_config.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/logging/app_logger.dart';
import 'package:happilab/core/network/api_client.dart';
import 'package:happilab/core/network/http_transport.dart';
import 'package:happilab/core/security/token_store.dart';
import 'package:happilab/features/auth/data/auth_api.dart';
import 'package:happilab/features/notifications/data/notifications_api.dart';
import 'package:happilab/shared/data/catalogue_api.dart';
import 'package:happilab/shared/data/delivery_address_api.dart';
import 'package:happilab/shared/data/member_api.dart';
import 'package:happilab/shared/data/orders_api.dart';
import 'package:happilab/shared/domain/catalogue.dart';

import '../../support/fake_http_transport.dart';

void main() {
  ApiClient client(FakeHttpTransport transport) => ApiClient(
    config: AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: Uri.parse('https://api.test.local'),
      maxRetries: 0,
    ),
    transport: transport,
    credentials: InMemoryTokenStore(),
    logger: AppLogger.forEnvironment(isProduction: true),
  );

  group('MemberApi', () {
    test('reads the member off the wire and carries the token', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(
            statusCode: 200,
            body:
                '{"name":"Ivy Santos","referral_code":"FCV-IVY24",'
                '"joined_on":"2025-03-12T00:00:00Z","points":1240,'
                '"lifetime_points":4860,"referred_people":8,'
                '"referred_buyers":5,"unread_notifications":3}',
          ),
        ],
      );
      final store = InMemoryTokenStore()..write('t0k3n');
      final api = MemberApi(
        ApiClient(
          config: AppConfig(
            environment: AppEnvironment.dev,
            apiBaseUrl: Uri.parse('https://api.test.local'),
          ),
          transport: transport,
          credentials: store,
          logger: AppLogger.forEnvironment(isProduction: true),
        ),
      );

      final outcome = await api.summary();

      expect(outcome.valueOrNull?.name, 'Ivy Santos');
      expect(outcome.valueOrNull?.pesoValue, '₱1,240');
      expect(transport.sentRequests.single.url.path, '/v1/me');
      expect(
        transport.sentRequests.single.headers['authorization'],
        'Bearer t0k3n',
      );
    });

    test(
      'a response off the contract is a data failure, not a crash',
      () async {
        final transport = FakeHttpTransport(
          responses: const [
            HttpTransportResponse(statusCode: 200, body: '{"name": 42}'),
          ],
        );

        final outcome = await MemberApi(client(transport)).summary();

        expect(outcome.errorOrNull, isA<DataFormatException>());
      },
    );
  });

  group('AuthApi', () {
    test('posts the credentials and reads the session back', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(
            statusCode: 200,
            body: '{"access_token":"a","refresh_token":"r"}',
          ),
        ],
      );

      final outcome = await AuthApi(client(transport))
          .signIn(identifier: 'ivy@example.com', password: 'placeholder');

      expect(outcome.valueOrNull?.accessToken, 'a');
      expect(outcome.valueOrNull?.refreshToken, 'r');
      expect(transport.sentRequests.single.method, HttpMethod.post);
      expect(transport.sentRequests.single.url.path, '/v1/auth/sign-in');
    });
  });

  group('AuthApi refresh', () {
    test('posts the refresh token alone and reads the new pair', () async {
      final transport = FakeHttpTransport(
        responses: const [
          HttpTransportResponse(
            statusCode: 200,
            body:
                '{"access_token":"a2","refresh_token":"r2",'
                '"expires_at":"2026-09-08T10:15:00Z"}',
          ),
        ],
      );

      final outcome = await AuthApi(client(transport)).refresh('r1');

      expect(outcome.valueOrNull?.accessToken, 'a2');
      expect(outcome.valueOrNull?.refreshToken, 'r2');
      expect(outcome.valueOrNull?.expiresAt, DateTime.utc(2026, 9, 8, 10, 15));
      final request = transport.sentRequests.single;
      expect(request.url.path, '/v1/auth/refresh');
      expect(request.body, {'refresh_token': 'r1'});
      expect(request.headers.containsKey('authorization'), isFalse);
    });
  });

  group('parsers', () {
    test('a notification with a destination the app does not know is news', () {
      final entries = NotificationsApi.parseList([
        {
          'id': 'n9',
          'body': 'Hello',
          'when': '1h',
          'is_unread': true,
          'destination': 'someday',
        },
      ]);

      expect(entries.single.destination, isNull);
      expect(entries.single.isActionable, isFalse);
    });

    test('an address comes back whole, or as none', () {
      expect(DeliveryAddressApi.parseAddress({'address': null}), isNull);
      final address = DeliveryAddressApi.parseAddress({
        'address': {
          'full_name': 'Ana Cruz',
          'email': 'ana@test.ph',
          'mobile': '09171234567',
          'street': '12 Mabini St',
          'purok': '',
          'barangay': 'San Isidro',
          'city': 'Bacolod City',
          'province': 'Negros Occidental',
          'postal_code': '6100',
          'landmark': '',
        },
      });
      expect(
        address?.oneLine,
        '12 Mabini St, San Isidro, Bacolod City, Negros Occidental, 6100',
      );
      expect(
        () => DeliveryAddressApi.parseAddress({
          'address': {'full_name': 1},
        }),
        throwsA(isA<DataFormatException>()),
      );
      final receipt = OrdersApi.parseReceipt({
        'reference': 'FC-1',
        'total': '₱900',
        'status': 'placed',
      });
      expect(receipt.reference, 'FC-1');
      expect(receipt.total, '₱900');
    });

    test('a product carries only the store links the app knows', () {
      final products = CatalogueApi.parseProducts([
        {
          'id': 'p1',
          'name': 'Soap',
          'blurb': 'Clean',
          'price': '₱250',
          'points': 11,
          'image_url': 'https://cdn.test/soap.jpg',
          'badge': 'topSale',
          'store_links': {'shopee': 'https://shopee.ph/x', 'other': 'y'},
        },
      ]);

      expect(products.single.badge, ProductBadge.topSale);
      expect(products.single.storeLinks, {
        SharePlatform.shopee: 'https://shopee.ph/x',
      });
    });
  });
}
