import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/security/session_manager.dart';
import 'package:happilab/core/security/token_store.dart';

/// Counts reads so restore's memoization is observable.
final class _CountingTokenStore implements TokenStore {
  String? _token;
  int reads = 0;

  @override
  Future<String?> read() async {
    reads++;
    return _token;
  }

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

void main() {
  group('SessionManager', () {
    test('starts unknown until restored', () {
      final manager = SessionManager(store: InMemoryTokenStore());

      expect(manager.status, SessionStatus.unknown);
      expect(manager.isSignedIn, isFalse);
    });

    test('restores to signed in when a token is stored', () async {
      final store = InMemoryTokenStore();
      await store.write('token');
      final manager = SessionManager(store: store);

      await manager.restore();

      expect(manager.status, SessionStatus.signedIn);
    });

    test('restores to signed out when nothing is stored', () async {
      final manager = SessionManager(store: InMemoryTokenStore());

      await manager.restore();

      expect(manager.status, SessionStatus.signedOut);
    });

    test(
      'restore reads the store once no matter how often it is called',
      () async {
        final store = _CountingTokenStore();
        final manager = SessionManager(store: store);

        await manager.restore();
        await manager.restore();

        expect(store.reads, 1);
      },
    );

    test('sign in persists the token and raises the session', () async {
      final store = InMemoryTokenStore();
      final manager = SessionManager(store: store);

      await manager.signIn('token');

      expect(manager.isSignedIn, isTrue);
      expect(await store.read(), 'token');
    });

    test('sign out clears the token and records the member chose it', () async {
      final store = InMemoryTokenStore();
      final manager = SessionManager(store: store);
      await manager.signIn('token');

      await manager.signOut();

      expect(manager.status, SessionStatus.signedOut);
      expect(manager.endReason, SessionEndReason.signedOut);
      expect(await store.read(), isNull);
    });

    test('a clear through the TokenStore contract reads as revoked', () async {
      // The 401 path: ApiClient drops a rejected token via TokenStore.clear.
      final manager = SessionManager(store: InMemoryTokenStore());
      await manager.signIn('token');

      await manager.clear();

      expect(manager.status, SessionStatus.signedOut);
      expect(manager.endReason, SessionEndReason.revoked);
    });

    test('signing back in forgets the old end reason', () async {
      final manager = SessionManager(store: InMemoryTokenStore());
      await manager.signIn('token');
      await manager.clear();

      await manager.signIn('fresh');

      expect(manager.endReason, isNull);
    });

    test('notifies only when the status actually changes', () async {
      final manager = SessionManager(store: InMemoryTokenStore());
      var notifications = 0;
      manager.addListener(() => notifications++);

      await manager.restore(); // unknown -> signedOut
      await manager.signOut(); // already signed out: silent
      await manager.signIn('token'); // -> signedIn
      await manager.signIn('token'); // already signed in: silent
      await manager.clear(); // -> signedOut

      expect(notifications, 3);
    });
  });
}
