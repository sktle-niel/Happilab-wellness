import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpNotifications(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.notifications));
    await tester.pump();
  }

  /// Explicit pumps, not pumpAndSettle: some destinations animate forever.
  Future<void> open(WidgetTester tester, String body) async {
    await tapVisible(tester, find.text(body));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  group('NotificationsScreen', () {
    testWidgets('a cash-out notice opens the account activity', (tester) async {
      await pumpNotifications(tester);

      await open(tester, 'Your ₱500 cash out was sent to GCash.');

      expect(find.text('Account activity'), findsOneWidget);
    });

    testWidgets('a friend joining opens the referrals', (tester) async {
      await pumpNotifications(tester);

      await open(tester, 'Paolo joined using your code. Say hello!');

      expect(find.text('My referrals'), findsOneWidget);
    });

    testWidgets('plain news gives no response to a tap', (tester) async {
      await pumpNotifications(tester);

      await open(tester, 'Payouts to Maya now arrive within 24 hours.');

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Account activity'), findsNothing);
      expect(find.text('My referrals'), findsNothing);
    });
  });
}
