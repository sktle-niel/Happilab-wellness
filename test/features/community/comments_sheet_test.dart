import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';

import '../../support/harness.dart';

void main() {
  Future<void> openComments(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.newsFeed));
    // Two reads settle in turn: the member, then the posts.
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.mode_comment_outlined).first);
    await settleSheet(tester);
    // The thread's own read.
    await tester.pump();
  }

  group('CommentsSheet', () {
    testWidgets('opens the thread with its count and lines', (tester) async {
      await openComments(tester);

      expect(find.text('Comments (5)'), findsOneWidget);
      expect(find.text('@ralphy'), findsOneWidget);
      expect(find.text('@jess123'), findsOneWidget);
    });

    testWidgets('a sent comment joins the thread and the count', (
      tester,
    ) async {
      await openComments(tester);

      await tester.enterText(find.byType(TextField), 'Does it ship to Cebu?');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(find.text('Comments (6)'), findsOneWidget);
      // The new line lands at the foot of a lazy list.
      await tester.drag(find.byType(ListView).last, const Offset(0, -900));
      await tester.pump();
      expect(find.text('Does it ship to Cebu?'), findsOneWidget);
    });

    testWidgets('reply goes under the comment it answers', (tester) async {
      await openComments(tester);

      await tester.tap(find.text('Reply').first);
      await tester.pump();
      expect(find.text('Replying to @ralphy'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Next month, they said.');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(find.text('Next month, they said.'), findsOneWidget);
      expect(find.text('Replying to @ralphy'), findsNothing);
      expect(find.text('Comments (6)'), findsOneWidget);
    });
  });
}
