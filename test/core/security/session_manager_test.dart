import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/core/security/session_manager.dart';
import 'package:happilab/core/security/session_tokens.dart';
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

/// No pair here is near expiry, so a renewal would be a bug.
Future<Result<SessionTokens>> _neverRenews(String refreshToken) =>
    throw StateError('unexpected refresh');

const SessionTokens _pair = SessionTokens(accessToken: 'token');

SessionManager _session([TokenStore? store]) =>
    SessionManager(store: store ?? InMemoryTokenStore(), refresh: _neverRenews);

void main() {
  group('SessionManager', () {
    test('starts unknown until restored', () {
      final session = _session();

      expect(session.status, SessionStatus.unknown);
      expect(session.isSignedIn, isFalse);
    });

    test('restores to signed in when a pair is stored', () async {
      final store = InMemoryTokenStore();
      await store.write(_pair.encode());
      final session = _session(store);

      await session.restore();

      expect(session.status, SessionStatus.signedIn);
      expect(await session.read(), 'token');
    });

    test('restores to signed out when nothing is stored', () async {
      final session = _session();

      await session.restore();

      expect(session.status, SessionStatus.signedOut);
    });

    test('restores to signed out when the entry cannot be read', () async {
      // A bare token, as a build before the pair was kept wrote it.
      final store = InMemoryTokenStore();
      await store.write('local.session.v1');
      final session = _session(store);

      await session.restore();

      expect(session.status, SessionStatus.signedOut);
      expect(await session.read(), isNull);
    });

    test('restore reads the store once however often it is asked', () async {
      final store = _CountingTokenStore();
      final session = _session(store);

      await session.restore();
      await session.restore();
      await session.read();

      expect(store.reads, 1);
    });

    test('sign in persists the pair and raises the session', () async {
      final store = InMemoryTokenStore();
      final session = _session(store);

      await session.signIn(_pair);

      expect(session.isSignedIn, isTrue);
      expect(SessionTokens.decode((await store.read())!)?.accessToken, 'token');
    });

    test('sign out clears the pair and records the member chose it', () async {
      final store = InMemoryTokenStore();
      final session = _session(store);
      await session.signIn(_pair);

      await session.signOut();

      expect(session.status, SessionStatus.signedOut);
      expect(session.endReason, SessionEndReason.signedOut);
      expect(await store.read(), isNull);
      expect(await session.read(), isNull);
    });

    test('a clear through the credentials contract reads as revoked', () async {
      // The 401 path: ApiClient drops a rejected token via clear.
      final session = _session();
      await session.signIn(_pair);

      await session.clear();

      expect(session.status, SessionStatus.signedOut);
      expect(session.endReason, SessionEndReason.revoked);
    });

    test('signing back in forgets the old end reason', () async {
      final session = _session();
      await session.signIn(_pair);
      await session.clear();

      await session.signIn(const SessionTokens(accessToken: 'fresh'));

      expect(session.endReason, isNull);
    });

    test('notifies only when the status actually changes', () async {
      final session = _session();
      var notifications = 0;
      session.addListener(() => notifications++);

      await session.restore(); // unknown -> signedOut
      await session.signOut(); // already signed out: silent
      await session.signIn(_pair); // -> signedIn
      await session.signIn(_pair); // already signed in: silent
      await session.clear(); // -> signedOut

      expect(notifications, 3);
    });
  });
}
