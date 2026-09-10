import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/features/support/data/fake_support_desk.dart';
import 'package:happilab/features/support/domain/support_chat.dart';
import 'package:happilab/features/support/presentation/widgets/support_avatar.dart';
import 'package:happilab/shared/widgets/member_avatar.dart';

import '../../support/harness.dart';

void main() {
  /// One read of the desk; the fake moves one step per read.
  const poll = Duration(seconds: 6);

  Future<void> pumpChat(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.supportChat));
    await tester.pump();
  }

  /// Reads until the longest line the fake deals has cleared.
  Future<void> waitForAgent(WidgetTester tester) async {
    for (var i = 0; i < FakeSupportDesk.longestLine; i++) {
      await tester.pump(poll);
    }
  }

  group('SupportChatScreen', () {
    testWidgets('opens from the help center', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(testApp(initialRoute: AppRoutes.helpCenter));
      await tester.pump();

      await tapVisible(tester, find.text('Chat with support'));
      await tester.pumpAndSettle();

      expect(find.text(SupportChatCopy.agentName), findsOneWidget);
      expect(find.text(SupportChatCopy.greeting), findsOneWidget);
      expect(find.text(SupportChatCopy.status), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      // The header and the greeting both wear the app's face.
      expect(find.byType(SupportAvatar), findsNWidgets(2));
      expect(find.byType(MemberAvatar), findsNothing);
    });

    testWidgets('a topic chip opens the chat and puts the member in line', (
      tester,
    ) async {
      await pumpChat(tester);

      // The chip row scrolls sideways; the topic sits past the first screen.
      await tester.dragUntilVisible(
        find.text('Cash out issue'),
        find.byType(ListView).last,
        const Offset(-160, 0),
      );
      await tester.pump();
      await tester.tap(find.text('Cash out issue'));
      await tester.pump();

      expect(find.text(SupportTopic.cashOut.opener), findsOneWidget);
      expect(find.text(SupportTopic.cashOut.followUp), findsOneWidget);
      expect(find.textContaining('in line'), findsNWidgets(2));
      // The openers are gone: the chat is on the desk now.
      expect(find.text('Something else'), findsNothing);
      expect(find.byType(MemberAvatar), findsOneWidget);
    });

    testWidgets('a typed line goes out, and a person joins in time', (
      tester,
    ) async {
      await pumpChat(tester);

      await tester.enterText(find.byType(TextField), 'Hello there');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();

      expect(find.text('Hello there'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );

      await waitForAgent(tester);

      expect(find.textContaining('joined the chat.'), findsOneWidget);
      expect(find.text(SupportChatCopy.agentStatus), findsOneWidget);
      expect(find.textContaining('how can I help?'), findsOneWidget);
    });
  });
}
