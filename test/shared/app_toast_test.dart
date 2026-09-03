import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/theme/app_palette.dart';
import 'package:happilab/app/theme/app_theme.dart';
import 'package:happilab/app/theme/app_tokens.dart';
import 'package:happilab/shared/widgets/app_toast.dart';
import 'package:happilab/shared/widgets/circle_badge.dart';

void main() {
  /// The card reads `context.palette`, so it needs the app's theme around it.
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );

  /// The badge disc is what carries the kind's colour in this design.
  Color discColour(WidgetTester tester) =>
      tester.widget<CircleBadge>(find.byType(CircleBadge)).color!;

  group('ToastCard', () {
    testWidgets('carries its title and its detail', (tester) async {
      await tester.pumpWidget(
        host(
          const ToastCard(
            kind: ToastKind.success,
            title: 'Code copied',
            detail: 'Paste it anywhere you like.',
          ),
        ),
      );

      expect(find.text('Code copied'), findsOneWidget);
      expect(find.text('Paste it anywhere you like.'), findsOneWidget);
    });

    testWidgets('stands on its own without a detail', (tester) async {
      await tester.pumpWidget(
        host(const ToastCard(kind: ToastKind.info, title: 'Nothing to do')),
      );

      expect(find.text('Nothing to do'), findsOneWidget);
    });

    testWidgets('each kind wears the colour that carries its meaning', (
      tester,
    ) async {
      const palette = AppPalette.light;
      final expected = <ToastKind, Color>{
        ToastKind.success: palette.accent,
        ToastKind.info: palette.info,
        ToastKind.caution: palette.brand,
        ToastKind.error: palette.danger,
      };

      for (final entry in expected.entries) {
        await tester.pumpWidget(
          host(ToastCard(kind: entry.key, title: entry.key.name)),
        );

        expect(discColour(tester), entry.value, reason: entry.key.name);
      }
    });

    testWidgets('follows the member into dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: ToastCard(kind: ToastKind.error, title: 'Failed'),
          ),
        ),
      );

      // The light palette's danger would be the wrong red on a dark surface.
      expect(discColour(tester), AppPalette.dark.danger);
    });
  });

  group('AppToast', () {
    /// A button, because a toast needs a context under the app's overlay.
    /// Centred so the stack dropping in at the top never sits over it — a
    /// toast is tappable, and a covered button would dismiss toasts instead
    /// of showing them.
    Widget trigger(void Function(BuildContext context) show) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => show(context),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );

    /// Not pumpAndSettle: a toast's whole life is one animation, so settling
    /// would wait until it has already taken itself down.
    Future<void> pumpIn(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('puts the message on screen, at the top', (tester) async {
      await tester.pumpWidget(
        trigger((context) => AppToast.success(context, 'Saved')),
      );

      await tester.tap(find.text('go'));
      await pumpIn(tester);

      expect(find.byType(ToastCard), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);

      // Above the vertical middle — a toast that rises from the bottom would
      // sit under the thumb and the nav bar.
      final centre = tester.getCenter(find.byType(ToastCard));
      final screen = tester.getSize(find.byType(MaterialApp));
      expect(centre.dy, lessThan(screen.height / 2));
    });

    testWidgets('takes itself down when its time is up', (tester) async {
      await tester.pumpWidget(
        trigger((context) => AppToast.success(context, 'Saved')),
      );

      await tester.tap(find.text('go'));
      await pumpIn(tester);
      await tester.pump(AppDuration.toast);
      await tester.pump();

      expect(find.byType(ToastCard), findsNothing);
    });

    testWidgets('stacks a second message instead of losing the first', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        trigger((context) => AppToast.success(context, 'Message ${++count}')),
      );

      await tester.tap(find.text('go'));
      await pumpIn(tester);
      await tester.tap(find.text('go'));
      await pumpIn(tester);

      // Both stand; a replacing toast would have eaten the first.
      expect(find.text('Message 1'), findsOneWidget);
      expect(find.text('Message 2'), findsOneWidget);

      // The newer one is in front: lower depth means no downward nudge.
      final first = tester.getTopLeft(find.text('Message 1'));
      final second = tester.getTopLeft(find.text('Message 2'));
      expect(second.dy, lessThan(first.dy));
    });

    testWidgets('holds three at most, letting the oldest go', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        trigger((context) => AppToast.success(context, 'Message ${++count}')),
      );

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('go'));
        await pumpIn(tester);
      }

      expect(find.text('Message 1'), findsNothing);
      expect(find.text('Message 2'), findsOneWidget);
      expect(find.text('Message 3'), findsOneWidget);
      expect(find.text('Message 4'), findsOneWidget);
    });

    testWidgets('a tap sends a toast away early', (tester) async {
      await tester.pumpWidget(
        trigger((context) => AppToast.success(context, 'Saved')),
      );

      await tester.tap(find.text('go'));
      await pumpIn(tester);

      await tester.tap(find.byType(ToastCard));
      // One pump starts the dismissal's ticker; the next rides it out.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.byType(ToastCard), findsNothing);
    });
  });
}
