import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/security/session_tokens.dart';

void main() {
  final now = DateTime.utc(2026, 9, 8, 10);
  const margin = Duration(minutes: 2);

  SessionTokens expiring(Duration left) =>
      SessionTokens(accessToken: 'a', expiresAt: now.add(left));

  group('SessionTokens', () {
    test('round-trips through its stored form', () {
      final pair = SessionTokens(
        accessToken: 'a',
        refreshToken: 'r',
        expiresAt: now,
      );

      final back = SessionTokens.decode(pair.encode());

      expect(back?.accessToken, 'a');
      expect(back?.refreshToken, 'r');
      expect(back?.expiresAt, now);
    });

    test('keeps a bare access token as one', () {
      final back = SessionTokens.decode(
        const SessionTokens(accessToken: 'a').encode(),
      );

      expect(back?.accessToken, 'a');
      expect(back?.refreshToken, isNull);
      expect(back?.expiresAt, isNull);
    });

    test('treats anything else as no session', () {
      expect(SessionTokens.decode('local.session.v1'), isNull);
      expect(SessionTokens.decode('{"refresh_token":"r"}'), isNull);
      expect(SessionTokens.decode('[]'), isNull);
    });

    test('knows when it is about to run out', () {
      expect(
        const SessionTokens(accessToken: 'a').expiresWithin(margin, now),
        isFalse,
      );
      expect(
        expiring(const Duration(minutes: 10)).expiresWithin(margin, now),
        isFalse,
      );
      expect(
        expiring(const Duration(minutes: 1)).expiresWithin(margin, now),
        isTrue,
      );
      expect(
        expiring(const Duration(hours: -1)).expiresWithin(margin, now),
        isTrue,
      );
    });
  });
}
