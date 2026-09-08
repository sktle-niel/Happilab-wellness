import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('the eye hides the balance on home and on cash out alike', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.home));
    await tester.pump();

    expect(find.text('1,240 POINTS'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide points'));
    await tester.pump();

    expect(find.text('•••• POINTS'), findsOneWidget);
    expect(find.text('= ₱••••'), findsOneWidget);

    await tester.tap(find.text('Cash out').first);
    // Explicit pumps, not pumpAndSettle: home animates forever.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('•••• pts'), findsOneWidget);
    expect(find.byTooltip('Show points'), findsOneWidget);

    await tester.tap(find.byTooltip('Show points'));
    await tester.pump();

    expect(find.text('1,240 pts'), findsOneWidget);
  });
}
