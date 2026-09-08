import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/network/server_error.dart';

void main() {
  group('ServerError.parse', () {
    test('reads the code and the sentence', () {
      final error = ServerError.parse(
        '{"error":"conflict","message":"That email is already registered."}',
      );

      expect(error?.code, 'conflict');
      expect(error?.message, 'That email is already registered.');
    });

    test('ignores anything that is not the contract shape', () {
      expect(ServerError.parse(''), isNull);
      expect(ServerError.parse('<html>502 Bad Gateway</html>'), isNull);
      expect(ServerError.parse('["error"]'), isNull);
      expect(ServerError.parse('{"error":"validation"}'), isNull);
      expect(ServerError.parse('{"error":7,"message":"x"}'), isNull);
      expect(
        ServerError.parse('{"error":"validation","message":"  "}'),
        isNull,
      );
    });

    test('strips control characters and caps the sentence', () {
      final nul = String.fromCharCode(0);
      final newline = String.fromCharCode(10);
      final body = jsonEncode({
        'error': 'validation',
        'message': 'Check$nul the$newline details ${'x' * 500}',
      });

      final error = ServerError.parse(body);

      expect(error?.message, startsWith('Check the details'));
      expect(error?.message, isNot(contains(newline)));
      expect(error?.message.length, 200);
    });
  });
}
