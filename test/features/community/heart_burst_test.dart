import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/theme/app_theme.dart';
import 'package:happilab/app/theme/app_tokens.dart';
import 'package:happilab/features/community/presentation/widgets/heart_burst.dart';

void main() {
  group('HeartBurst', () {
    late int taps;

    /// The burst reads `context.palette`, so it needs the app's theme around
    /// it — a bare MaterialApp would have no palette extension to find.
    Widget host({bool showBurst = true}) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: showBurst
              ? HeartBurst(
                  onTapped: () => taps++,
                  child: const SizedBox(width: 200, height: 200),
                )
              : const SizedBox(width: 200, height: 200),
        ),
      ),
    );

    Finder hearts() => find.byIcon(Icons.favorite_rounded);

    setUp(() => taps = 0);

    testWidgets('a tap leaves a heart behind', (tester) async {
      await tester.pumpWidget(host());
      expect(hearts(), findsNothing);

      await tester.tap(find.byType(HeartBurst));
      await tester.pump();

      expect(hearts(), findsOneWidget);
      expect(taps, 1);
    });

    testWidgets('the heart clears itself once it has flown', (tester) async {
      await tester.pumpWidget(host());
      await tester.tap(find.byType(HeartBurst));
      await tester.pump();
      expect(hearts(), findsOneWidget);

      await tester.pumpAndSettle();

      expect(hearts(), findsNothing);
    });

    testWidgets('a run of taps overlaps into a burst', (tester) async {
      await tester.pumpWidget(host());

      for (var tap = 0; tap < 4; tap++) {
        await tester.tap(find.byType(HeartBurst));
        // Well inside one heart's life, so none of them has cleared yet.
        await tester.pump(const Duration(milliseconds: 60));
      }

      expect(hearts(), findsNWidgets(4));
      expect(taps, 4);
    });

    testWidgets('reports every tap, not only the first', (tester) async {
      await tester.pumpWidget(host());

      await tester.tap(find.byType(HeartBurst));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.byType(HeartBurst));
      await tester.pump();

      expect(taps, 2);
    });

    testWidgets('leaves no controller running when it goes', (tester) async {
      await tester.pumpWidget(host());
      await tester.tap(find.byType(HeartBurst));
      await tester.pump(const Duration(milliseconds: 60));
      expect(hearts(), findsOneWidget);

      // Tearing the burst down mid-flight: a controller left alive here is a
      // ticker leak, and the test binding fails the test for it.
      await tester.pumpWidget(host(showBurst: false));
      await tester.pump(AppDuration.heartBurst);

      expect(hearts(), findsNothing);
    });
  });
}
