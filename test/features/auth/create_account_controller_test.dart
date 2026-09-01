import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/auth/presentation/create_account_controller.dart';
import 'package:happilab/shared/domain/password_policy.dart';

void main() {
  group('CreateAccountController', () {
    late CreateAccountController controller;
    late int notifications;

    void fillValidForm() {
      controller.fullName.text = 'Ivy Santos';
      controller.email.text = 'ivy@gmail.com';
      controller.password.text = 'Sakura99!';
      controller.referralCode.text = 'FCV-IVY24';
    }

    setUp(() {
      controller = CreateAccountController();
      notifications = 0;
      controller.addListener(() => notifications++);
    });

    tearDown(() => controller.dispose());

    test('refuses an empty form field by field', () {
      expect(controller.validate(), isFalse);
      expect(controller.fullNameError, 'Full name is required.');
      expect(controller.emailError, 'Email is required.');
      expect(
        controller.passwordError,
        'Password does not meet all requirements yet.',
      );
      expect(controller.referralCodeError, 'Referral code is required.');
    });

    test('will not create an account without a referral code', () {
      fillValidForm();
      controller.referralCode.text = '';

      expect(controller.validate(), isFalse);
      expect(controller.referralCodeError, 'Referral code is required.');
      expect(controller.fullNameError, isNull);
    });

    test('reports the password rules still unmet', () {
      fillValidForm();
      controller.password.text = 'sakura99';

      expect(controller.validate(), isFalse);
      expect(controller.unmetRules, {
        PasswordRule.capital,
        PasswordRule.symbol,
      });
    });

    test('accepts a complete form', () {
      fillValidForm();

      expect(controller.validate(), isTrue);
      expect(controller.unmetRules, isEmpty);
    });

    test('redraws the chips on every keystroke, the fields only on a fix', () {
      controller.onPasswordChanged('S');
      expect(notifications, 1);

      // No error is standing on the name, so there is nothing to redraw for.
      controller.onFullNameChanged('I');
      expect(notifications, 1);
    });
  });
}
