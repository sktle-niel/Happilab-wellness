import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/auth/domain/password_policy.dart';

void main() {
  group('PasswordPolicy', () {
    test('a password meeting every rule is valid', () {
      expect(PasswordPolicy.isValid('Sakura99!'), isTrue);
      expect(PasswordPolicy.unmetRules('Sakura99!'), isEmpty);
      expect(PasswordPolicy.validate('Sakura99!'), isNull);
    });

    test('reports exactly the rules a password fails', () {
      expect(PasswordPolicy.unmetRules(''), PasswordRule.values.toSet());
      expect(PasswordPolicy.unmetRules('Short1!'), {PasswordRule.minLength});
      expect(PasswordPolicy.unmetRules('lowercase1!'), {PasswordRule.capital});
      expect(PasswordPolicy.unmetRules('NoDigitsHere!'), {PasswordRule.number});
      expect(PasswordPolicy.unmetRules('NoSymbols123'), {PasswordRule.symbol});
    });

    test('counts a space and a non-latin mark as symbols', () {
      expect(PasswordPolicy.satisfies(PasswordRule.symbol, 'Abc 1234'), isTrue);
      expect(PasswordPolicy.satisfies(PasswordRule.symbol, 'Abc₱1234'), isTrue);
    });

    test('the minimum length is measured, not assumed', () {
      final atLimit = 'Aa1!' * 2;
      expect(atLimit.length, PasswordPolicy.minLength);
      expect(PasswordPolicy.satisfies(PasswordRule.minLength, atLimit), isTrue);
      expect(
        PasswordPolicy.satisfies(PasswordRule.minLength, atLimit.substring(1)),
        isFalse,
      );
    });
  });
}
