/// A single password requirement, in the order the design shows its chips.
enum PasswordRule {
  minLength('8+ characters'),
  capital('1 capital'),
  number('1 number'),
  symbol('1 symbol');

  const PasswordRule(this.label);

  /// Chip copy, taken from the design canvas.
  final String label;
}

/// The sign-up password rules.
///
/// Pure and self-contained so the requirement chips, the submit guard and the
/// tests all read the same source instead of re-implementing the checks.
abstract final class PasswordPolicy {
  static const int minLength = 8;

  static final RegExp _capital = RegExp('[A-Z]');
  static final RegExp _number = RegExp(r'\d');
  static final RegExp _symbol = RegExp('[^A-Za-z0-9]');

  static bool satisfies(PasswordRule rule, String password) => switch (rule) {
    PasswordRule.minLength => password.length >= minLength,
    PasswordRule.capital => _capital.hasMatch(password),
    PasswordRule.number => _number.hasMatch(password),
    PasswordRule.symbol => _symbol.hasMatch(password),
  };

  static Set<PasswordRule> unmetRules(String password) =>
      PasswordRule.values.where((rule) => !satisfies(rule, password)).toSet();

  static bool isValid(String password) => unmetRules(password).isEmpty;

  /// Message for the field itself; the chips carry the detail.
  static String? validate(String password) =>
      isValid(password) ? null : 'Password does not meet all requirements yet.';
}
