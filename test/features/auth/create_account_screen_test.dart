import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpCreateAccount(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.createAccount));
  }

  Finder submitButton() => find.text('Create account').last;

  Finder fullNameField() => find.byType(TextField).at(0);
  Finder emailField() => find.byType(TextField).at(1);
  Finder passwordField() => find.byType(TextField).at(2);
  Finder referralField() => find.byType(TextField).at(3);

  Future<void> fillValidForm(
    WidgetTester tester, {
    String? referralCode,
  }) async {
    await tester.enterText(fullNameField(), 'Ivy C');
    await tester.enterText(emailField(), 'ivy@gmail.com');
    await tester.enterText(passwordField(), 'Sakura99!');
    if (referralCode != null) {
      await tester.enterText(referralField(), referralCode);
    }
  }

  group('CreateAccountScreen', () {
    testWidgets('refuses an empty form field by field', (tester) async {
      await pumpCreateAccount(tester);

      await tapVisible(tester, submitButton());
      await tester.pump();

      expect(find.text('Full name is required.'), findsOneWidget);
      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Referral code is required.'), findsOneWidget);
      expect(
        find.text('Password does not meet all requirements yet.'),
        findsOneWidget,
      );
    });

    testWidgets('will not create an account without a referral code', (
      tester,
    ) async {
      await pumpCreateAccount(tester);
      await fillValidForm(tester);

      await tapVisible(tester, submitButton());
      await tester.pump();

      expect(find.text('Referral code is required.'), findsOneWidget);
    });

    testWidgets('blocks a password that misses a requirement', (tester) async {
      await pumpCreateAccount(tester);
      await fillValidForm(tester, referralCode: 'FAITH-MARIA24');
      await tester.enterText(passwordField(), 'sakura99');

      await tapVisible(tester, submitButton());
      await tester.pump();

      expect(
        find.text('Password does not meet all requirements yet.'),
        findsOneWidget,
      );
    });

    testWidgets('shows the four password requirement chips', (tester) async {
      await pumpCreateAccount(tester);

      expect(find.text('8+ characters'), findsOneWidget);
      expect(find.text('1 capital'), findsOneWidget);
      expect(find.text('1 number'), findsOneWidget);
      expect(find.text('1 symbol'), findsOneWidget);
    });

    testWidgets('a complete form leaves the screen', (tester) async {
      await pumpCreateAccount(tester);
      await fillValidForm(tester, referralCode: 'FAITH-MARIA24');

      await tapVisible(tester, submitButton());
      await tester.pumpAndSettle();

      expect(find.text('Join and start earning from day one'), findsNothing);
    });

    testWidgets('the back affordance returns to sign in', (tester) async {
      await pumpCreateAccount(tester);

      await tester.tap(find.bySemanticsLabel('Back to sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
