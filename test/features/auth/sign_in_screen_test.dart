import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpSignIn(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.signIn));
  }

  Finder identifierField() => find.byType(TextField).at(0);
  Finder passwordField() => find.byType(TextField).at(1);

  group('SignInScreen', () {
    testWidgets('refuses an empty form and says which fields are missing', (
      tester,
    ) async {
      await pumpSignIn(tester);

      await tapVisible(tester, find.text('Sign in'));
      await tester.pump();

      expect(find.text('Username or Gmail is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('rejects a malformed email address', (tester) async {
      await pumpSignIn(tester);

      await tester.enterText(identifierField(), 'ivy@');
      await tester.enterText(passwordField(), 'Sakura99!');
      await tapVisible(tester, find.text('Sign in'));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('clears a field error once the user starts fixing it', (
      tester,
    ) async {
      await pumpSignIn(tester);

      await tapVisible(tester, find.text('Sign in'));
      await tester.pump();
      expect(find.text('Password is required.'), findsOneWidget);

      await tester.enterText(passwordField(), 'S');
      await tester.pump();

      expect(find.text('Password is required.'), findsNothing);
    });

    testWidgets('a valid form leaves the sign-in screen', (tester) async {
      await pumpSignIn(tester);

      await tester.enterText(identifierField(), 'ivy@gmail.com');
      await tester.enterText(passwordField(), 'Sakura99!');
      await tapVisible(tester, find.text('Sign in'));
      // Explicit pumps, not pumpAndSettle: home animates its mascot caret
      // forever, so there is never a settled frame to wait for.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Welcome back'), findsNothing);
    });

    testWidgets('the password toggle flips between hidden and shown', (
      tester,
    ) async {
      await pumpSignIn(tester);

      expect(tester.widget<TextField>(passwordField()).obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      expect(tester.widget<TextField>(passwordField()).obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('offers the way to create an account', (tester) async {
      await pumpSignIn(tester);

      await tapVisible(tester, find.text('Join with a referral code'));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsWidgets);
    });
  });
}
