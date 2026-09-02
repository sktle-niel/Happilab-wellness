import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/theme/app_palette.dart';
import 'package:happilab/app/theme/app_theme.dart';
import 'package:happilab/shared/widgets/app_toast.dart';

void main() {
  /// The card reads `context.palette`, so it needs the app's theme around it.
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );

  Color iconColour(WidgetTester tester) =>
      tester.widget<Icon>(find.byType(Icon)).color!;

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
        ToastKind.success: palette.accentText,
        ToastKind.info: palette.info,
        ToastKind.caution: palette.brand,
        ToastKind.error: palette.danger,
      };

      for (final entry in expected.entries) {
        await tester.pumpWidget(
          host(ToastCard(kind: entry.key, title: entry.key.name)),
        );

        expect(iconColour(tester), entry.value, reason: entry.key.name);
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
      expect(iconColour(tester), AppPalette.dark.danger);
    });
  });

  group('AppToast', () {
    /// A button, because a toast needs a context under the messenger.
    Widget trigger(void Function(BuildContext context) show) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => show(context),
            child: const Text('go'),
          ),
        ),
      ),
    );

    testWidgets('puts the message on screen', (tester) async {
      await tester.pumpWidget(
        trigger((context) => AppToast.success(context, 'Saved')),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.byType(ToastCard), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('replaces the standing message rather than queueing', (
      tester,
    ) async {
      var second = false;
      await tester.pumpWidget(
        trigger(
          (context) => second
              ? AppToast.error(context, 'Second')
              : AppToast.success(context, 'First'),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);

      second = true;
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      // A queued toast would leave the member waiting out the first one.
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });
  });
}
