import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/app/theme/app_tokens.dart';
import 'package:happilab/shared/domain/delivery_address.dart';

import '../../support/harness.dart';

const home = DeliveryAddress(
  fullName: 'Ivy Santos',
  email: 'ivy@example.com',
  mobile: '09171231234',
  street: '12 Mabini St',
  purok: 'Purok 3',
  barangay: 'San Isidro',
  city: 'Bacolod City',
  province: 'Negros Occidental',
  postalCode: '6100',
);

void main() {
  /// Starts on the suggestions grid and gets the first product.
  Future<void> openCheckout(
    WidgetTester tester, {
    DeliveryAddress? address,
  }) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      testApp(initialRoute: AppRoutes.suggestions, deliveryAddress: address),
    );
    await tester.pump();
    await tester.pump();

    await tapVisible(tester, find.bySemanticsLabel('Get Sakura Glow Soap'));
    await tester.pumpAndSettle();
  }

  /// Lets the toast withdraw so no timer outlives the test.
  Future<void> letToastGo(WidgetTester tester) async {
    await tester.pump(AppDuration.toast);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> fillAddress(WidgetTester tester) async {
    final fields = find.byType(TextField);
    const values = [
      'Ivy Santos',
      '0917 123 1234',
      'ivy@example.com',
      'Negros Occidental',
      'Bacolod City',
      'San Isidro',
      '6100',
      '12 Mabini St',
    ];
    for (final (index, value) in values.indexed) {
      await tester.ensureVisible(fields.at(index));
      await tester.enterText(fields.at(index), value);
    }
  }

  group('GetProductScreen', () {
    testWidgets('asks for an address first, then places the order', (
      tester,
    ) async {
      await openCheckout(tester);
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Sakura Glow Soap'), findsOneWidget);
      expect(find.text('No delivery address yet'), findsOneWidget);

      await tapVisible(tester, find.text('Add delivery address'));
      await tester.pumpAndSettle();
      expect(find.text('Add address'), findsOneWidget);

      await fillAddress(tester);
      await tapVisible(tester, find.text('Save address'));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Ivy Santos · 0917 123 1234'), findsOneWidget);
      expect(
        find.text(
          '12 Mabini St, San Isidro, Bacolod City, Negros Occidental, 6100',
        ),
        findsOneWidget,
      );
      await letToastGo(tester);

      await tester.tap(find.bySemanticsLabel('One more'));
      await tester.pump();
      expect(find.text('₱150 × 2'), findsOneWidget);

      await tapVisible(tester, find.text('Place order'));
      // Not pumpAndSettle: the toast breathes for as long as it shows, so a
      // settle would wait it out; the route's own exit is over in this time.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Order FC-DEMO0001 placed'), findsOneWidget);
      expect(find.text('Checkout'), findsNothing);
      await letToastGo(tester);
    });

    testWidgets('a saved address is offered at once, with a way to change it', (
      tester,
    ) async {
      await openCheckout(tester, address: home);

      expect(find.text('Ivy Santos · 0917 123 1234'), findsOneWidget);
      expect(find.text('Add delivery address'), findsNothing);

      await tapVisible(tester, find.text('Change'));
      await tester.pumpAndSettle();
      expect(find.text('Update address'), findsOneWidget);
      expect(find.text('Purok 3'), findsOneWidget);
    });

    testWidgets('the form refuses a bad mobile and stays put', (tester) async {
      await openCheckout(tester);
      await tapVisible(tester, find.text('Add delivery address'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), '1234');
      // Leaving the field first, as a thumb does: a focused field keeps its
      // caret on screen, which would scroll the button back out of reach.
      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pump();
      await tapVisible(tester, find.text('Save address'));
      await tester.pump();

      expect(
        find.text('Enter an 11-digit mobile number starting with 09.'),
        findsOneWidget,
      );
      // The header has scrolled out of the list by now; the button is the
      // sign the form is still on screen.
      expect(find.text('Save address'), findsOneWidget);
    });
  });
}
