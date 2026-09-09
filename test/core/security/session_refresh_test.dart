import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/core/security/session_manager.dart';
import 'package:happilab/core/security/session_tokens.dart';
import 'package:happilab/core/security/token_store.dart';

/// A scripted refresher: what it answers, and what it was asked.
final class _Refresher {
  _Refresher(this.answer);

  Result<SessionTokens> answer;
  final List<String> asked = [];

  Future<Result<SessionTokens>> call(String refreshToken) async {
    asked.add(refreshToken);
    return answer;
  }
}

final DateTime _now = DateTime.utc(2026, 9, 8, 10);

SessionTokens _pair({
  required Duration left,
  String access = 'old',
  String refresh = 'r1',
}) => SessionTokens(
  accessToken: access,
  refreshToken: refresh,
  expiresAt: _now.add(left),
);

void main() {
  late InMemoryTokenStore store;
  late _Refresher refresher;

  SessionManager session() =>
      SessionManager(store: store, refresh: refresher.call, clock: () => _now);

  setUp(() {
    store = InMemoryTokenStore();
    refresher = _Refresher(
      Success(
        _pair(left: const Duration(minutes: 15), access: 'new', refresh: 'r2'),
      ),
    );
  });

  group('SessionManager renewal', () {
    test('hands over a token with time left without asking', () async {
      final manager = session();
      await manager.signIn(_pair(left: const Duration(minutes: 10)));

      expect(await manager.read(), 'old');
      expect(refresher.asked, isEmpty);
    });

    test('renews a token about to run out and keeps the new pair', () async {
      final manager = session();
      await manager.signIn(_pair(left: const Duration(minutes: 1)));

      expect(await manager.read(), 'new');

      expect(refresher.asked, ['r1']);
      expect(SessionTokens.decode((await store.read())!)?.refreshToken, 'r2');
      expect(manager.isSignedIn, isTrue);
    });

    test('one renewal serves every request waiting on it', () async {
      final manager = session();
      await manager.signIn(_pair(left: Duration.zero));

      final tokens = await Future.wait([
        manager.read(),
        manager.read(),
        manager.read(),
      ]);

      expect(tokens, ['new', 'new', 'new']);
      expect(refresher.asked, hasLength(1));
    });

    test('a refused refresh token ends the session as revoked', () async {
      refresher.answer = const Failure(UnauthorizedException());
      final manager = session();
      await manager.signIn(_pair(left: const Duration(minutes: 1)));

      expect(await manager.read(), isNull);

      expect(manager.status, SessionStatus.signedOut);
      expect(manager.endReason, SessionEndReason.revoked);
      expect(await store.read(), isNull);
    });

    test('any other failure keeps the pair in hand', () async {
      refresher.answer = const Failure(NetworkException());
      final manager = session();
      await manager.signIn(_pair(left: const Duration(minutes: 1)));

      expect(await manager.read(), 'old');
      expect(manager.isSignedIn, isTrue);
    });

    test('a pair without a refresh token is never renewed', () async {
      final manager = session();
      await manager.signIn(
        SessionTokens(
          accessToken: 'only',
          expiresAt: _now.subtract(const Duration(hours: 1)),
        ),
      );

      expect(await manager.read(), 'only');
      expect(refresher.asked, isEmpty);
    });

    test('a session that ended mid-renewal stays ended', () async {
      final gate = Completer<Result<SessionTokens>>();
      final manager = SessionManager(
        store: store,
        refresh: (_) => gate.future,
        clock: () => _now,
      );
      await manager.signIn(_pair(left: Duration.zero));

      final reading = manager.read();
      await manager.signOut();
      gate.complete(
        Success(_pair(left: const Duration(minutes: 15), access: 'new')),
      );

      expect(await reading, isNull);
      expect(manager.isSignedIn, isFalse);
      expect(await store.read(), isNull);
    });
  });
}
