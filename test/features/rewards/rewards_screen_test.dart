import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/shared/domain/payout_account.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpRewards(
    WidgetTester tester, {
    PayoutAccounts? wallets,
  }) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      testApp(initialRoute: AppRoutes.rewards, payoutAccounts: wallets),
    );
    await tester.pump();
  }

  PayoutAccounts savedWallets() =>
      PayoutAccounts(initial: PayoutAccount.placeholder);

  group('RewardsScreen', () {
    testWidgets('offers the saved wallets as destinations', (tester) async {
      await pumpRewards(tester, wallets: savedWallets());

      expect(find.text('GCash'), findsOneWidget);
      expect(find.text('Maya'), findsOneWidget);
      expect(find.text('Ivy Santos · 0917 •••• 1234'), findsNWidgets(2));
    });

    testWidgets('asks for a wallet before it offers destinations', (
      tester,
    ) async {
      await pumpRewards(tester);

      expect(find.text('No payout account yet'), findsOneWidget);
      expect(find.text('Add GCash'), findsOneWidget);
      expect(find.text('Add Maya'), findsOneWidget);
      expect(find.text('GCash'), findsNothing);
    });

    testWidgets('the pencil opens the wallet filled with what is saved', (
      tester,
    ) async {
      await pumpRewards(tester, wallets: savedWallets());

      await tapVisible(tester, find.byTooltip('Edit GCash'));
      await tester.pumpAndSettle();

      expect(find.text('Update GCash'), findsOneWidget);
      expect(find.text('Ivy Santos'), findsOneWidget);
      expect(find.text('09171231234'), findsOneWidget);
    });

    testWidgets('needs an amount and a destination before it will send', (
      tester,
    ) async {
      await pumpRewards(tester, wallets: savedWallets());
      expect(find.text('Choose an amount'), findsOneWidget);

      // The history below repeats the figure; the chip comes first in the tree.
      await tester.tap(find.text('₱500').first);
      await tester.pump();
      await tester.tap(find.text('GCash'));
      await tester.pump();

      await tapVisible(tester, find.text('Cash out ₱500'));
      await tester.pump();

      expect(find.textContaining('sending ₱500'), findsOneWidget);
    });
  });
}
