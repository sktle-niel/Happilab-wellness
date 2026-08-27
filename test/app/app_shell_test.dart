import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/app/shell/app_tab.dart';

import '../support/harness.dart';

void main() {
  Future<void> pumpShell(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.home));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The bar renders every tab's label, so a tap finds it by name.
  Future<void> tapTab(WidgetTester tester, AppTab tab) async {
    await tester.tap(find.text(tab.label));
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('AppShell', () {
    testWidgets('opens on home with every destination in the bar', (
      tester,
    ) async {
      await pumpShell(tester);

      expect(find.text('Your referral code'.toUpperCase()), findsOneWidget);
      for (final tab in AppTab.values) {
        expect(find.text(tab.label), findsWidgets, reason: tab.label);
      }
    });

    testWidgets('moves between destinations', (tester) async {
      await pumpShell(tester);

      await tapTab(tester, AppTab.rewards);
      expect(find.text('Available'), findsOneWidget);

      await tapTab(tester, AppTab.profile);
      expect(find.text('Payout methods'), findsOneWidget);

      await tapTab(tester, AppTab.refer);
      expect(find.text('YOUR CODE'), findsOneWidget);
    });

    testWidgets('a destination carries no back button', (tester) async {
      await pumpShell(tester);
      await tapTab(tester, AppTab.rewards);

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('cash out on the points card opens the rewards tab', (
      tester,
    ) async {
      await pumpShell(tester);

      await tester.tap(find.text('Cash out').first);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('a screen pushed over the shell does carry one', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(testApp(initialRoute: AppRoutes.howItWorks));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Share your code'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
