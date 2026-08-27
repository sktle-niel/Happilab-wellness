import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/security/secure_token_store.dart';

void main() {
  late Map<String, String> platformStorage;

  setUp(() {
    platformStorage = <String, String>{};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      platformStorage,
    );
  });

  group('SecureTokenStore', () {
    test('persists the token and reads it back', () async {
      final store = SecureTokenStore();

      await store.write('secret-token');

      expect(platformStorage[store.key], 'secret-token');
      expect(await store.read(), 'secret-token');
    });

    test('serves later reads from memory, not the platform channel', () async {
      platformStorage['auth_token'] = 'from-storage';
      final store = SecureTokenStore();

      expect(await store.read(), 'from-storage');
      platformStorage['auth_token'] = 'changed-underneath';

      expect(await store.read(), 'from-storage');
    });

    test('clear wipes both the platform entry and the cache', () async {
      final store = SecureTokenStore();
      await store.write('secret-token');

      await store.clear();

      expect(platformStorage, isEmpty);
      expect(await store.read(), isNull);
    });
  });
}
