import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/security/token_store.dart';
import 'package:happilab/core/storage/persisted_flag.dart';

/// A store that refuses every write, the way a locked keystore would.
final class _RefusingStore implements TokenStore {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String token) async =>
      throw const SecureStorageException();

  @override
  Future<void> clear() async {}
}

void main() {
  group('PersistedFlag', () {
    PersistedFlag build(TokenStore store) {
      final flag = PersistedFlag(store: store, onValue: 'yes');
      addTearDown(flag.dispose);
      return flag;
    }

    test('starts off and restores what was kept', () async {
      final store = InMemoryTokenStore();
      await store.write('yes');
      final flag = build(store);
      expect(flag.value, isFalse);

      await flag.restore();

      expect(flag.value, isTrue);
    });

    test('keeps a change for the next launch', () async {
      final store = InMemoryTokenStore();
      final flag = build(store);

      flag.toggle();
      await pumpEventQueue();
      expect(await store.read(), 'yes');

      flag.set(false);
      await pumpEventQueue();
      expect(await store.read(), isNull);
    });

    test('still flips when the store will not keep it', () async {
      final flag = build(_RefusingStore());
      var notified = 0;
      flag.addListener(() => notified++);

      flag.toggle();
      await pumpEventQueue();

      expect(flag.value, isTrue);
      expect(notified, 1);
    });

    test('setting the same value again tells no one', () {
      final flag = build(InMemoryTokenStore());
      var notified = 0;
      flag.addListener(() => notified++);

      flag.set(false);

      expect(notified, 0);
    });
  });
}
