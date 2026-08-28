import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpRewards(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.rewards));
    await tester.pump();
  }

  group('RewardsScreen', () {
    testWidgets('offers the two wallets as destinations', (tester) async {
      await pumpRewards(tester);

      expect(find.text('GCash'), findsOneWidget);
      expect(find.text('Maya'), findsOneWidget);
    });

    testWidgets('needs an amount and a destination before it will send', (
      tester,
    ) async {
      await pumpRewards(tester);
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
