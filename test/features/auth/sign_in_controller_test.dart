import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/auth/presentation/sign_in_controller.dart';

void main() {
  group('SignInController', () {
    late SignInController controller;
    late int notifications;

    setUp(() {
      controller = SignInController();
      notifications = 0;
      controller.addListener(() => notifications++);
    });

    tearDown(() => controller.dispose());

    test('refuses an empty form and names both fields', () {
      expect(controller.validate(), isFalse);
      expect(controller.identifierError, 'Username or Gmail is required.');
      expect(controller.passwordError, 'Password is required.');
    });

    test('holds an identifier with an @ to the email rules', () {
      controller.identifier.text = 'ivy@gmail';
      controller.password.text = 'Sakura99!';

      expect(controller.validate(), isFalse);
      expect(controller.identifierError, 'Enter a valid email address.');
    });

    test('takes a plain username as it is', () {
      controller.identifier.text = 'ivysantos';
      controller.password.text = 'Sakura99!';

      expect(controller.validate(), isTrue);
      expect(controller.identifierError, isNull);
      expect(controller.passwordError, isNull);
    });

    test('clears a field error once the member starts fixing it', () {
      controller.validate();
      final afterValidate = notifications;

      controller.onIdentifierChanged('i');

      expect(controller.identifierError, isNull);
      expect(notifications, afterValidate + 1);
    });

    test('stays quiet while typing into a field with no error to clear', () {
      controller
        ..onIdentifierChanged('i')
        ..onPasswordChanged('s');

      expect(notifications, 0);
    });

    test('hides the password until the member asks to see it', () {
      expect(controller.isPasswordHidden, isTrue);

      controller.togglePasswordVisibility();

      expect(controller.isPasswordHidden, isFalse);
      expect(notifications, 1);
    });
  });
}
