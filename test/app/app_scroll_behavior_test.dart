import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';

import '../support/harness.dart';

void main() {
  testWidgets('scrolling past an edge draws no stretch or glow', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.howItWorks));
    await tester.pump();

    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pump();

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expect(find.byType(GlowingOverscrollIndicator), findsNothing);
  });
}
