import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/shared/widgets/app_button.dart';

import '../../support/harness.dart';

void main() {
  // Counter stands in for Home until that screen is designed and built.
  Future<void> pumpCounter(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.home));
  }

  testWidgets('counter starts at zero and increments on tap', (tester) async {
    await pumpCounter(tester);

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('reset is disabled until the counter moves', (tester) async {
    await pumpCounter(tester);

    final resetButton = find.widgetWithText(AppButton, 'Reset');
    expect(tester.widget<AppButton>(resetButton).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(tester.widget<AppButton>(resetButton).onPressed, isNotNull);

    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
