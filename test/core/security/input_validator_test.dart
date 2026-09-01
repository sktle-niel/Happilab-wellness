import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/security/input_validator.dart';

void main() {
  group('InputValidator.notEmpty', () {
    test('rejects nothing, a blank and whitespace, by field name', () {
      const message = 'Full name is required.';

      expect(InputValidator.notEmpty(null, field: 'Full name'), message);
      expect(InputValidator.notEmpty('', field: 'Full name'), message);
      expect(InputValidator.notEmpty('   ', field: 'Full name'), message);
    });

    test('accepts a value with something in it', () {
      expect(InputValidator.notEmpty('Ivy'), isNull);
    });
  });

  group('InputValidator.email', () {
    test('accepts an address, ignoring the space around it', () {
      expect(InputValidator.email('ivy.santos+ph@gmail.com'), isNull);
      expect(InputValidator.email('  ivy@gmail.com  '), isNull);
    });

    test('rejects an address that could never deliver', () {
      for (final value in [
        'ivy',
        'ivy@',
        '@gmail.com',
        'ivy@gmail',
        'ivy @gmail.com',
        'ivy@gmail.c',
      ]) {
        expect(
          InputValidator.email(value),
          'Enter a valid email address.',
          reason: value,
        );
      }
    });

    test('asks for the field before it asks for a shape', () {
      expect(InputValidator.email(''), 'Email is required.');
    });
  });

  group('InputValidator.minLength', () {
    test('measures the value after trimming it', () {
      expect(InputValidator.minLength('  abc  ', 3), isNull);
      expect(
        InputValidator.minLength('ab', 3, field: 'Code'),
        'Code must be at least 3 characters.',
      );
    });
  });

  group('InputValidator.sanitize', () {
    test('drops the control characters that corrupt a log or a parser', () {
      expect(
        InputValidator.sanitize('Ivy\u0000 San\u001Ftos\u007F'),
        'Ivy Santos',
      );
      expect(InputValidator.sanitize('one\ntwo'), 'onetwo');
    });

    test('trims what is left', () {
      expect(InputValidator.sanitize('  Ivy  '), 'Ivy');
    });

    test('caps a paste bomb so it travels no further', () {
      expect(InputValidator.sanitize('a' * 1000).length, 512);
      expect(InputValidator.sanitize('a' * 1000, maxLength: 10), 'a' * 10);
    });
  });
}
