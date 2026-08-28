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

      expect(find.text('Your points'.toUpperCase()), findsOneWidget);
      for (final tab in AppTab.values) {
        expect(find.text(tab.label), findsWidgets, reason: tab.label);
      }
    });

    testWidgets('moves between destinations', (tester) async {
      await pumpShell(tester);

      await tapTab(tester, AppTab.products);
      expect(find.textContaining('Suggested for your friends'), findsOneWidget);

      await tapTab(tester, AppTab.profile);
      expect(find.text('Log out'), findsOneWidget);

      await tapTab(tester, AppTab.refer);
      expect(find.text('YOUR CODE'), findsOneWidget);
    });

    testWidgets('a destination carries no back button', (tester) async {
      await pumpShell(tester);
      await tapTab(tester, AppTab.products);

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('cash out on the points card opens rewards', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Cash out').first);
      // A pushed route builds on the frame after the tap, then animates in.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Available'), findsOneWidget);
    });

    /// The reveal snapshots the screen before it flips, then animates; the
    /// flip itself lands a frame or two after the tap.
    Future<void> settleReveal(WidgetTester tester) async {
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
    }

    Brightness brightnessAt(WidgetTester tester, String text) =>
        Theme.of(tester.element(find.text(text))).brightness;

    testWidgets('the profile switch flips the whole app to the dark palette', (
      tester,
    ) async {
      await pumpShell(tester);
      await tapTab(tester, AppTab.profile);
      expect(brightnessAt(tester, 'Dark mode'), Brightness.light);

      // Notifications comes first in the settings list; dark mode is next.
      await tester.tap(find.byType(Switch).at(1));
      await settleReveal(tester);

      expect(brightnessAt(tester, 'Dark mode'), Brightness.dark);
    });

    testWidgets('the home button flips the palette both ways', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.bySemanticsLabel('Switch to dark mode'));
      await settleReveal(tester);
      expect(brightnessAt(tester, 'Welcome,'), Brightness.dark);

      await tester.tap(find.bySemanticsLabel('Switch to light mode'));
      await settleReveal(tester);
      expect(brightnessAt(tester, 'Welcome,'), Brightness.light);
    });

    testWidgets('the profile rewards section opens rewards', (tester) async {
      await pumpShell(tester);
      await tapTab(tester, AppTab.profile);

      // Home carries its own "Cash out" button and sits first in the stack;
      // the profile's card is the last match.
      await tester.tap(find.text('Cash out').last);
      // A pushed route builds on the frame after the tap, then animates in.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Available'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
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
