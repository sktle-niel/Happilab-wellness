import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/theme/app_theme.dart';
import 'package:happilab/app/theme/app_tokens.dart';
import 'package:happilab/shared/widgets/app_loader.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  Finder slowNote() => find.textContaining('taking longer than usual');

  group('AppLoader', () {
    testWidgets('says what it is for anyone who cannot see it', (tester) async {
      await tester.pumpWidget(host(const AppLoader()));

      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    });

    testWidgets('keeps pulsing without settling', (tester) async {
      await tester.pumpWidget(host(const AppLoader()));

      // A loader that settles has stopped saying anything, so well into the
      // cycle it must still be asking for frames.
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.binding.hasScheduledFrame, isTrue);
    });
  });

  group('LoadingView', () {
    testWidgets('waits quietly at first', (tester) async {
      await tester.pumpWidget(host(const LoadingView()));

      expect(find.byType(AppLoader), findsOneWidget);
      expect(slowNote(), findsNothing);
    });

    testWidgets('shows the label it was handed', (tester) async {
      await tester.pumpWidget(
        host(const LoadingView(label: 'Loading stories')),
      );

      expect(find.text('Loading stories'), findsOneWidget);
    });

    testWidgets('says nothing about the connection before the wait runs long', (
      tester,
    ) async {
      await tester.pumpWidget(host(const LoadingView()));

      await tester.pump(AppDuration.slowHint - const Duration(seconds: 1));

      expect(slowNote(), findsNothing);
    });

    testWidgets('admits a slow connection once the wait runs long', (
      tester,
    ) async {
      await tester.pumpWidget(host(const LoadingView()));

      await tester.pump(AppDuration.slowHint);
      await tester.pump();

      // A loader that never changes cannot be told apart from one that hung.
      expect(slowNote(), findsOneWidget);
    });

    testWidgets('drops its timer when it goes', (tester) async {
      await tester.pumpWidget(host(const LoadingView()));
      await tester.pump(const Duration(seconds: 1));

      // A timer left running past the widget fires setState on a dead State,
      // and the test binding fails the test for the pending timer.
      await tester.pumpWidget(host(const SizedBox.shrink()));
      await tester.pump(AppDuration.slowHint);

      expect(slowNote(), findsNothing);
    });
  });
}
