import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/security/redactor.dart';

void main() {
  group('Redactor', () {
    const redactor = Redactor();
    const mask = '***REDACTED***';

    test('masks a bearer token', () {
      final line = redactor.redact(
        'GET /v1/profile authorization: Bearer eyJhbGci.9dHkiOiJKV1Q-abc=',
      );

      expect(line, isNot(contains('eyJhbGci')));
      expect(line, contains(mask));
    });

    test('masks a labelled secret however it is written', () {
      const lines = [
        'password: hunter2',
        'passwd=hunter2',
        '"api_key":"hunter2"',
        'api-key = hunter2',
        'token=hunter2',
        "'refresh_token': 'hunter2'",
        'SECRET: hunter2',
      ];

      for (final line in lines) {
        expect(redactor.redact(line), isNot(contains('hunter2')), reason: line);
      }
    });

    test('masks an email address anywhere in the line', () {
      expect(
        redactor.redact('sign-in failed for ivy.santos+ph@gmail.com'),
        'sign-in failed for $mask',
      );
    });

    test('masks a card or account number', () {
      expect(
        redactor.redact('card 4111111111111111 declined'),
        'card $mask declined',
      );
      expect(redactor.redact('ref 123456789012'), 'ref $mask');
    });

    test('masks every secret in a line, not just the first', () {
      final line = redactor.redact(
        'user ivy@gmail.com token=abc123 authorization: Bearer xyz789',
      );

      expect(line, isNot(contains('ivy@gmail.com')));
      expect(line, isNot(contains('abc123')));
      expect(line, isNot(contains('xyz789')));
    });

    test('leaves a line with nothing to hide untouched', () {
      // An over-broad rule that eats ordinary diagnostics costs as much as one
      // that leaks — the logs stop being worth reading.
      const line = 'GET /v1/products -> 200 in 84ms';

      expect(redactor.redact(line), line);
    });
  });
}
