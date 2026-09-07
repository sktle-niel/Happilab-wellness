import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/app/theme/app_tokens.dart';

import '../../support/harness.dart';

void main() {
  /// Starts on Cash out with no wallet saved and goes into the GCash form.
  Future<void> openAddGcash(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.rewards));
    await tester.pump();

    await tapVisible(tester, find.text('Add GCash'));
    await tester.pumpAndSettle();
  }

  Finder nameField() => find.byType(TextField).at(0);
  Finder numberField() => find.byType(TextField).at(1);

  group('EditPayoutNumberScreen', () {
    testWidgets('a wallet added from Cash out appears in its picker', (
      tester,
    ) async {
      await openAddGcash(tester);
      expect(find.text('Add GCash'), findsOneWidget);

      await tester.enterText(nameField(), 'Ivy Santos');
      await tester.enterText(numberField(), '0917 123 1234');
      await tapVisible(tester, find.text('Save account'));
      await tester.pumpAndSettle();

      expect(find.text('GCash'), findsOneWidget);
      expect(find.text('Ivy Santos · 0917 •••• 1234'), findsOneWidget);
      expect(find.text('Add Maya'), findsOneWidget);
      expect(find.text('No payout account yet'), findsNothing);
      // Let the toast withdraw so no timer outlives the test.
      await tester.pump(AppDuration.toast);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('refuses a number that is not a mobile number', (tester) async {
      await openAddGcash(tester);

      await tester.enterText(nameField(), 'Ivy Santos');
      await tester.enterText(numberField(), '1234');
      await tapVisible(tester, find.text('Save account'));
      await tester.pump();

      expect(
        find.text('Enter an 11-digit mobile number starting with 09.'),
        findsOneWidget,
      );
      expect(find.text('Add GCash'), findsOneWidget);
    });
  });
}
