import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/theme/app_theme.dart';
import 'package:happilab/shared/widgets/skeleton.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  /// The route's own cross-fade is a FadeTransition too; only the ones the
  /// skeleton drives count.
  Finder breaths() => find.descendant(
    of: find.byType(Skeleton),
    matching: find.byType(FadeTransition),
  );

  group('Skeleton', () {
    testWidgets('a lone box starts its own breath', (tester) async {
      await tester.pumpWidget(host(const SkeletonBox(width: 80, height: 12)));

      expect(find.byType(Skeleton), findsOneWidget);
      expect(breaths(), findsOneWidget);
    });

    testWidgets('boxes under one skeleton breathe from one ticker', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Skeleton(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox.circle(size: 40),
                SkeletonLine(widthFactor: 0.6),
                SkeletonLine(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Skeleton), findsOneWidget);
      expect(breaths(), findsNWidgets(3));

      // Half a breath in, the boxes are on their way to faint.
      final before = tester
          .widget<FadeTransition>(breaths().first)
          .opacity
          .value;
      await tester.pump(const Duration(milliseconds: 550));
      final after = tester
          .widget<FadeTransition>(breaths().first)
          .opacity
          .value;

      expect(after, isNot(before));
    });
  });
}
